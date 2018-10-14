port module Main exposing
    ( Day(..)
    , Model
    , arrowView
    , changeTrainStatus
    , connectingHallsView
    , delay
    , findEntity
    , gameView
    , getCurrentStation
    , init
    , loaded
    , main
    , mapView
    , nextDay
    , noop
    , platformDelay
    , scriptedEvents
    , stationView
    , storyView
    , subscriptions
    , titleCardDelay
    , titleCardView
    , toColor
    , transitDelay
    , update
    , updateStory
    , update_
    , view
    )

import Browser
import City exposing (..)
import Color
import Components exposing (..)
import Dict exposing (Dict)
import Engine exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import List.Extra
import List.Zipper as Zipper exposing (Zipper)
import LocalTypes exposing (..)
import Manifest
import Markdown
import Murmur3
import Process
import Rules
import Subway
import Task
import Tuple
import Views.Train



{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


type alias Flags =
    {}


main : Program Flags Model Msg
main =
    Browser.document
        { init = always init
        , view = \model -> { title = "Subway!", body = [ view model ] }
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
    , storyLine : Maybe String
    , narrativeContent : Dict String (Zipper String)
    , map : Subway.Map City.Station City.Line
    , mapImage : String
    , location : Location
    , isIntro : Bool
    , titleCard : Maybe String
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
                (Dict.map (\a b -> getRuleData ( a, b )) Rules.rules)
                |> Engine.changeWorld Rules.startingState
    in
    ( { engineModel = engineModel
      , loaded = False
      , storyLine = Nothing
      , narrativeContent = Dict.map (\a b -> getNarrative ( a, b )) Rules.rules
      , map = City.fullMap
      , mapImage = City.mapImage City.RedMap
      , location = InStation
      , isIntro = False
      , titleCard = Nothing
      , day = Monday
      , showMap = False
      }
        |> updateStory "nextDay"
    , delay titleCardDelay RemoveTitleCard
    )


titleCardDelay : Float
titleCardDelay =
    1 * 1000


transitDelay : Float
transitDelay =
    7 * 1000


platformDelay : Float
platformDelay =
    5 * 1000


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
        , storyLine = narrativeForThisInteraction
        , narrativeContent = updatedContent
    }


nextDay : Day -> { titleCard : String, day : Day }
nextDay day =
    case day of
        Monday ->
            { titleCard = "Tuesday, 6:02 AM"
            , day = Tuesday
            }

        Tuesday ->
            { titleCard = "Wednesday, 6:01 AM"
            , day = Wednesday
            }

        Wednesday ->
            { titleCard = "Thursday, 6:04 AM"
            , day = Thursday
            }

        Thursday ->
            { titleCard = "Friday, 6:05 AM"
            , day = Friday
            }

        Friday ->
            { titleCard = "Friday"
            , day = Friday
            }


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


changeTrainStatus : TrainStatus -> Location -> Location
changeTrainStatus newStatus status =
    case status of
        OnTrain train _ ->
            OnTrain train newStatus

        other ->
            other


{-| Use when you need to manually change the Model outside of the normal subway mechanics.

Tip: use the event name as a discrete string for updateStory, then you can set the scene, location, etc of the EngineModel via the usual Engine rules instead of with Engine.changeWorld

\*\* Don't forget to call `updateStory` to get the right narrative based on your changes, but be careful not to call it twice (if it was already called in `update`)

\*\* Dont' forget to pass through or batch in the cmd if unless you know you want to cancel it

-}
scriptedEvents : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
scriptedEvents msg ( model, cmd ) =
    case ( Engine.getCurrentScene model.engineModel, msg ) of
        ( "meetSteve", Continue ) ->
            case ( model.isIntro, model.day, model.location ) of
                ( True, _, InStation ) ->
                    -- board train to work (via the Msg)
                    ( { model | location = InConnectingHalls }
                    , delay 0 <| BoardTrain ( Red, TwinBrooks )
                    )

                ( True, Friday, OnTrain _ _ ) ->
                    noop model

                ( True, _, OnTrain train _ ) ->
                    -- jump to next day
                    ( { model
                        | location = InStation
                        , day = nextDay model.day |> .day
                        , titleCard = Just <| .titleCard <| nextDay model.day
                      }
                        |> updateStory "nextDay"
                    , delay titleCardDelay RemoveTitleCard
                    )

                _ ->
                    noop model

        ( "meetSteve", ArriveAtStation MetroCenter ) ->
            -- jump to next day (save as above)
            ( { model
                | location = InStation
                , day = nextDay model.day |> .day
                , titleCard = Just <| .titleCard <| nextDay model.day
              }
                |> updateStory "nextDay"
            , delay titleCardDelay RemoveTitleCard
            )

        ( "meetSteve", ArriveAtStation ChurchStreet ) ->
            -- fall asleep, end intro
            if model.day == Friday then
                ( { model
                    | location = changeTrainStatus Stopped model.location
                    , isIntro = False
                    , titleCard = Just ""
                  }
                    |> updateStory "fallAsleep"
                , delay 4000 RemoveTitleCard
                )

            else
                ( model, cmd )

        ( "overslept", ArriveAtStation FederalTriangle ) ->
            -- stop the train before Metro Center and add yellow line
            ( { model
                | location = changeTrainStatus OutOfService model.location
                , map = City.map [ Red, Yellow ]
              }
                |> updateStory "outOfService"
            , Cmd.none
            )

        _ ->
            ( model, cmd )


getCurrentStation : Model -> Station
getCurrentStation model =
    Engine.getCurrentLocation model.engineModel
        |> String.toInt
        |> Maybe.andThen (Subway.getStation model.map)
        |> Maybe.withDefault WestMulberry


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    update_ msg model



-- TODO put back after adjusting train mechanics if needed
-- |> scriptedEvents msg


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
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

            Delay duration delayedMsg ->
                ( model
                , Task.perform (always delayedMsg) <| Process.sleep duration
                )

            Continue ->
                -- use scriptedEvents to respond to Continue's
                noop model

            RemoveTitleCard ->
                ( { model
                    | titleCard = Nothing
                    , showMap = False
                  }
                , Cmd.none
                )

            ToggleMap ->
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            PassTurnStyle ->
                let
                    currentStation =
                        getCurrentStation model
                in
                case model.location of
                    InStation ->
                        ( { model | location = InConnectingHalls }, Cmd.none )

                    _ ->
                        noop model

            BoardTrain train ->
                case model.location of
                    InConnectingHalls ->
                        let
                            currentStation =
                                getCurrentStation model

                            cmd =
                                -- TODO update for new mechanics of navigation...
                                delay 0 <| LeaveStation
                        in
                        ( { model
                            | location = OnTrain train Stopped
                          }
                            |> updateStory "train"
                        , cmd
                        )

                    _ ->
                        noop model

            ExitTrain ->
                let
                    currentStation =
                        getCurrentStation model
                in
                case model.location of
                    OnTrain train Stopped ->
                        ( { model | location = InStation } |> updateStory "platform", Cmd.none )

                    OnTrain train OutOfService ->
                        ( { model | location = InStation } |> updateStory "platform", Cmd.none )

                    _ ->
                        noop model

            ArriveAtStation newStation ->
                case model.location of
                    OnTrain train Moving ->
                        ( { model
                            | location = model.location |> changeTrainStatus Stopped
                            , engineModel =
                                -- this is the only place there should be an Engine.changeWorld call to set the location
                                Engine.changeWorld
                                    [ Engine.moveTo (newStation |> stationInfo |> .id |> String.fromInt) ]
                                    model.engineModel
                          }
                        , Cmd.batch
                            [ delay platformDelay LeaveStation
                            ]
                        )

                    _ ->
                        noop model

            LeaveStation ->
                let
                    currentStation =
                        getCurrentStation model
                in
                case model.location of
                    -- TODO needs to be updated with new navigation mechanic
                    OnTrain train Stopped ->
                        ( { model
                            | location = changeTrainStatus Moving model.location
                          }
                        , Cmd.none
                        )

                    _ ->
                        noop model


delay : Float -> Msg -> Cmd Msg
delay duration msg =
    Task.perform (always msg) <| Process.sleep duration


port loaded : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loaded <| always Loaded
        ]


view : Model -> Html Msg
view model =
    let
        showTheMap =
            Debug.log (Subway.graphViz (stationInfo >> .name) (lineInfo >> .name) City.fullMap ++ "\n") "Copy and paste in http://viz-js.com/"
    in
    div [ class "game" ] <|
        List.filterMap identity
            [ Just <| gameView model
            , Maybe.map titleCardView model.titleCard
            ]


titleCardView : String -> Html Msg
titleCardView title =
    div [ class "titlecard" ] [ text title ]


gameView : Model -> Html Msg
gameView model =
    let
        currentStation =
            getCurrentStation model

        stationToId station =
            stationInfo station |> .id

        lineToId line =
            lineInfo line |> .number

        config =
            { stationToId = stationToId
            , lineToId = lineToId
            }
    in
    div []
        [ case model.location of
            InStation ->
                stationView
                    currentStation
                    (Subway.connections config model.map currentStation)
                    model.storyLine
                    model.isIntro

            OnTrain (( line, end ) as train) status ->
                -- TODO update to pass in desired stop
                Views.Train.view
                    line
                    end
                    currentStation
                    status
                    (case model.location of
                        OnTrain _ Moving ->
                            False

                        _ ->
                            True
                    )
                    model.isIntro
                    (model.day == Friday)
                    model.storyLine

            InConnectingHalls ->
                connectingHallsView
                    model.map
                    currentStation
        , if model.showMap then
            mapView model.mapImage

          else
            div [ onClick ToggleMap, class "map_toggle" ] [ text "Map" ]
        ]


stationView : Station -> List Line -> Maybe String -> Bool -> Html Msg
stationView currentStation connections storyLine isIntro =
    let
        story storyLine_ =
            div [ class "station__story" ] [ storyView storyLine_ isIntro ]

        exitView =
            div [ class "station__connections", onClick PassTurnStyle ] <|
                [ text "To trains", arrowView 0 ]
    in
    div [ class "station" ] <|
        List.filterMap identity
            [ Just <|
                div [ class "station__top" ] <|
                    [ h2 [ class "station__name" ] [ text (stationInfo currentStation |> .name) ]
                    ]
                        ++ (if isIntro then
                                []

                            else
                                [ exitView ]
                           )
            , Maybe.map story storyLine
            ]


arrowView : Int -> Html Msg
arrowView direction =
    div
        [ class "connection__arrow"
        , style "transform" ("rotate(" ++ String.fromInt direction ++ "deg)")
        ]
        [ text "→" ]


connectingHallsView : Subway.Map City.Station City.Line -> Station -> Html Msg
connectingHallsView map currentStation =
    let
        lineInfoView lineInfo =
            div [ class "line_info" ]
                [ lineNumberView lineInfo
                , text <| .name <| lineInfo
                ]

        lineNumberView lineInfo =
            div
                [ class "station__line"
                , style "color" (toColor lineInfo.color)
                , style "borderColor" (toColor lineInfo.color)
                ]
                [ text <| String.fromInt lineInfo.number ]

        lineConnectionView lineInfo =
            div
                [ class "line_map__stop_connection"
                , style "background" (toColor lineInfo.color)
                ]
                [ text <| String.fromInt lineInfo.number ]

        connections station =
            Subway.connections City.config map station

        stopView currentLine station =
            div [ class "line_map__stop" ] <|
                [ div [ class "line_map__stop_connections" ] <|
                    List.map (City.lineInfo >> lineConnectionView) (List.filter ((/=) currentLine) <| connections station)
                , div
                    [ classList
                        [ ( "station_dot", True )
                        , ( "station_dot--current", station == currentStation )
                        ]
                    , style "borderColor" (toColor <| .color <| lineInfo <| currentLine)
                    ]
                    []
                , div
                    [ classList
                        [ ( "connection_name", True )
                        , ( "connection_name--current", station == currentStation )
                        ]
                    ]
                    [ text <| .name <| stationInfo station ]
                ]

        lineMap line =
            div [ class "line_map" ]
                [ lineInfoView <| City.lineInfo line
                , div [ class "line_map__stops" ] <|
                    [ div
                        [ class "line_map__line"
                        , style "background" (toColor <| .color <| lineInfo <| line)
                        ]
                        []
                    ]
                        ++ List.map (stopView line) (City.lineInfo line |> .stations)
                ]
    in
    div [ class "connecting_halls" ]
        [ div [ class "line_maps" ] <| List.map lineMap <| connections currentStation ]



-- TODO
-- make 2 connecting halls - one with list of lines and arrors (like connections before), one with line map and a back/exit sign
-- in other words, only one line map per screen


storyView : String -> Bool -> Html Msg
storyView storyLine showContinue =
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( storyLine
          , div [ class "StoryLine__content" ] <|
                [ Markdown.toHtml [] storyLine ]
                    ++ (if showContinue then
                            [ span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ] ]

                        else
                            []
                       )
          )
        ]


mapView : String -> Html Msg
mapView mapImage =
    div [ onClick ToggleMap, class "map" ]
        [ pre [ class "map__image", style "fontFamily" "monospace" ]
            [ text <| mapImage ]
        ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> (\{ red, green, blue } -> "rgb(" ++ String.fromInt red ++ "," ++ String.fromInt green ++ "," ++ String.fromInt blue ++ ")")
