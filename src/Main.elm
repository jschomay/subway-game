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
import Views.CharacterInfo as CharacterInfo
import Views.Station.CentralGuardOffice as CentralGuardOffice
import Views.Station.Lobby as Lobby
import Views.Station.Platform as Platform
import Views.Train as Train



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
    , rules : LocalTypes.Rules
    , location : Location
    , showMap : Bool
    , showCharacterInfo : Bool
    , gameOver : Bool
    , selectScene : Bool
    , history : List String
    , pendingChanges : List ChangeWorld
    }


init : ( Model, Cmd Msg )
init =
    ( { worldModel = Manifest.worldModel
      , loaded = False
      , story = Nothing
      , rules = Rules.rules
      , location = InStation Lobby

      -- after removing scene select:
      -- , location = OnTrain { line = Red, status = InTransit }
      , showMap = False
      , showCharacterInfo = False
      , gameOver = False
      , selectScene = True
      , history = []
      , pendingChanges = []
      }
      -- after removing scene select:
      -- actually, this should happen in the Loaded Msg handling
      -- , delay introDelay (Interact "player")
    , Cmd.none
    )


introDelay : Float
introDelay =
    3 * 1000


departingDelay : Float
departingDelay =
    0.5 * 1000


arrivingDelay : Float
arrivingDelay =
    0.5 * 1000


{-| "Ticks" the narrative engine, and displays the story content
-}
updateStory : String -> Model -> Model
updateStory trigger model =
    case Narrative.Rules.findMatchingRule trigger model.rules model.worldModel of
        Nothing ->
            let
                defaultChanges =
                    defaultUpdate trigger model.worldModel

                default =
                    Dict.get trigger model.worldModel
                        |> Maybe.map .description
            in
            { model
                | story = default
                , pendingChanges = defaultChanges
            }

        Just ( matchedRuleID, matchedRule ) ->
            let
                defaultChanges =
                    defaultUpdate trigger model.worldModel

                ( currentNarrative, updatedNarrative ) =
                    Narrative.update matchedRule.narrative
            in
            { model
              -- make sure rule changes are second so that they can overrite default changes if needed
                | pendingChanges = defaultChanges ++ matchedRule.changes
                , story = Just currentNarrative
                , rules = Dict.insert matchedRuleID { matchedRule | narrative = updatedNarrative } model.rules
            }
                |> specialEvents matchedRuleID


specialEvents : String -> Model -> Model
specialEvents ruleId model =
    model


{-| Sometimes you need to react to an interaction regardless of which rule matches. For example, things like moving to a locaiton, or taking an item.
This happens before `updateStory`, so you can always override these changes in the rules if need.
Warning, this should be used sparingly!
-}
defaultUpdate : String -> Manifest.WorldModel -> List ChangeWorld
defaultUpdate interactableId worldModel =
    if assert interactableId [ HasTag "station" ] worldModel then
        -- move to selected station
        [ SetLink "player" "location" interactableId ]

    else
        []


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


updateAndThen : (m -> ( m, Cmd c )) -> ( m, Cmd c ) -> ( m, Cmd c )
updateAndThen f ( model, cmds ) =
    f model |> Tuple.mapSecond (\cmd -> Cmd.batch [ cmd, cmds ])


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    if model.gameOver then
        -- no-op if story has ended
        noop model

    else
        case msg of
            NoOp ->
                noop model

            Loaded ->
                ( { model | loaded = True }
                , Cmd.none
                )

            LoadScene history ->
                List.foldl
                    (\id modelTuple ->
                        modelTuple
                            |> updateAndThen (update <| Interact id)
                            |> updateAndThen
                                (\m ->
                                    ( { m
                                        | pendingChanges = []
                                        , worldModel = applyChanges m.pendingChanges m.worldModel
                                      }
                                    , Cmd.none
                                    )
                                )
                    )
                    ( { model | selectScene = False }, Cmd.none )
                    history

            Interact interactableId ->
                ( { model | history = model.history ++ [ interactableId ] |> Debug.log "history\n" }
                    |> updateStory interactableId
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

            ToggleCharacterInfo ->
                ( { model | showCharacterInfo = not model.showCharacterInfo }
                , Cmd.none
                )

            Go area ->
                ( { model | location = InStation area }, Cmd.none )

            BoardTrain line station ->
                ( { model | location = OnTrain { line = line, status = InTransit } }
                , delay departingDelay (Interact (station |> stationInfo |> .id |> String.fromInt))
                )

            Continue ->
                (case model.location of
                    InStation _ ->
                        ( model, Cmd.none )

                    CentralGuardOffice ->
                        ( model, Cmd.none )

                    OnTrain train ->
                        ( { model | location = OnTrain <| changeTrainStatus Arriving train }
                        , delay arrivingDelay <| Disembark
                        )
                )
                    |> updateAndThen
                        (\m ->
                            ( { m
                                | worldModel = applyChanges model.pendingChanges model.worldModel
                                , pendingChanges = []
                                , story = Nothing
                              }
                            , Cmd.none
                            )
                        )

            Disembark ->
                ( { model | location = InStation Lobby }
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

        "c" ->
            ToggleCharacterInfo

        _ ->
            NoOp


view : Model -> Html Msg
view model =
    let
        --     showTheMap =
        --         Debug.log (Subway.graphViz (stationInfo >> .name) (lineInfo >> .name) City.fullMap ++ "\n") "Copy and paste in http://viz-js.com/"
        currentStation =
            getCurrentStation map model.worldModel

        location =
            if assert "player" [ HasTag "caught" ] model.worldModel then
                CentralGuardOffice

            else
                model.location

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
        -- keyed so fade in animations play
        Html.Keyed.node "div"
            [ class "game" ]
            [ case location of
                CentralGuardOffice ->
                    ( "centralGuardOffice", CentralGuardOffice.view model.worldModel )

                InStation Lobby ->
                    ( "lobby", Lobby.view map model.worldModel currentStation )

                InStation (Platform line) ->
                    ( "platform", Platform.view map currentStation line )

                OnTrain { line, status } ->
                    ( "train"
                    , Train.view
                        { line = line
                        , arrivingAtStation =
                            if status == Arriving then
                                Just currentStation

                            else
                                Nothing
                        }
                    )
            , ( "toggles"
              , case model.location of
                    InStation _ ->
                        div [ class "toggles" ]
                            [ div [ onClick ToggleMap, class "toggle" ] [ text "Map (M)" ]
                            , div [ onClick ToggleCharacterInfo, class "toggle" ] [ text "Character (C)" ]
                            ]

                    _ ->
                        text ""
              )
            , ( "characterInfoView"
              , if model.showCharacterInfo then
                    CharacterInfo.view model.worldModel

                else
                    text ""
              )
            , ( "map"
              , if model.showMap then
                    mapView mapLevel

                else
                    text ""
              )
            , ( "story"
              , model.story
                    |> Maybe.map storyView
                    |> Maybe.withDefault (text "")
              )
            ]


selectSceneView : Html Msg
selectSceneView =
    let
        beginning =
            [ "player" ]

        lostBriefcase =
            beginning ++ [ "1", "largeCrowd" ]

        centralGuardOffice =
            lostBriefcase ++ [ "2", "policeOffice", "3" ]
    in
    div [ class "SelectScene" ]
        [ h1 [] [ text "Select a scene to jump to:" ]
        , ul []
            [ li [ onClick <| LoadScene beginning ] [ text "Beginning" ]
            , li [ onClick <| LoadScene lostBriefcase ] [ text "Losing briefcase" ]
            , li [ onClick <| LoadScene centralGuardOffice ] [ text "In the central guard office" ]
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
