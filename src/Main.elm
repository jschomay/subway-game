port module Main exposing (..)

import Engine exposing (..)
import Manifest
import Rules
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Tuple


-- import Theme.Layout

import ClientTypes exposing (..)
import Narrative
import Components exposing (..)
import Dict exposing (Dict)
import List.Zipper as Zipper exposing (Zipper)
import Subway
import Color


{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


main : Program Never Model ClientTypes.Msg
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
    , storyLine : List StorySnippet
    , narrativeContent : Dict String (Zipper String)
    , location : Location
    }


type Location
    = OnPlatform Subway.Station
    | OnTrain Subway.Train Subway.Station
    | InStation Subway.Station


init : ( Model, Cmd ClientTypes.Msg )
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
    in
        ( { engineModel = engineModel
          , loaded = False
          , storyLine = [ Narrative.startingNarrative ]
          , narrativeContent = Dict.map (curry getNarrative) Rules.rules
          , location = OnPlatform Subway.Central
          }
        , Cmd.none
        )


findEntity : String -> Entity
findEntity id =
    (Manifest.items ++ Manifest.locations ++ Manifest.characters)
        |> List.filter (Tuple.first >> (==) id)
        |> List.head
        |> Maybe.withDefault (entity id)


update :
    ClientTypes.Msg
    -> Model
    -> ( Model, Cmd ClientTypes.Msg )
update msg model =
    if Engine.getEnding model.engineModel /= Nothing then
        -- no-op if story has ended
        ( model, Cmd.none )
    else
        case msg of
            Interact interactableId ->
                let
                    ( newEngineModel, maybeMatchedRuleId ) =
                        Engine.update interactableId model.engineModel

                    {- If the engine found a matching rule, look up the narrative content component for that rule if possible.  The description from the display info component for the entity that was interacted with is used as a default. -}
                    narrativeForThisInteraction =
                        { interactableName = findEntity interactableId |> getDisplayInfo |> .name
                        , interactableCssSelector = findEntity interactableId |> getClassName
                        , narrative =
                            maybeMatchedRuleId
                                |> Maybe.andThen (\id -> Dict.get id model.narrativeContent)
                                |> Maybe.map Zipper.current
                                |> Maybe.withDefault (findEntity interactableId |> getDisplayInfo |> .description)
                        }

                    {- If a rule matched, attempt to move to the next associated narrative content for next time. -}
                    updateNarrativeContent : Maybe (Zipper String) -> Maybe (Zipper String)
                    updateNarrativeContent =
                        Maybe.map (\narrative -> Zipper.next narrative |> Maybe.withDefault narrative)

                    updatedContent =
                        maybeMatchedRuleId
                            |> Maybe.map (\id -> Dict.update id updateNarrativeContent model.narrativeContent)
                            |> Maybe.withDefault model.narrativeContent
                in
                    ( { model
                        | engineModel = newEngineModel
                        , storyLine = narrativeForThisInteraction :: model.storyLine
                        , narrativeContent = updatedContent
                      }
                    , Cmd.none
                    )

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )

            BoardTrain train ->
                let
                    leavingStation =
                        case model.location of
                            OnTrain train station ->
                                station

                            OnPlatform station ->
                                station

                            InStation station ->
                                station
                in
                    ( { model | location = OnTrain train leavingStation }
                    , Cmd.none
                    )

            ExitTrain ->
                let
                    station =
                        case model.location of
                            OnTrain train station ->
                                station

                            OnPlatform station ->
                                station

                            InStation station ->
                                station
                in
                    ( { model | location = OnPlatform station }
                    , Cmd.none
                    )

            ArriveAtStation ->
                let
                    location =
                        case model.location of
                            OnTrain train previousStation ->
                                Subway.nextStop Subway.fullMap train previousStation
                                    |> Maybe.withDefault previousStation
                                    |> OnTrain train

                            x ->
                                x
                in
                    ( { model | location = location }
                    , Cmd.none
                    )


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub ClientTypes.Msg
subscriptions model =
    loaded <| always Loaded


view :
    Model
    -> Html ClientTypes.Msg
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

        graphViz =
            textarea [] [ text <| Subway.draw ]
    in
        div []
            [ mapView
            , gameView model
            ]


gameView : Model -> Html Msg
gameView model =
    case model.location of
        InStation station ->
            text "In the station..."

        OnPlatform station ->
            div [] <| [ stationView <| Subway.stationInfo station ]

        OnTrain train station ->
            let
                nextStop =
                    Subway.nextStop Subway.fullMap train station
            in
                div [] <| [ trainView { nextStop = nextStop, trainInfo = Subway.trainInfo train } ]


stationView : Subway.StationInfo Msg -> Html Msg
stationView { name, connections } =
    let
        connectionView connection =
            li [ class "connection", onClick <| connection.msg BoardTrain ]
                [ div
                    [ class "connection__number"
                    , style [ ( "color", toColor connection.color ), ( "borderColor", toColor connection.color ) ]
                    ]
                    [ text <| toString connection.number ]
                , div [ class "connection__direction" ] [ text <| "Towards " ++ (Subway.stationInfo connection.direction |> .name) ++ " station" ]
                ]

        connectionsView connections =
            ul [ class "station__connections" ]
                (connections
                    |> List.sortBy .number
                    |> List.map connectionView
                )
    in
        div [ class "station" ]
            [ h2 [ class "station__name" ] [ text <| name ++ " station" ]
            , connectionsView connections
            ]


trainView : { trainInfo : Subway.TrainInfo Msg, nextStop : Maybe Subway.Station } -> Html Msg
trainView { trainInfo, nextStop } =
    let
        display =
            nextStop
                |> Maybe.map (Subway.stationInfo >> .name >> (++) " - next stop ")
                |> Maybe.withDefault " - end of the line"
    in
        div [] <|
            [ h3 [] [ text <| trainInfo.name ++ display ]
            , button [ onClick <| ArriveAtStation ] [ text "Continue" ]
            , button [ onClick <| ExitTrain ] [ text "Get off" ]
            ]


mapView : Html Msg
mapView =
    pre [ style [ ( "fontFamily", "monospace" ) ] ] [ text """
                                         red line
                         / ----------------------------- o EastEnd
                       / / --------------------------- / |
                     / /           yellow line           |
                   / /                                   |
            Market o                                     |
                   | \\                   / ------------- /
                   |   \\               /    green line
        red line   |     \\           /
         ---------/        \\       /
       /                     \\ --- o Central
       |                           |
       |                           |
       |                           |
       |         green line        |
       o ------------------------- /
    WestEnd


   red line - WestEnd, Market, EastEnd
   green line - WestEnd, Central, EastEnd
   yellow line - Central, Market, EastEnd
""" ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> \{ red, green, blue } -> "rgb(" ++ toString red ++ "," ++ toString green ++ "," ++ toString blue ++ ")"
