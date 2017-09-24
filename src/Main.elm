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

    TODO
    - for intro section, figure out if the intro should advance by timing, or by user action
      - if by timing, how to indicate time left/give enough time?
      - if by action, what action?  Does the action need to be validated?  What about getting off at the right station?
      - if by action, does that affect the tone of voice used (switching from 3rd person to 1st/2nd?)
   - insert title cards/blank screen at appropriate points in intro
-}


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Day
    = Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday


type alias Model =
    { engineModel : Engine.Model
    , loaded : Bool
    , storyLine : String
    , narrativeContent : Dict String (Zipper String)
    , location : Location
    , isIntro : Bool
    , day : Day
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
            OnPlatform WestMulberry
    in
        ( { engineModel = engineModel
          , loaded = False
          , storyLine = ""
          , narrativeContent = Dict.map (curry getNarrative) Rules.rules
          , location = startingPlace
          , isIntro = True
          , day = Monday
          , showMap = False
          }
            |> updateStory "platform"
        , Cmd.none
        )


transitDelay : Time
transitDelay =
    -- 12 * 1000
    1 * 1000


platformDelay : Time
platformDelay =
    -- 6 * 1000
    1 * 1000


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

        narrativeForThisInteraction =
            maybeMatchedRuleId
                |> Maybe.andThen (\id -> Dict.get id model.narrativeContent)
                |> Maybe.map Zipper.current

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
            , storyLine = narrativeForThisInteraction |> Maybe.withDefault "..."
            , narrativeContent = updatedContent
        }


nextDay : Day -> Day
nextDay day =
    case day of
        Monday ->
            Tuesday

        Tuesday ->
            Wednesday

        Wednesday ->
            Thursday

        Thursday ->
            Friday

        Friday ->
            Friday


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


setEngineScene : String -> Engine.Model -> Engine.Model
setEngineScene scene model =
    Engine.changeWorld [ Engine.loadScene scene ] model


setEngineLocation : Station -> Engine.Model -> Engine.Model
setEngineLocation station model =
    Engine.changeWorld [ Engine.moveTo ((stationInfo >> .name) station) ] model


{-| Used when you need to manually change the location (or other Model field) outside of the normal subway mechanics.
   Or when you need to manually change the scene based on data outside of the Engine.Model

   ** Don't forget to call `updateStory` to get the right narrative based on your changes, but NOT if it was already called!
   ** Don't forget to call `setEngineLocation` if you change the `Location` to keep the Engine.Model locaiton in sync
-}
storyOverrides : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
storyOverrides msg ( model, cmd ) =
    -- TODO maybe move this somewhere else and find a better data driven way of representing it?
    case ( Engine.getCurrentScene model.engineModel, msg ) of
        ( "meetSteve", ArriveAtPlatform MetroCenter ) ->
            ( { model
                | location = OnPlatform WestMulberry
                , engineModel = setEngineLocation WestMulberry model.engineModel
                , day = nextDay model.day
              }
                |> updateStory "platform"
            , cmd
            )

        ( "meetSteve", ArriveAtPlatform ChurchStreet ) ->
            if model.day == Friday then
                ( { model
                    | location = OnTrain ( Red, TwinBrooks ) TwinBrooks Stopped
                    , engineModel =
                        model.engineModel
                            |> setEngineLocation TwinBrooks
                            |> setEngineScene "getBackToMetroCenter"
                    , isIntro = False
                  }
                    |> updateStory "train"
                , cmd
                )
            else
                ( model, cmd )

        _ ->
            ( model, cmd )


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
                    ( { model
                        | location = newLocation
                        , engineModel = setEngineLocation station model.engineModel
                      }
                    , delay platformDelay LeavePlatform
                    )
                        |> storyOverrides msg

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
    -- Debug.log (Subway.graphViz City.map ++ "\n") "Copy and paste in http://viz-js.com/" |> \_ ->
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
            platformView station
                (Subway.connections City.map (stationInfo station |> .id))
                model.storyLine

        OnTrain (( line, end ) as train) currentStation status ->
            trainView
                line
                end
                currentStation
                (Subway.nextStop City.map train (stationInfo currentStation |> .id))
                status
                model.isIntro
                model.storyLine


platformView : Station -> List ( Line, Station ) -> String -> Html Msg
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


storyView : String -> Html Msg
storyView storyLine =
    Html.Keyed.node "div" [ class "StoryLine" ] [ ( storyLine, Markdown.toHtml [ class "StoryLine__Item u-fade-in" ] storyLine ) ]


trainView : Line -> Station -> Station -> Maybe Station -> TrainStatus -> Bool -> String -> Html Msg
trainView line end currentStation nextStation status isIntro storyLine =
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

        exitButton =
            if isIntro then
                []
            else
                [ div [ class "train__exit_button" ]
                    [ button (buttonClasses :: action) [ text "Exit train" ]
                    ]
                ]
    in
        div [ class "train" ] <|
            [ div [ class "train__story" ] [ storyView storyLine ]
            , div [ class "train__ticker" ]
                [ h4 [ class "train__info" ] [ text info ]
                , h3 [ class "train__next_stop" ] [ text nextStop ]
                ]
            ]
                ++ exitButton


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
