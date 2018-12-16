port module Main exposing (main)

import Browser
import City exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import List.Extra
import LocalTypes exposing (..)
import Manifest
import Markdown
import Narrative
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Process
import Rules
import Subway
import Task
import Tuple
import Views.Station.Hall as Hall
import Views.Station.Lobby as Lobby
import Views.Station.Platform as Platform
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


type alias Model =
    { worldModel : Manifest.WorldModel
    , loaded : Bool
    , story : Maybe String
    , rules : Rules.Rules
    , map : Subway.Map City.Station City.Line
    , mapImage : String
    , location : Location
    , showMap : Bool
    , gameOver : Bool
    , selectScene : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { worldModel = Manifest.worldModel
      , loaded = False
      , story = Nothing
      , rules = Rules.rules
      , map = City.map [ Red ]
      , mapImage = City.mapImage City.RedMap
      , location = OnTrain { line = Red, status = InTransit, desiredStop = TwinBrooks }
      , showMap = False
      , gameOver = False
      , selectScene = True
      }
      -- , delay introDelay (Interact "intro")
    , Cmd.none
    )


introDelay : Float
introDelay =
    3 * 1000


departingDelay : Float
departingDelay =
    1.5 * 1000


arrivingDelay : Float
arrivingDelay =
    1.5 * 1000


{-| "Ticks" the narrative engine, and displays the story content
-}
updateStory : String -> Model -> Model
updateStory trigger model =
    case Narrative.Rules.findMatchingRule trigger model.rules model.worldModel of
        Nothing ->
            let
                default =
                    Dict.get trigger model.worldModel
                        |> Maybe.map .description
            in
            { model | story = default }

        Just ( matchedRuleID, matchedRule ) ->
            let
                ( currentNarrative, updatedNarrative ) =
                    Narrative.update matchedRule.narrative
            in
            { model
                | worldModel = applyChanges matchedRule.changes model.worldModel
                , story = Just currentNarrative
                , rules = Dict.insert matchedRuleID { matchedRule | narrative = updatedNarrative } model.rules
            }
                |> specialEvents matchedRuleID


specialEvents : String -> Model -> Model
specialEvents ruleId model =
    -- TODO maybe this isn't needed, changing the map can be based on the world model
    case ruleId of
        "redirectedToLostAndFound" ->
            { model
                | mapImage = City.mapImage RedYellowMap
                , map = City.map [ Red, Yellow ]
            }

        "endOfDemo" ->
            { model
                | mapImage = City.mapImage RedYellowGreenMap
                , map = City.map [ Red, Yellow, Green ]
            }

        _ ->
            model


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


changeTrainStatus : TrainStatus -> TrainProps -> TrainProps
changeTrainStatus newStatus { line, desiredStop } =
    { line = line, status = newStatus, desiredStop = desiredStop }


getCurrentStation : Model -> Station
getCurrentStation model =
    Narrative.WorldModel.getLink "player" "location" model.worldModel
        |> Maybe.andThen String.toInt
        |> Maybe.andThen (Subway.getStation model.map)
        |> Maybe.withDefault WestMulberry


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    update_ msg model


update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
    if model.gameOver then
        -- no-op if story has ended
        noop model

    else
        case msg of
            NoOp ->
                noop model

            SelectScene scene ->
                ( { model | selectScene = False }
                , delay introDelay (Interact scene)
                )

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

            ToggleMap ->
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            Go area ->
                ( { model | location = InStation area }, Cmd.none )

            BoardTrain line desiredStop ->
                ( { model
                    | location = OnTrain { line = line, status = InTransit, desiredStop = desiredStop }
                    , worldModel =
                        -- this is the only place there should be an Engine.changeWorld call to set the location
                        -- set here instead of Disembark so that the rules can match against currentLocation (which will be the desiredStop)
                        -- TODO maybe change to `Interact desiredStop` after delay and let rules handle move
                        Narrative.WorldModel.applyChanges
                            [ SetLink "player" "location" (desiredStop |> stationInfo |> .id |> String.fromInt) ]
                            model.worldModel
                  }
                , delay departingDelay (Interact "train")
                )

            Continue ->
                -- note, use scriptedEvents to respond special to Continue's
                case model.location of
                    InStation _ ->
                        ( { model | story = Nothing }, Cmd.none )

                    OnTrain ({ desiredStop } as train) ->
                        ( { model
                            | location = OnTrain <| changeTrainStatus Arriving train
                            , story = Nothing
                          }
                        , delay arrivingDelay <| Disembark desiredStop
                        )

            Disembark station ->
                ( { model
                    | location = InStation Lobby
                    , story = Nothing
                  }
                , Cmd.none
                )


delay : Float -> Msg -> Cmd Msg
delay duration msg =
    Task.perform (always msg) <| Process.sleep duration


port loaded : (Bool -> msg) -> Sub msg


port keyPress : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loaded <| always Loaded
        , keyPress <| handleKey model
        ]


handleKey : Model -> String -> Msg
handleKey model key =
    case key of
        " " ->
            if model.story /= Nothing then
                Continue

            else
                NoOp

        "m" ->
            ToggleMap

        _ ->
            NoOp


view : Model -> Html Msg
view model =
    let
        --     showTheMap =
        --         Debug.log (Subway.graphViz (stationInfo >> .name) (lineInfo >> .name) City.fullMap ++ "\n") "Copy and paste in http://viz-js.com/"
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
    if not model.loaded then
        div [ class "Loading" ] [ text "Loading..." ]

    else if model.selectScene then
        selectSceneView

    else
        div [ class "game" ]
            [ case model.location of
                InStation Lobby ->
                    Lobby.view model.worldModel currentStation

                InStation Hall ->
                    Hall.view model.map currentStation

                InStation (Platform line) ->
                    Platform.view model.map currentStation line

                OnTrain { line, status, desiredStop } ->
                    Views.Train.view
                        { line = line
                        , arrivingAtStation =
                            if status == Arriving then
                                Just desiredStop

                            else
                                Nothing
                        }
            , model.story
                |> Maybe.map storyView
                |> Maybe.withDefault (text "")
            , if model.showMap then
                mapView model.mapImage

              else
                case model.location of
                    InStation _ ->
                        div [ onClick ToggleMap, class "map_toggle" ] [ text "Map" ]

                    _ ->
                        text ""
            ]


selectSceneView : Html Msg
selectSceneView =
    div [ class "SelectScene" ]
        [ h1 [] [ text "Select a scene to jump to:" ]
        , ul []
            [ li [ onClick <| SelectScene "beginning" ] [ text "Beginning" ]
            , li [ onClick <| SelectScene "lostBriefcase" ] [ text "Losing briefcase" ]
            ]
        ]


storyView : String -> Html Msg
storyView story =
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( story
          , div [ class "StoryLine__content" ]
                [ Markdown.toHtml [] story
                , span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ]
                ]
          )
        ]


mapView : String -> Html Msg
mapView mapImage =
    div [ onClick ToggleMap, class "map" ]
        [ img [ class "map__image", src <| "img/" ++ mapImage ] []
        ]
