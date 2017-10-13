port module Main exposing (..)

import Engine exposing (..)
import Manifest
import Rules
import List.Extra
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
import FNV


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
    , safeToExit : Bool
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
                (Dict.map (curry getRuleData) Rules.rules)
                |> Engine.changeWorld Rules.startingState
    in
        ( { engineModel = engineModel
          , loaded = False
          , storyLine = Nothing
          , narrativeContent = Dict.map (curry getNarrative) Rules.rules
          , map = City.map [ City.redLine ]
          , mapImage = City.mapImage City.RedMap
          , location = OnPlatform ( Red, TwinBrooks )
          , safeToExit = False
          , isIntro = True
          , titleCard = Just "Monday 6:03 AM"
          , day = Monday
          , showMap = False
          }
            |> updateStory "nextDay"
        , delay titleCardDelay RemoveTitleCard
        )


titleCardDelay : Time
titleCardDelay =
    --3
    1 * 1000


transitDelay : Time
transitDelay =
    -- 8
    1 * 1000


platformDelay : Time
platformDelay =
    --3
    1 * 1000


doorDelay : Time
doorDelay =
    0.5 * 1000


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
        OnTrain train status ->
            OnTrain train newStatus

        other ->
            other


{-| Use when you need to manually change the Model outside of the normal subway mechanics.

   Tip: use the event name as a discrete string for updateStory, then you can set the scene, location, etc of the EngineModel via the usual Engine rules instead of with Engine.changeWorld

   ** Don't forget to call `updateStory` to get the right narrative based on your changes, but be careful not to call it twice (if it was already called in `update`)

   ** Dont' forget to pass through or batch in the cmd if unless you know you want to cancel it
-}
scriptedEvents : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
scriptedEvents msg ( model, cmd ) =
    case ( Engine.getCurrentScene model.engineModel, msg ) of
        ( "meetSteve", Continue ) ->
            case ( model.isIntro, model.day, model.location ) of
                ( True, _, OnPlatform _ ) ->
                    -- board train to work (via the Msg)
                    ( model
                    , delay 0 <| BoardTrain
                    )

                ( True, Friday, OnTrain _ _ ) ->
                    noop model

                ( True, _, OnTrain train _ ) ->
                    -- jump to next day
                    ( { model
                        | location = OnPlatform ( Red, TwinBrooks )
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
                | location = OnPlatform ( Red, TwinBrooks )
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
                    , safeToExit = True
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
                , safeToExit = True
                , map = City.map [ City.redLine, City.yellowLine ]
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
        |> Result.toMaybe
        |> Maybe.andThen (Subway.getStation model.map)
        |> Maybe.withDefault WestMulberry


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    update_ msg model
        |> scriptedEvents msg


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

            Delay duration msg ->
                ( model
                , Task.perform (always msg) <| Process.sleep duration
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

            BoardTrain ->
                case model.location of
                    OnPlatform train ->
                        let
                            currentStation =
                                getCurrentStation model

                            cmd =
                                case Subway.nextStop model.map train (stationInfo currentStation |> .id) of
                                    Nothing ->
                                        Cmd.none

                                    Just station ->
                                        delay 0 <| LeaveStation
                        in
                            ( { model
                                | location = OnTrain train Stopped
                                , safeToExit = False
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
                            ( { model | location = OnPlatform train } |> updateStory "platform", Cmd.none )

                        OnTrain train OutOfService ->
                            ( { model | location = OnPlatform train } |> updateStory "platform", Cmd.none )

                        _ ->
                            noop model

            EnterPlatform train ->
                let
                    currentStation =
                        getCurrentStation model
                in
                    case model.location of
                        InConnectingHalls ->
                            ( { model | location = OnPlatform train }, Cmd.none )

                        _ ->
                            noop model

            ExitPlatform ->
                let
                    currentStation =
                        getCurrentStation model
                in
                    case model.location of
                        OnPlatform _ ->
                            ( { model | location = InConnectingHalls }, Cmd.none )

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
                                    [ Engine.moveTo (newStation |> stationInfo |> .id |> toString) ]
                                    model.engineModel
                          }
                        , Cmd.batch
                            [ delay platformDelay LeaveStation
                            , delay doorDelay SafeToExit
                            ]
                        )

                    _ ->
                        noop model

            SafeToExit ->
                ( { model | safeToExit = True }, Cmd.none )

            LeaveStation ->
                let
                    currentStation =
                        getCurrentStation model
                in
                    case model.location of
                        OnTrain train Stopped ->
                            case Subway.nextStop model.map train (stationInfo currentStation |> .id) of
                                Nothing ->
                                    noop model

                                Just next ->
                                    ( { model
                                        | location = changeTrainStatus Moving model.location
                                        , safeToExit = False
                                      }
                                    , delay transitDelay <| ArriveAtStation next
                                    )

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
        ]


view : Model -> Html Msg
view model =
    -- Debug.log (Subway.graphViz City.mapRedYellow ++ "\n") "Copy and paste in http://viz-js.com/" |> \_ ->
    div [ class "game" ]
        [ case model.titleCard of
            Nothing ->
                gameView model

            Just title ->
                titleCardView title
        ]


titleCardView : String -> Html Msg
titleCardView title =
    div [ class "titlecard" ] [ text title ]


gameView : Model -> Html Msg
gameView model =
    let
        currentStation =
            getCurrentStation model
    in
        div []
            [ case model.location of
                InStation ->
                    text "In the station..."

                OnPlatform train ->
                    platformView
                        currentStation
                        train
                        (Subway.connections model.map (stationInfo currentStation |> .id))
                        (Subway.nextStop model.map train (stationInfo currentStation |> .id))
                        model.storyLine
                        model.isIntro

                OnTrain (( line, end ) as train) status ->
                    trainView
                        line
                        end
                        currentStation
                        (Subway.nextStop model.map train (stationInfo currentStation |> .id))
                        status
                        model.safeToExit
                        model.isIntro
                        model.storyLine

                InConnectingHalls ->
                    connectingHallsView
                        currentStation
                        (Subway.connections model.map (stationInfo currentStation |> .id))
            , if model.showMap then
                mapView model.mapImage
              else
                div [ onClick ToggleMap, class "map_toggle" ] [ text "Map" ]
            ]


platformView : Station -> Train -> List ( Line, Station ) -> Maybe Station -> Maybe String -> Bool -> Html Msg
platformView station (( line, direction ) as train) connections nextStop storyLine isIntro =
    let
        storyEl =
            case storyLine of
                Just story ->
                    [ div [ class "platform__story" ] [ storyView story isIntro ] ]

                Nothing ->
                    []

        lineView =
            let
                lineInfo =
                    City.lineInfo line
            in
                div [ class "platform__train", onClick BoardTrain ]
                    [ div
                        [ class "connection__number"
                        , style [ ( "color", toColor lineInfo.color ), ( "borderColor", toColor lineInfo.color ) ]
                        ]
                        [ text <| toString lineInfo.number ]
                    , div [ class "connection__direction" ] [ text <| "towards " ++ (stationInfo direction |> .name) ]
                    ]

        connectionView (( line, end ) as connection) =
            let
                lineInfo =
                    City.lineInfo line
            in
                div
                    [ class "platform__line"
                    , style [ ( "color", toColor lineInfo.color ), ( "borderColor", toColor lineInfo.color ) ]
                    ]
                    [ text <| toString lineInfo.number ]

        lineNumber ( line, _ ) =
            lineInfo line |> .number

        exitView =
            div [ class "platform__exit", onClick ExitPlatform ] <|
                text "Exit & connections"
                    :: (connections
                            |> List.Extra.uniqueBy lineNumber
                            |> List.sortBy lineNumber
                            |> List.map connectionView
                       )
                    ++ [ arrowView station train ]
    in
        div [ class "platform" ] <|
            storyEl
                ++ [ div [ class "platform__platform_info" ] <|
                        [ h2 [ class "platform__name" ] [ text (stationInfo station |> .name) ]
                        , exitView
                        ]
                            ++ case nextStop of
                                Nothing ->
                                    []

                                Just _ ->
                                    [ lineView ]
                   ]


arrowView : Station -> ( Line, Station ) -> Html Msg
arrowView station ( line, end ) =
    let
        lineName =
            City.lineInfo line |> .name

        endName =
            City.stationInfo end |> .name

        stationName =
            City.stationInfo station |> .name

        direction =
            -- 45% from -90 to +90 (90 = up)
            (FNV.hashString (stationName ++ lineName ++ endName) % 5) * 45 - 180
    in
        div
            [ class "connection__arrow"
            , style [ ( "transform", "rotate(" ++ toString direction ++ "deg)" ) ]
            ]
            [ text "→" ]


connectingHallsView : Station -> List ( Line, Station ) -> Html Msg
connectingHallsView station connections =
    let
        connectionView (( line, end ) as connection) =
            let
                lineInfo =
                    City.lineInfo line
            in
                li [ class "connection", onClick <| EnterPlatform connection ]
                    [ div
                        [ class "connection__number"
                        , style [ ( "color", toColor lineInfo.color ), ( "borderColor", toColor lineInfo.color ) ]
                        ]
                        [ text <| toString lineInfo.number ]
                    , div [ class "connection__direction" ]
                        [ text (stationInfo end |> .name) ]
                    , arrowView station connection
                    ]
    in
        div [ class "connecting_halls" ]
            [ ul [ class "connections" ]
                (connections
                    |> List.sortBy (\( line, _ ) -> lineInfo line |> .number)
                    |> List.map connectionView
                )
            ]


storyView : String -> Bool -> Html Msg
storyView storyLine showContinue =
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( storyLine
          , div [ class "StoryLine__content" ] <|
                [ Markdown.toHtml [] storyLine ]
                    ++ if showContinue then
                        [ span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ] ]
                       else
                        []
          )
        ]


trainView : Line -> Station -> Station -> Maybe Station -> TrainStatus -> Bool -> Bool -> Maybe String -> Html Msg
trainView line end currentStation nextStation status isStopped isIntro storyLine =
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

                ( OutOfService, Just next ) ->
                    "Out of service: " ++ (stationInfo currentStation |> .name)

                ( OutOfService, Nothing ) ->
                    "Out of service"

        info =
            (lineInfo line |> .name) ++ " towards " ++ (stationInfo end |> .name)

        buttonClasses =
            classList
                [ ( "exit_button", True )
                , ( "exit_button--active", isStopped )
                ]

        action =
            if isStopped then
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

        storyEl =
            case storyLine of
                Just storyLine ->
                    [ div [ class "train__story" ] [ storyView storyLine isIntro ] ]

                Nothing ->
                    []
    in
        div [ class "platform" ] <|
            storyEl
                ++ [ div [ class "train__ticker" ]
                        [ h4 [ class "train__info" ] [ text info ]
                        , h3 [ class "train__next_stop" ] [ text nextStop ]
                        ]
                   ]
                ++ exitButton


mapView : String -> Html Msg
mapView mapImage =
    div [ onClick ToggleMap, class "map" ]
        [ pre [ class "map__image", style [ ( "fontFamily", "monospace" ) ] ]
            [ text <| mapImage ]
        ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> \{ red, green, blue } -> "rgb(" ++ toString red ++ "," ++ toString green ++ "," ++ toString blue ++ ")"
