port module Main exposing (main)

import Browser
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
import Rules.Parser
import Subway exposing (..)
import Task
import Tuple
import Views.Station.CentralGuardOffice as CentralGuardOffice
import Views.Station.Lobby as Lobby
import Views.Station.Platform as Platform
import Views.Station.Turnstile as Turnstile
import Views.Train as Train



{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


type alias Flags =
    { selectScene : Bool }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = \model -> { title = "Subway!", body = [ view model ] }
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( initialWorldModel, entityParseErrors ) =
            Manifest.initialWorldModel

        ruleParseErrors =
            Rules.parseErrors
    in
    ( { worldModel = initialWorldModel
      , parseErrors = entityParseErrors ++ ruleParseErrors
      , loaded = False
      , story = []
      , ruleMatchCounts = Dict.empty
      , scene = Title (dayText initialWorldModel)
      , showMap = False
      , gameOver = False
      , selectScene = flags.selectScene
      , history = []
      , pendingChanges = Nothing
      }
    , Cmd.none
    )


introDelay : Float
introDelay =
    0 * 1000


departingDelay : Float
departingDelay =
    0.8 * 1000


arrivingDelay : Float
arrivingDelay =
    0.9 * 1000


{-| "Ticks" the narrative engine, and displays the story content. Also preps changes
(to be applied when story has finished). Handles cases for a matched rule and no match.
-}
updateStory : String -> Model -> ( Model, Cmd Msg )
updateStory trigger model =
    case Narrative.Rules.findMatchingRule trigger Rules.rules model.worldModel of
        Nothing ->
            let
                ( newStory, newMatchCounts ) =
                    -- TODO might not need this check  (use rules to return empty narrative)
                    if Rules.unsafeAssert (trigger ++ ".silent") model.worldModel then
                        ( [], model.ruleMatchCounts )

                    else
                        Dict.get trigger model.worldModel
                            |> Maybe.map (.description >> parseNarrative model trigger trigger)
                            |> Maybe.withDefault ( [ "ERROR: unablle to find entity for " ++ trigger ], model.ruleMatchCounts )
            in
            -- no need to apply special events or pending changes (no changes,
            -- and no rule id to match).
            ( { model | story = newStory, ruleMatchCounts = newMatchCounts }, Cmd.none )

        Just ( matchedRuleID, matchedRule ) ->
            let
                debug =
                    Debug.log "Matched rule:" matchedRuleID

                ( newStory, newMatchCounts ) =
                    parseNarrative model matchedRuleID trigger matchedRule.narrative
            in
            ( { model
                | pendingChanges = Just ( trigger, matchedRule.changes, matchedRuleID )
                , story = newStory
                , ruleMatchCounts = newMatchCounts
              }
            , Cmd.none
            )
                |> updateAndThen
                    (if List.isEmpty newStory then
                        applyPendingChanges

                     else
                        noop
                    )


parseNarrative model matchedRuleID trigger rawNarrative =
    let
        cycleIndex =
            Dict.get matchedRuleID model.ruleMatchCounts
                |> Maybe.withDefault 0

        replaceTrigger id =
            if id == "$" then
                trigger

            else
                id

        propFn keyword fn =
            ( keyword
            , replaceTrigger
                >> (\id ->
                        Dict.get id model.worldModel
                            |> Maybe.map (fn >> Ok)
                            |> Maybe.withDefault (Err <| "Unable to find entity for id: " ++ id)
                   )
            )

        propKeywords =
            Dict.fromList
                [ propFn "name" .name
                , propFn "description" .description
                ]

        config =
            { cycleIndex = cycleIndex
            , propKeywords = propKeywords
            , trigger = trigger
            , worldModel = model.worldModel
            }

        narrative =
            Narrative.parse config rawNarrative

        newMatchCounts =
            Dict.update
                matchedRuleID
                (\i ->
                    i
                        |> Maybe.map ((+) 1)
                        |> Maybe.withDefault 1
                        |> Just
                )
                model.ruleMatchCounts
    in
    ( narrative, newMatchCounts )


dayText : Manifest.WorldModel -> String
dayText worldModel =
    case getStat "PLAYER" "day" worldModel of
        Just 1 ->
            "Monday morning"

        Just 2 ->
            "Tuesday morning"

        Just 3 ->
            "Wednesday morning"

        Just 4 ->
            "Thursday morning"

        Just 5 ->
            "Friday morning"

        _ ->
            "ERROR can't get PLAYER.day"


{-| Changes the model based on the matched rule id. This shouldn't change fields
based on teh world model or rules (story, pendingChanges, worldModel).

This should run at the same time the model updates from a rule or from pending changes.

Note that this only runs when a rule has matched. In other words, you won't get the
id of an entity as a ruleId to match against.

-}
specialEvents : String -> Model -> ( Model, Cmd Msg )
specialEvents ruleId model =
    case ruleId of
        "checkMap" ->
            ( { model | showMap = not model.showMap }, Cmd.none )

        "goToWorkAndResetToNextDay" ->
            ( { model | scene = Title (dayText model.worldModel) }, Cmd.none )

        "goToLineTurnstile" ->
            ( { model | scene = Turnstile <| Maybe.withDefault Red <| getCurrentLine model.worldModel }, Cmd.none )

        "goToLobby" ->
            ( { model | scene = Lobby }, Cmd.none )

        other ->
            if List.member other [ "goToLinePlatform" ] then
                -- Remember, if you add another matcher to jump the turnstile, remove
                -- the at_turnstile tag!!!!!!!!
                ( { model | scene = Platform <| Maybe.withDefault Red <| getCurrentLine model.worldModel }, Cmd.none )

            else
                ( model, Cmd.none )


noop : Model -> ( Model, Cmd Msg )
noop model =
    ( model, Cmd.none )


changeTrainStatus : TrainStatus -> TrainProps -> TrainProps
changeTrainStatus newStatus trainProps =
    { trainProps | status = newStatus }


getCurrentStation : Manifest.WorldModel -> Station
getCurrentStation worldModel =
    Narrative.WorldModel.getLink "PLAYER" "location" worldModel
        |> Maybe.withDefault "ERROR getting the current location of player from worldmodel"


getCurrentLine : Manifest.WorldModel -> Maybe Subway.Line
getCurrentLine worldModel =
    Narrative.WorldModel.getLink "PLAYER" "line" worldModel
        |> Maybe.andThen Subway.idToLine


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
                , if model.selectScene then
                    Cmd.none

                  else
                    -- doesn't need anything special to start events now (starts at
                    -- title screen)
                    Cmd.none
                )

            LoadScene ( model_, history ) ->
                List.foldl
                    (\id modelTuple ->
                        modelTuple
                            |> updateAndThen (update <| Interact id)
                            |> updateAndThen applyPendingChanges
                    )
                    ( { model_ | selectScene = False }, Cmd.none )
                    history

            Interact interactableId ->
                ( { model | history = model.history ++ [ interactableId ] |> Debug.log "history\n" }
                , Cmd.none
                )
                    |> updateAndThen (updateStory interactableId)

            Delay duration delayedMsg ->
                ( model
                , Task.perform (always delayedMsg) <| Process.sleep duration
                )

            ToggleMap ->
                -- TODO check if allowed to show map (ie. map in inventory, scene lobby, etc)
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            Go area ->
                -- TODO would be best to move all of `model.scene` into the world model, but for now, just duplicate the line color there
                ( { model | scene = area }, Cmd.none )

            BoardTrain line station ->
                ( { model | scene = Train { line = line, status = InTransit } }
                , delay departingDelay (Interact station)
                )

            Continue ->
                -- reduces the story and applies the pending changes when the story
                -- has completed (this avoids having the background change before the
                -- player has finished reading the story)
                if List.length model.story > 1 then
                    ( { model | story = List.drop 1 model.story }, Cmd.none )

                else
                    ( { model | story = [] }, Cmd.none )
                        |> updateAndThen applyPendingChanges
                        |> updateAndThen
                            (\m ->
                                -- special case when riding the train
                                case m.scene of
                                    Train train ->
                                        ( { m | scene = Train <| changeTrainStatus Arriving train }
                                        , delay arrivingDelay <| Disembark
                                        )

                                    _ ->
                                        ( m, Cmd.none )
                            )

            Disembark ->
                ( { model | scene = Lobby }
                , Cmd.none
                )


{-| Applies pending changes and special events. This is used to make sure the view
doesn't change in the background until the story modal has closed.
-}
applyPendingChanges : Model -> ( Model, Cmd Msg )
applyPendingChanges model =
    case model.pendingChanges of
        Just ( trigger, changes, matchedRuleID ) ->
            ( { model
                | worldModel = applyChanges changes trigger model.worldModel
                , pendingChanges = Nothing
              }
            , Cmd.none
            )
                |> updateAndThen (specialEvents matchedRuleID)

        _ ->
            ( model, Cmd.none )


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
    let
        showingTitle =
            case model.scene of
                Title _ ->
                    True

                _ ->
                    False
    in
    if not model.loaded || model.selectScene then
        NoOp

    else
        case key of
            " " ->
                if showingTitle then
                    -- TODO might need to parameterize the Title with a msg
                    Interact "LOBBY"

                else if model.showMap then
                    ToggleMap

                else if not <| List.isEmpty model.story then
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
        currentStation =
            getCurrentStation model.worldModel

        scene =
            if Rules.unsafeAssert "PLAYER.caught" model.worldModel then
                CentralGuardOffice

            else
                model.scene

        map =
            Subway.fullMap
    in
    if not model.loaded then
        div [ class "Loading" ] [ text "Loading..." ]

    else if not <| List.isEmpty model.parseErrors then
        div [ class "SelectScene" ]
            [ h1 [] [ text "Errors when parsing!  Please fix:" ]
            , ul [] <|
                List.map
                    (\( s, e ) ->
                        li []
                            [ h3 [] [ text s ]
                            , text <| Rules.Parser.deadEndsToString e
                            ]
                    )
                    model.parseErrors
            ]

    else if model.selectScene then
        selectSceneView model

    else
        -- keyed so fade in animations play
        Html.Keyed.node "div"
            [ class "game" ]
            [ case scene of
                Title title ->
                    ( "title", titleView title )

                CentralGuardOffice ->
                    ( "centralGuardOffice", CentralGuardOffice.view model.worldModel )

                Lobby ->
                    ( "lobby", Lobby.view map model.worldModel currentStation )

                Platform line ->
                    ( "platform", Platform.view map currentStation line (getLink "PLAYER" "destination" model.worldModel) )

                Turnstile line ->
                    ( "turnstile", Turnstile.view model.worldModel line )

                Train { line, status } ->
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
            , ( "story"
              , model.story
                    |> List.head
                    |> Maybe.withDefault ""
                    |> (\t ->
                            if String.isEmpty t then
                                text ""

                            else
                                storyView t
                       )
              )
            , ( "map"
              , if model.showMap then
                    mapView

                else
                    text ""
              )
            ]


selectSceneView : Model -> Html Msg
selectSceneView model =
    let
        beginning =
            ( model, [] )

        -- lostBriefcase =
        --     ( { model
        --         | scene = Lobby
        --       }
        --     , Tuple.second beginning ++ [ "cellPhone", "cellPhone", "briefcase", "presentation", "redLinePass", "TwinBrooks", "mapPoster", "MetroCenter", "largeCrowd" ]
        --     )
    in
    div [ class "SelectScene" ]
        [ h1 [] [ text "Select a scene to jump to:" ]
        , ul []
            [ li [ onClick <| LoadScene beginning ] [ text "Beginning" ]
            ]
        ]


titleView : String -> Html Msg
titleView title =
    div [ class "Scene TitleScene" ]
        [ div [ class "TitleContent" ]
            [ h1 [ class "Title" ] [ text title ]
            , span [ class "StoryLine__continue", onClick (Interact "LOBBY") ] [ text "Continue..." ]
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


mapView : Html Msg
mapView =
    div [ onClick ToggleMap, class "map" ]
        [ img [ class "map__image", src <| "img/" ++ Subway.mapImage ] []
        ]
