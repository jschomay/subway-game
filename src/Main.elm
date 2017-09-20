port module Main exposing (..)

import Engine exposing (..)
import Manifest
import Rules
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Tuple
import Process
import Task
import Time exposing (Time)
import Types exposing (..)
import Components exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)
import Subway
import Color
import City exposing (..)
import Markdown


{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { engineModel : Engine.Model
    , loaded : Bool
    , storyLine : List String
    , narrativeContent : Dict String (Zipper String)
    , location : Location
    , showMap : Bool
    }


init : ( Model, Cmd Msg )
init =
    let
        engineModel =
            Engine.init
                { items = List.map Tuple.first Manifest.items
                , locations = List.map Tuple.first Manifest.locations
                , characters = List.map Tuple.first Manifest.characters
                }
                (Dict.map (curry getRuleData) Rules.rules)
                |> Engine.changeWorld Rules.startingState

        startingPlace =
            OnPlatform EastMulberry
    in
        ( { engineModel = engineModel
          , loaded = False
          , storyLine = []
          , narrativeContent = Dict.map (curry getNarrative) Rules.rules
          , location = startingPlace
          , showMap = False
          }
            |> updateStory "platform"
        , Cmd.none
        )


transitDelay : Time
transitDelay =
    12 * 1000


platformDelay : Time
platformDelay =
    6 * 1000


findEntity : String -> Entity
findEntity id =
    (Manifest.items ++ Manifest.locations ++ Manifest.characters)
        |> List.filter (Tuple.first >> (==) id)
        |> List.head
        |> Maybe.withDefault (entity id)


updateStory : String -> Model -> Model
updateStory interactableId model =
    let
        ( newEngineModel, maybeMatchedRuleId ) =
            Engine.update interactableId model.engineModel

        {- If the engine found a matching rule, look up the narrative content component for that rule if possible.  The description from the display info component for the entity that was interacted with is used as a default. -}
        narrativeForThisInteraction =
            maybeMatchedRuleId
                |> Maybe.andThen (\id -> Dict.get id model.narrativeContent)
                |> Maybe.map Zipper.current

        {- If a rule matched, attempt to move to the next associated narrative content for next time. -}
        updateNarrativeContent : Maybe (Zipper String) -> Maybe (Zipper String)
        updateNarrativeContent =
            Maybe.andThen (\narrative -> Zipper.next narrative)

        updatedContent =
            maybeMatchedRuleId
                |> Maybe.map (\id -> Dict.update id updateNarrativeContent model.narrativeContent)
                |> Maybe.withDefault model.narrativeContent
    in
        { model
            | engineModel = newEngineModel
            , storyLine = Maybe.map (\snippet -> snippet :: model.storyLine) narrativeForThisInteraction |> Maybe.withDefault model.storyLine
            , narrativeContent = updatedContent
        }


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


update :
    Msg
    -> Model
    -> ( Model, Cmd Msg )
update msg model =
    if Engine.getEnding model.engineModel /= Nothing then
        -- no-op if story has ended
        noop model
    else
        case msg of
            Interact interactableId ->
                ( updateStory interactableId model
                , Cmd.none
                )

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )

            Delay duration msg ->
                ( model
                , Task.perform (always msg) <| Process.sleep duration
                )

            ToggleMap ->
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            BoardTrain train ->
                case model.location of
                    OnPlatform station ->
                        let
                            cmd =
                                case Subway.nextStop City.map train (stationInfo station |> .id) of
                                    Nothing ->
                                        Cmd.none

                                    Just station ->
                                        delay 0 <| LeavePlatform

                            location =
                                OnTrain train station Stopped
                        in
                            ( { model
                                | location = location
                                , storyLine = []
                              }
                                |> updateStory "train"
                            , cmd
                            )

                    _ ->
                        noop model

            ExitTrain ->
                case model.location of
                    OnTrain train station Stopped ->
                        ( { model
                            | location = OnPlatform station
                            , storyLine = []
                          }
                            |> updateStory "platform"
                        , Cmd.none
                        )

                    _ ->
                        noop model

            ArriveAtPlatform station ->
                let
                    newLocation =
                        case model.location of
                            OnTrain train arrivingFrom Moving ->
                                OnTrain train station Stopped

                            other ->
                                other
                in
                    ( { model | location = newLocation }
                    , delay platformDelay LeavePlatform
                    )

            LeavePlatform ->
                case model.location of
                    OnTrain train station Stopped ->
                        case Subway.nextStop City.map train (stationInfo station |> .id) of
                            Nothing ->
                                noop model

                            Just next ->
                                ( { model | location = OnTrain train station Moving }, delay transitDelay <| ArriveAtPlatform next )

                    _ ->
                        noop model


delay : Time -> Msg -> Cmd Msg
delay duration msg =
    Task.perform (always msg) <| Process.sleep duration


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loaded <| always Loaded
          -- , AnimationFrame.times Tick
        ]


view :
    Model
    -> Html Msg
view model =
    let
        currentLocation =
            Engine.getCurrentLocation model.engineModel |> findEntity

        displayState =
            { currentLocation = currentLocation
            , itemsInCurrentLocation =
                Engine.getItemsInCurrentLocation model.engineModel
                    |> List.map findEntity
            , charactersInCurrentLocation =
                Engine.getCharactersInCurrentLocation model.engineModel
                    |> List.map findEntity
            , exits =
                getExits currentLocation
                    |> List.map
                        (\( direction, id ) ->
                            ( direction, findEntity id )
                        )
            , itemsInInventory =
                Engine.getItemsInInventory model.engineModel
                    |> List.map findEntity
            , ending =
                Engine.getEnding model.engineModel
            , storyLine =
                model.storyLine
            }

        -- graphViz =
        --     Debug.log (Subway.graphViz City.map ++ "\n") "Copy and paste in http://viz-js.com/"
    in
        div [ class "game" ]
            [ gameView model
            , if model.showMap then
                mapView
              else
                div [ onClick ToggleMap, class "map_toggle" ] [ text "Map" ]
            ]


gameView : Model -> Html Msg
gameView model =
    case model.location of
        InStation station ->
            text "In the station..."

        OnPlatform station ->
            platformView station (Subway.connections City.map (stationInfo station |> .id)) model.storyLine

        OnTrain (( line, end ) as train) currentStation status ->
            trainView
                line
                end
                currentStation
                (Subway.nextStop City.map train (stationInfo currentStation |> .id))
                status
                model.storyLine


platformView : Station -> List ( Line, Station ) -> List String -> Html Msg
platformView station connections storyLine =
    let
        connectionView (( line, end ) as connection) =
            let
                lineInfo =
                    City.lineInfo line
            in
                li [ class "connection", onClick <| BoardTrain connection ]
                    [ div
                        [ class "connection__number"
                        , style [ ( "color", toColor lineInfo.color ), ( "borderColor", toColor lineInfo.color ) ]
                        ]
                        [ text <| toString lineInfo.number ]
                    , div [ class "connection__direction" ] [ text (stationInfo end |> .name) ]
                    ]

        connectionsView connections =
            ul [ class "platform_info__connections" ]
                (connections
                    |> List.sortBy (\( line, _ ) -> lineInfo line |> .number)
                    |> List.map connectionView
                )
    in
        div [ class "platform" ]
            [ div [ class "platform__story" ] [ storyView storyLine ]
            , div [ class "platform__platform_info" ]
                [ div [ class "platform_info" ]
                    [ h2 [ class "platform_info__name" ] [ text (stationInfo station |> .name) ]
                    , connectionsView connections
                    ]
                ]
            ]


storyView : List String -> Html Msg
storyView storyLine =
    Html.Keyed.ul [ class "StoryLine" ] <|
        List.indexedMap
            (\i narrative -> ( toString (List.length storyLine - i), li [ class "StoryLine__Item u-fade-in" ] [ Markdown.toHtml [] narrative ] ))
            storyLine


trainView : Line -> Station -> Station -> Maybe Station -> TrainStatus -> List String -> Html Msg
trainView line end currentStation nextStation status storyLine =
    let
        nextStop =
            case ( status, nextStation ) of
                ( Moving, Just next ) ->
                    "Next stop: " ++ (stationInfo next |> .name)

                ( Moving, Nothing ) ->
                    "Out of service"

                ( Stopped, Just next ) ->
                    "Arriving at: " ++ (stationInfo currentStation |> .name)

                ( Stopped, Nothing ) ->
                    "End of the line: " ++ (stationInfo currentStation |> .name)

        info =
            (lineInfo line |> .name) ++ " towards " ++ (stationInfo end |> .name)

        buttonClasses =
            classList
                [ ( "exit_button", True )
                , ( "exit_button--active", stopped )
                ]

        stopped =
            case status of
                Moving ->
                    False

                Stopped ->
                    True

        action =
            if stopped then
                [ onClick ExitTrain ]
            else
                []
    in
        div [ class "train" ] <|
            [ div [ class "train__story" ] [ storyView storyLine ]
            , div [ class "train__ticker" ]
                [ h4 [ class "train__info" ] [ text info ]
                , h3 [ class "train__next_stop" ] [ text nextStop ]
                ]
            , div [ class "train__exit_button" ]
                [ button (buttonClasses :: action) [ text "Exit train" ]
                ]
            ]


mapView : Html Msg
mapView =
    div [ onClick ToggleMap, class "map" ]
        [ pre [ class "map__image", style [ ( "fontFamily", "monospace" ) ] ] [ text """

  Red Line:

        WestMulberry
             |
             |
        EastMulberry
             |
             |
        ChurchStreet
             |
             |
        MetroCenter
             |
             |
        FederalTriangle
             |
             |
        SpringHill
             |
             |
        TwinBrooks

""" ]
        ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> \{ red, green, blue } -> "rgb(" ++ toString red ++ "," ++ toString green ++ "," ++ toString blue ++ ")"
