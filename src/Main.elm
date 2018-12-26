port module Main exposing (main)

import Browser
import City exposing (..)
import Constants exposing (..)
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
      , location = OnTrain { line = Red, status = InTransit }
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
    model


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


changeTrainStatus : TrainStatus -> TrainProps -> TrainProps
changeTrainStatus newStatus trainProps =
    { trainProps | status = newStatus }


getCurrentStation : City.Map -> Manifest.WorldModel -> Station
getCurrentStation map worldModel =
    Narrative.WorldModel.getLink "player" "location" worldModel
        |> Maybe.andThen String.toInt
        |> Maybe.andThen (Subway.getStation map)
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
                ( { model
                    | selectScene = False

                    -- sort of a hack for a minimal way to get a "custom event" to trigger a rule
                    -- TODO a better way to do this would be to hardcode the list of interactions to "complete" a scene, and fold them into the model
                    , worldModel = applyChanges [ SetStat "selectScene" "jumpToScene" scene ] model.worldModel
                  }
                , delay introDelay (Interact "selectScene")
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

            BoardTrain line station ->
                ( { model
                    | location = OnTrain { line = line, status = InTransit }

                    -- always move to the selected station (you can override this in the rules if needed)
                    , worldModel =
                        Narrative.WorldModel.applyChanges
                            [ SetLink "player" "location" (station |> stationInfo |> .id |> String.fromInt) ]
                            model.worldModel
                  }
                  -- also trigger story rules with station
                , delay departingDelay (Interact (station |> stationInfo |> .id |> String.fromInt))
                )

            Continue ->
                -- note, use scriptedEvents to respond special to Continue's
                case model.location of
                    InStation _ ->
                        ( { model | story = Nothing }, Cmd.none )

                    OnTrain train ->
                        ( { model
                            | location = OnTrain <| changeTrainStatus Arriving train
                            , story = Nothing
                          }
                        , delay arrivingDelay <| Disembark
                        )

            Disembark ->
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
            getCurrentStation map model.worldModel

        map =
            mapLevel
                |> City.mapLines
                |> City.map

        mapLevel =
            Narrative.WorldModel.getStat "player" "mapLevel" model.worldModel
                |> Maybe.withDefault 1

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
                    Hall.view map currentStation

                InStation (Platform line) ->
                    Platform.view map currentStation line

                OnTrain { line, status } ->
                    Views.Train.view
                        { line = line
                        , arrivingAtStation =
                            if status == Arriving then
                                Just currentStation

                            else
                                Nothing
                        }
            , model.story
                |> Maybe.map storyView
                |> Maybe.withDefault (text "")
            , if model.showMap then
                mapView mapLevel

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
            [ li [ onClick <| SelectScene Constants.scenes.intro ] [ text "Beginning" ]
            , li [ onClick <| SelectScene Constants.scenes.lostBriefcase ] [ text "Losing briefcase" ]
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


mapView : Int -> Html Msg
mapView mapLevel =
    div [ onClick ToggleMap, class "map" ]
        [ img [ class "map__image", src <| "img/" ++ City.mapImage mapLevel ] []
        ]
