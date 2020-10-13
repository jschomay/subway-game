port module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Json.Decode as Json
import List.Extra
import LocalTypes exposing (..)
import Manifest
import Markdown
import NarrativeContent
import NarrativeEngine.Core.Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Debug as Debug
import NarrativeEngine.Syntax.Helpers exposing (parseErrorsView)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser exposing (Narrative)
import Process
import Rules
import Set
import Subway exposing (..)
import Task
import Tuple
import Views.NoteBook as NoteBook
import Views.Station.CentralGuardOffice as CentralGuardOffice
import Views.Station.Lobby as Lobby
import Views.Station.Passageway as Passageway
import Views.Station.Platform as Platform
import Views.Station.Turnstile as Turnstile
import Views.Train as Train



{- This is the kernel of the whole app.  It glues everything together and handles some logic such as choosing the correct narrative to display.
   You shouldn't need to change anything in this file, unless you want some kind of different behavior.
-}


type alias Flags =
    { debug : Bool }


defaultFlags : Flags
defaultFlags =
    { debug = False }


main : Program Flags Model Msg
main =
    -- This does all parsing up front.  If there are errors, a different view is displayed.
    let
        parsedData =
            Result.map3 (\initialWorldModel narrative rules -> ( initialWorldModel, rules ))
                Manifest.initialWorldModel
                NarrativeContent.parseAll
                Rules.rules
    in
    Browser.document
        { init =
            parsedData
                |> Result.map Tuple.first
                |> Result.withDefault Dict.empty
                |> init
        , view =
            \model ->
                case parsedData of
                    Ok _ ->
                        { title = "Subway!", body = [ view model ] }

                    Err errors ->
                        -- Just show the errors, model is ignored
                        { title = "Errors found", body = [ parseErrorsView errors ] }
        , update =
            parsedData
                |> Result.map Tuple.second
                |> Result.withDefault Dict.empty
                |> update
        , subscriptions = subscriptions
        }


init : Manifest.WorldModel -> Flags -> ( Model, Cmd Msg )
init initialWorldModel flags =
    let
        debugState =
            if flags.debug then
                Just Debug.init

            else
                Nothing
    in
    ( { worldModel = initialWorldModel
      , loaded = False
      , persistKey = ""
      , story = NarrativeContent.t "title_intro" |> String.split "---"
      , ruleMatchCounts = Dict.empty
      , scene = MainTitle
      , showMap = False
      , showNotebook = False
      , noteBookPage = Goals
      , showTranscript = False
      , gameOver = False
      , debugState = debugState
      , showSelectScene = flags.debug
      , history = []
      , transcript = []
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
    3 * 1000


achievementDelay : Float
achievementDelay =
    0.3 * 1000


disembarkStoryDelay : Float
disembarkStoryDelay =
    0.5 * 1000


passagewayDelay : Float
passagewayDelay =
    1.6 * 1000


{-| "Ticks" the narrative engine, and displays the story content. Also preps changes
(to be applied when story has finished). Handles cases for a matched rule and no match.
-}
updateStory : LocalTypes.Rules -> String -> Model -> ( Model, Cmd Msg )
updateStory rules trigger model =
    case findMatchingRule trigger rules model.worldModel of
        Nothing ->
            let
                ( newStory, newMatchCounts ) =
                    -- TODO might not need this check  (use rules to return empty narrative)
                    if Rules.unsafeAssert (trigger ++ ".silent") model.worldModel then
                        ( [], model.ruleMatchCounts )

                    else
                        NarrativeContent.t trigger
                            |> parseNarrative model trigger trigger

                newDebugState =
                    Maybe.map (Debug.setLastMatchedRuleId "no matching rule" >> Debug.setLastInteractionId trigger) model.debugState
            in
            -- no need to apply special events or pending changes (no changes,
            -- and no rule id to match).
            ( { model
                | story = newStory
                , ruleMatchCounts = newMatchCounts
                , debugState = newDebugState
              }
            , Cmd.none
            )
                |> updateAndThen (specialEvents rules trigger)

        Just ( matchedRuleID, matchedRule ) ->
            let
                newDebugState =
                    Maybe.map (Debug.setLastMatchedRuleId matchedRuleID >> Debug.setLastInteractionId trigger) model.debugState

                ( newStory, newMatchCounts ) =
                    parseNarrative model matchedRuleID trigger (NarrativeContent.t matchedRuleID)
            in
            ( { model
                | pendingChanges = Just ( trigger, matchedRule.changes, matchedRuleID )
                , story = newStory
                , debugState = newDebugState
                , ruleMatchCounts = newMatchCounts
              }
            , Cmd.none
            )
                |> updateAndThen
                    (if List.isEmpty newStory then
                        applyPendingChanges rules

                     else
                        noop
                    )


parseNarrative : Model -> RuleID -> ID -> String -> ( Narrative, Dict String Int )
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

        propKeywords =
            Dict.fromList
                [ ( "name"
                  , replaceTrigger
                        >> (\id ->
                                Dict.get id model.worldModel
                                    |> Result.fromMaybe ("Unable to find entity for id: " ++ id)
                                    |> Result.map .name
                           )
                  )
                , ( "description", replaceTrigger >> NarrativeContent.t >> Ok )
                , ( "format_amount"
                  , replaceTrigger
                        >> (\id ->
                                getStat id "amount" model.worldModel
                                    |> Maybe.map
                                        (\n ->
                                            "$"
                                                ++ (String.fromInt <| n // 100)
                                                ++ "."
                                                ++ (case modBy 100 n of
                                                        0 ->
                                                            "00"

                                                        rem ->
                                                            String.fromInt rem
                                                   )
                                        )
                                    |> Result.fromMaybe ("Error looking up 'amount' stat on " ++ id)
                           )
                  )
                ]

        config =
            { cycleIndex = cycleIndex
            , propKeywords = propKeywords
            , trigger = trigger
            , worldModel = model.worldModel
            }

        narrative =
            NarrativeParser.parse config rawNarrative

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
specialEvents : LocalTypes.Rules -> String -> Model -> ( Model, Cmd Msg )
specialEvents rules ruleId model =
    case ruleId of
        "notebookInstructions" ->
            ( { model | showNotebook = True }, Cmd.none )

        "NOTEBOOK" ->
            ( { model | showNotebook = not model.showNotebook }, Cmd.none )

        "checkMap" ->
            ( { model | showMap = not model.showMap }, Cmd.none )

        "goToLobby" ->
            ( { model | scene = Lobby }, Cmd.none )

        -- achievements
        "get_caffeinated_quest_2" ->
            delay rules achievementDelay (Achievement "get_caffeinated_quest_achievement") model

        "ratty_hat_man_advice_5" ->
            delay rules achievementDelay (Achievement "fools_errand_achievement") model

        "meetConductorFirstTime" ->
            ( { model | scene = Lobby }, Cmd.none )
                |> updateAndThen (delay rules achievementDelay (Achievement "transfer_station"))

        "jumpTurnstileFortySecondStreet" ->
            ( { model | scene = End }, Cmd.none )
                |> updateAndThen (delay rules achievementDelay (Achievement "freedom"))

        "pourSodaOnInfractionsMachine" ->
            delay rules achievementDelay (Achievement "f_the_system") model

        "fallAsleep" ->
            ( model, stopSound "piano2" )

        "briefcaseStolen" ->
            ( model, playSound "song_long" )

        "nextDay" ->
            ( { model | scene = Lobby }
            , if model.scene == Title "Monday morning" then
                Cmd.batch
                    [ playSound "subway_ambient_loop"
                    , Process.sleep 2000 |> Task.perform (always <| PlaySound "piano2")
                    , Process.sleep 8000 |> Task.perform (always <| SubwaySounds)
                    ]

              else
                Cmd.none
            )

        other ->
            if List.member other [ "use_secret_passage_way", "chaseThiefAgain" ] then
                ( { model | scene = Passageway }, Cmd.none )
                    |> updateAndThen (delay rules passagewayDelay Disembark)

            else if List.member other [ "goToLineTurnstile", "followSkaterDudeToOrangeLine" ] then
                -- Remember to add line=LINE_[X] when adding rules to this match!!!
                ( { model | scene = Turnstile <| Maybe.withDefault Red <| getCurrentLine model.worldModel }, Cmd.none )

            else if List.member other [ "goToLinePlatform", "jumpTurnstileWithSkaterDude", "jumpTurnstileAfterTaklingToMark" ] then
                -- Remember, if you add another matcher to jump the turnstile, remove
                -- the at_turnstile tag!!!!!!!!
                ( { model | scene = Platform <| Maybe.withDefault Red <| getCurrentLine model.worldModel }, Cmd.none )

            else if List.member other [ "caughtOnOrangeLineHeadingTo73rd", "caughtOnOrangeLineHeadingToOther" ] then
                ( { model | scene = CentralGuardOffice }, Cmd.none )

            else if List.member other [ "endMonday", "endTuesday", "endWednesday", "endThursday" ] then
                ( { model | scene = Title (dayText model.worldModel) }, Cmd.none )

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
    getLink "PLAYER" "location" worldModel
        |> Maybe.withDefault "ERROR getting the current location of player from worldmodel"


getCurrentLine : Manifest.WorldModel -> Maybe Subway.Line
getCurrentLine worldModel =
    getLink "PLAYER" "line" worldModel
        |> Maybe.andThen Subway.idToLine


updateAndThen : (m -> ( m, Cmd c )) -> ( m, Cmd c ) -> ( m, Cmd c )
updateAndThen f ( model, cmds ) =
    f model |> Tuple.mapSecond (\cmd -> Cmd.batch [ cmd, cmds ])


update : LocalTypes.Rules -> Msg -> Model -> ( Model, Cmd Msg )
update rules msg model =
    if model.gameOver then
        -- no-op if story has ended
        noop model

    else
        case msg of
            NoOp ->
                noop model

            Persist ListSaves ->
                ( model, persistListReq () )

            Persist (Load k) ->
                ( { model | loaded = False }, persistLoadReq k )

            Persist (Save k v) ->
                ( model, persistSaveReq ( k, v ) )

            Persist (Delete k) ->
                ( model, persistDeleteReq k )

            Persist (ExistingSaves ( currTime, saves )) ->
                ( { model | noteBookPage = SavedGames saves, persistKey = currTime }, Cmd.none )

            Persist (PersistKeyUpdate key) ->
                ( { model | persistKey = key }, Cmd.none )

            Loaded ->
                ( { model | loaded = True }, Cmd.none )

            LoadScene history ->
                -- TODO maybe this can use a recursive `Process.sleep 0 (Replay id)` to create debuggable history
                List.foldl
                    (\id modelTuple ->
                        modelTuple
                            |> updateAndThen (update rules <| Interact id)
                            |> updateAndThen (applyPendingChanges rules)
                    )
                    ( init (Manifest.initialWorldModel |> Result.withDefault Dict.empty) { debug = model.debugState /= Nothing } |> Tuple.first, Cmd.none )
                    history
                    |> updateAndThen
                        (\m ->
                            -- Ensure the UI is in the right place after all interactions
                            ( { m
                                | showSelectScene = False
                                , showMap = False
                                , loaded = True
                                , showNotebook = False
                                , scene =
                                    case m.scene of
                                        Train _ ->
                                            Lobby

                                        Turnstile _ ->
                                            Lobby

                                        Platform _ ->
                                            Lobby

                                        other ->
                                            other
                                , story =
                                    case m.scene of
                                        MainTitle ->
                                            m.story

                                        other ->
                                            []
                              }
                              -- start ambiant sounds
                            , Cmd.batch
                                [ playSound "subway_ambient_loop"
                                , Process.sleep 8000 |> Task.perform (always <| SubwaySounds)
                                ]
                            )
                        )

            Interact interactableId ->
                ( { model | history = model.history ++ [ interactableId ] }
                , Cmd.none
                )
                    |> updateAndThen (updateStory rules interactableId)
                    |> updateAndThen
                        (\m ->
                            if m.debugState == Nothing then
                                ( m, Cmd.none )

                            else
                                ( { m | transcript = m.transcript ++ (interactableId :: m.story) }, Cmd.none )
                        )
                    |> updateAndThen
                        -- Need to continue automaticaly when riding on the train if
                        -- there is no story, otherwise the train never arrives
                        (\m ->
                            case ( m.scene, m.story ) of
                                ( Train _, [] ) ->
                                    delay rules arrivingDelay Continue m

                                _ ->
                                    ( m, Cmd.none )
                        )

            ToggleNotebook ->
                if Rules.unsafeAssert "NOTEBOOK.!new" model.worldModel then
                    ( { model | showNotebook = not model.showNotebook }
                    , Cmd.none
                    )

                else
                    ( model, Cmd.none )

            ToggleNotebookPage page ->
                ( { model | noteBookPage = page }, Cmd.none )

            ToggleMap ->
                if Rules.unsafeAssert "MAP.location=PLAYER" model.worldModel then
                    ( { model | showMap = not model.showMap }
                    , Cmd.none
                    )

                else
                    ( model, Cmd.none )

            ToggleTranscript ->
                ( { model | showTranscript = not model.showTranscript }
                , Cmd.none
                )

            BoardTrain line station ->
                ( { model | scene = Train { line = line, status = InTransit } }
                , Cmd.batch
                    [ playSound "subway_departure"
                    , playSound "subway_whistle"
                    ]
                )
                    |> updateAndThen (delay rules departingDelay (Interact station))

            Continue ->
                -- reduces the story and applies the pending changes when the story
                -- has completed (this avoids having the background change before the
                -- player has finished reading the story)
                if List.length model.story > 1 then
                    ( { model | story = List.drop 1 model.story }, Cmd.none )

                else
                    ( { model | story = [] }, Cmd.none )
                        |> updateAndThen (applyPendingChanges rules)
                        |> updateAndThen
                            (\m ->
                                -- handle continue by scene
                                case m.scene of
                                    Train train ->
                                        ( { m | scene = Train <| changeTrainStatus Arriving train }, Cmd.none )
                                            |> updateAndThen (delay rules arrivingDelay Disembark)

                                    MainTitle ->
                                        ( { m | scene = Splash }
                                        , Cmd.batch
                                            [ playSound "subway_departure"
                                            , Process.sleep 2000 |> Task.perform (always <| PlaySound "subway_whistle")
                                            ]
                                        )

                                    Splash ->
                                        ( { m | scene = Title <| dayText m.worldModel }
                                        , stopSound "subway_departure"
                                        )

                                    Title _ ->
                                        ( m, stopSound "subway_departure" )

                                    _ ->
                                        ( m, Cmd.none )
                            )

            PlaySound key ->
                ( model, playSound key )

            StopSound key ->
                ( model, stopSound key )

            SubwaySounds ->
                ( model
                , Cmd.batch
                    [ playSound "subway_arrival"
                    , Process.sleep 37000 |> Task.perform (always <| SubwaySounds)
                    ]
                )

            Achievement key ->
                -- TODO probably make a better UI for this
                ( { model | story = [ NarrativeContent.t key ] }
                , Cmd.none
                )

            Disembark ->
                ( { model | scene = Lobby }, stopSound "subway_departure" )
                    |> updateAndThen (delay rules disembarkStoryDelay DisembarkStory)

            DisembarkStory ->
                updateStory rules "disembark" model

            DebugSeachWorldModel text ->
                let
                    newDebugState =
                        Maybe.map (Debug.updateSearch text) model.debugState
                in
                ( { model | debugState = newDebugState }
                , Cmd.none
                )


{-| Applies pending changes and special events. This is used to make sure the view
doesn't change in the background until the story modal has closed.
-}
applyPendingChanges : LocalTypes.Rules -> Model -> ( Model, Cmd Msg )
applyPendingChanges rules model =
    case model.pendingChanges of
        Just ( trigger, changes, matchedRuleID ) ->
            ( { model
                | worldModel = applyChanges changes trigger model.worldModel
                , pendingChanges = Nothing
              }
            , Cmd.none
            )
                |> updateAndThen (specialEvents rules matchedRuleID)

        _ ->
            ( model, Cmd.none )


delay : LocalTypes.Rules -> Float -> Msg -> Model -> ( Model, Cmd Msg )
delay rules duration msg model =
    -- no delay if loading a checkpoint
    if model.showSelectScene || not model.loaded then
        update rules msg model

    else
        ( model, Task.perform (always msg) <| Process.sleep duration )



-- PORTS
-- IN


port loaded : (Bool -> msg) -> Sub msg


port keyPress : (String -> msg) -> Sub msg


port persistLoadRes : (List String -> msg) -> Sub msg


port persistListRes : (( String, List String ) -> msg) -> Sub msg


port persistListChanged : (() -> msg) -> Sub msg



-- OUT


port persistListReq : () -> Cmd msg


port persistLoadReq : String -> Cmd msg


port persistSaveReq : ( String, List String ) -> Cmd msg


port persistDeleteReq : String -> Cmd msg


port playSound : String -> Cmd msg


port stopSound : String -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loaded <| always Loaded
        , keyPress <| handleKey model
        , persistListRes <| (Persist << ExistingSaves)
        , persistLoadRes LoadScene
        , persistListChanged <| always (Persist ListSaves)
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
    if not model.loaded || model.showSelectScene then
        NoOp

    else
        case key of
            " " ->
                if showingTitle then
                    Interact "next_day"

                else if model.showMap then
                    ToggleMap

                else if model.showNotebook then
                    ToggleNotebook

                else if model.scene == Splash then
                    Continue

                else if not <| List.isEmpty model.story then
                    Continue

                else
                    NoOp

            "m" ->
                ToggleMap

            "n" ->
                ToggleNotebook

            _ ->
                NoOp


view : Model -> Html Msg
view model =
    if not model.loaded then
        div [ class "Loading" ]
            [ p [] [ text "Loading..." ]
            , progress [ id "loading-progress", value "0" ] [ text "0" ]
            ]

    else if model.showSelectScene then
        selectSceneView

    else
        div []
            [ if model.scene == MainTitle then
                -- should always have a head since the scene switches to Title after
                -- the story runs out
                mainTitleView <| Maybe.withDefault "ERROR: No story to show" <| List.head model.story

              else
                mainView model
            , div
                [ class "Debug"
                , stopPropagationOn "keydown" <| Json.succeed ( NoOp, True )
                ]
                [ Maybe.map (Debug.debugBar DebugSeachWorldModel model.worldModel) model.debugState
                    |> Maybe.withDefault (text "")
                ]
            , if model.debugState == Nothing then
                text ""

              else
                transcriptView model
            ]


transcriptView : Model -> Html Msg
transcriptView model =
    div []
        [ div
            [ style "color" "green"
            , style "display" "block"
            , style "position" "absolute"
            , style "z-index" "99"
            , style "padding" "2px"
            , style "bottom" "0"
            , style "left" "1em"
            , style "cursor" "pointer"
            , onClick ToggleTranscript
            ]
            [ text "transcript" ]
        , if model.showTranscript then
            textarea
                [ style "color" "green"
                , style "position" "absolute"
                , style "z-index" "99"
                , style "width" "50%"
                , style "height" "70%"
                , style "top" "3em"
                , style "left" "1em"
                , readonly True
                ]
                [ text (model.transcript |> String.join "\n") ]

          else
            text ""
        ]


mainView : Model -> Html Msg
mainView model =
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
    -- keyed so fade in animations play
    Html.Keyed.node "div"
        [ class "game" ]
        [ case scene of
            MainTitle ->
                -- shouldn't happen because mainTitleView is showing instad of mainView
                ( "mainTitle", text "" )

            Splash ->
                ( "splash", splashView )

            Title title ->
                ( "title", titleView title )

            End ->
                ( "end", endView )

            CentralGuardOffice ->
                ( "centralGuardOffice", CentralGuardOffice.view model.worldModel )

            Lobby ->
                ( "lobby", Lobby.view map model.worldModel currentStation )

            Platform line ->
                ( "platform", Platform.view map currentStation line model.worldModel )

            Passageway ->
                ( "passageway", Passageway.view )

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
                    , worldModel = model.worldModel
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
        , ( "notebook"
          , if model.showNotebook then
                notebookView model

            else
                text ""
          )
        , ( "map"
          , if model.showMap then
                mapView model.worldModel

            else
                text ""
          )
        ]


selectSceneView : Html Msg
selectSceneView =
    let
        chapter1 =
            [ "LOBBY", "BRIEFCASE", "RED_LINE_PASS", "RED_LINE_PASS", "RED_LINE", "CELL_PHONE", "CELL_PHONE", "CELL_PHONE", "COFFEE_CART", "COFFEE", "COFFEE_CART", "COMMUTER_1", "COMMUTER_1", "LOUD_PAYPHONE_LADY", "COFFEE_CART", "LOUD_PAYPHONE_LADY", "GRAFFITI_EAST_MULBERRY", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "RED_LINE_PASS", "COFFEE_CART", "COFFEE_CART", "TRASH_DIGGER", "TRASH_DIGGER", "GRAFFITI_EAST_MULBERRY", "COFFEE", "CELL_PHONE", "CELL_PHONE", "RED_LINE", "RED_LINE", "CONVENTION_CENTER", "BROADWAY_STREET", "LOBBY", "RED_LINE", "SKATER_DUDE", "COFFEE_CART", "COFFEE_CART", "COFFEE", "CELL_PHONE", "CELL_PHONE", "COFFEE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "COFFEE_CART", "COFFEE_CART", "COFFEE_CART", "COFFEE", "RED_LINE", "RED_LINE", "CHURCH_STREET", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "COFFEE_CART", "RED_LINE", "RED_LINE", "LOBBY", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "MAP_POSTER", "MAP", "SAFETY_WARNING_POSTER", "CONVENTION_CENTER", "BROADWAY_STREET", "LOBBY", "EXIT", "ANGRY_CROWD", "YELLOW_LINE", "RED_LINE", "COMMUTER_1", "COMMUTER_1", "GIRL_IN_YELLOW", "NOTEBOOK", "SECURITY_OFFICERS", "RED_LINE", "ANGRY_CROWD", "COMMUTER_1", "SECURITY_OFFICERS", "RED_LINE", "RED_LINE", "SPRING_HILL", "LOBBY", "SECURITY_DEPOT_SPRING_HILL_STATION", "RED_LINE", "RED_LINE", "CHURCH_STREET", "MOTHER", "MOTHER", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "SODA_MACHINE", "RED_LINE", "RED_LINE", "CHURCH_STREET", "MOTHER", "RED_LINE", "RED_LINE", "SPRING_HILL", "SECURITY_DEPOT_SPRING_HILL_STATION", "SKATER_DUDE", "SKATER_DUDE", "RED_LINE", "ORANGE_LINE", "ORANGE_LINE", "UNIVERSITY", "ST_MARKS", "CAPITOL_HEIGHTS", "GREEN_SUIT_MAN", "SHIFTY_MAN", "TRASH_CAN_CAPITOL_HEIGHTS", "ODD_KEY", "SPIKY_HAIR_GUY", "MARK", "MARK", "YELLOW_LINE", "YELLOW_LINE", "LOBBY", "ORANGE_LINE", "ORANGE_LINE", "SEVENTY_THIRD_STREET", "TICKET_INSPECTOR", "INFRACTIONS_INSTRUCTIONS_POSTER", "INFRACTIONS_ROOM_DOOR", "INFRACTIONS_PRINTER", "INFRACTIONS_COMPUTER", "INFRACTIONS_CARD_READER", "INFRACTIONS_CARD_READER", "INFRACTIONS_PRINTER", "INFRACTIONS_COMPUTER", "INFRACTIONS_CARD_READER", "INFRACTIONS_COMPUTER", "INFRACTIONS_PRINTER", "INFRACTIONS_CARD_READER", "INFRACTIONS_COMPUTER", "INFRACTIONS_PRINTER", "INFRACTIONS_ROOM_DOOR", "GRIZZLED_SECURITY_GUARD", "RED_LINE_PASS" ]

        chatper2 =
            [ "ORANGE_LINE", "ORANGE_LINE", "SEVENTY_THIRD_STREET", "BROOM_CLOSET", "PAYPHONE_SEVENTY_THIRD_STREET", "DISTRESSED_WOMAN", "MISSING_DOG_POSTER_5", "BUSINESS_MAN", "ORANGE_LINE", "ORANGE_LINE", "SPRING_HILL", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_5", "RED_LINE", "RED_LINE", "CONVENTION_CENTER", "MISSING_DOG_POSTER_5", "MISSING_DOG_POSTER_4", "MISSING_DOG_POSTER_5", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "CHURCH_STREET", "MISSING_DOG_POSTER_4", "MISSING_DOG_POSTER_4", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "MISSING_DOG_POSTER_3", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "MISSING_DOG_POSTER_2", "RED_LINE", "RED_LINE", "TWIN_BROOKS", "MISSING_DOG_POSTER_1", "MISSING_DOG_POSTER_1", "MAN_IN_HOT_DOG_SUIT", "MASCOT_PAPERS", "MAN_IN_HOT_DOG_SUIT", "RED_LINE", "RED_LINE", "SPRING_HILL", "ORANGE_LINE", "ORANGE_LINE", "UNIVERSITY", "FRANKS_FRANKS", "FRANKS_FRANKS", "MAN_IN_HOT_DOG_SUIT", "CHANGE", "MAN_IN_HOT_DOG_SUIT", "ORANGE_LINE", "ORANGE_LINE", "ST_MARKS", "BROKEN_PAYPHONE", "ORANGE_LINE", "ORANGE_LINE", "SEVENTY_THIRD_STREET", "PAYPHONE_SEVENTY_THIRD_STREET", "MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET", "MAINTENANCE_DOOR_FORTY_SECOND_STREET_TO_SEVENTY_THIRD_STREET", "BLUE_LINE", "BLUE_LINE", "LOBBY", "SECURITY_CAMERA_FORTY_SECOND_STREET", "GRIZZLED_REPAIRMAN", "confront_repairman", "ELECTRIC_PANEL", "BLUE_LINE" ]

        fullPlay =
            chapter1 ++ chatper2

        finalPlayThrough =
            [ "LOBBY", "BRIEFCASE", "CELL_PHONE", "CELL_PHONE", "RED_LINE_PASS", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "CHURCH_STREET", "WEST_MULBERRY", "WEST_MULBERRY", "LOBBY", "COFFEE_CART", "COFFEE", "COFFEE", "COFFEE_CART", "LOUD_PAYPHONE_LADY", "LOUD_PAYPHONE_LADY", "SODA_MACHINE", "SODA_MACHINE", "COMMUTER_1", "COMMUTER_1", "COMMUTER_1", "GRAFFITI_EAST_MULBERRY", "GRAFFITI_EAST_MULBERRY", "PURPLE_LINE", "PURPLE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "COFFEE_CART", "COFFEE", "CELL_PHONE", "GRAFFITI_EAST_MULBERRY", "COFFEE_CART", "TRASH_DIGGER", "TRASH_DIGGER", "SODA_MACHINE", "PURPLE_LINE", "PURPLE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "TWIN_BROOKS", "BROADWAY_STREET", "LOBBY", "SKATER_DUDE", "COFFEE_CART", "COFFEE", "SODA_MACHINE", "CELL_PHONE", "COFFEE", "PURPLE_LINE", "PURPLE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "CONVENTION_CENTER", "BROADWAY_STREET", "LOBBY", "BENCH_BUM", "BENCH_BUM", "BENCH_BUM", "BENCH_BUM", "TRASH_DIGGER", "COFFEE_CART", "COFFEE_CART", "COFFEE", "COFFEE", "GRAFFITI_EAST_MULBERRY", "SODA_MACHINE", "CELL_PHONE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "NOTEBOOK", "NOTEBOOK", "COFFEE_CART", "COFFEE_CART", "COFFEE_CART", "COFFEE_CART", "COFFEE_CART", "SODA_MACHINE", "GRAFFITI_EAST_MULBERRY", "CELL_PHONE", "SODA_MACHINE", "SODA_MACHINE", "SODA_MACHINE", "BRIEFCASE", "PURPLE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "LOBBY", "NOTEBOOK", "MAINTENANCE_MAN", "MAINTENANCE_MAN", "MAP_POSTER", "MAP", "MAP", "MAP", "RED_LINE_PASS", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "YELLOW_LINE", "YELLOW_LINE", "RED_LINE", "NOTEBOOK", "EXIT", "EXIT", "COMMUTER_1", "COMMUTER_1", "GIRL_IN_YELLOW", "NOTEBOOK", "EXIT", "ANGRY_CROWD", "ANGRY_CROWD", "EXIT", "SECURITY_OFFICERS", "SECURITY_OFFICERS", "ANGRY_CROWD", "COMMUTER_1", "NOTEBOOK", "CELL_PHONE", "YELLOW_LINE", "SECURITY_OFFICERS", "MAP", "SECURITY_OFFICERS", "SECURITY_OFFICERS", "MAP", "YELLOW_LINE", "YELLOW_LINE", "LOBBY", "BLUE_LINE", "BLUE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "BULLETIN_BOARD", "BULLETIN_BOARD", "BULLETIN_BOARD", "BULLETIN_BOARD", "SOGGY_JACKET", "SOGGY_JACKET", "DRINKING_FOUNTAIN", "CELL_PHONE", "BULLETIN_BOARD", "TRASH_CAN_WEST_MULBERRY", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "COFFEE_CART", "SODA_MACHINE", "PURPLE_LINE", "PURPLE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "CHURCH_STREET", "MISSIONARIES", "MISSIONARIES", "SCHOOL_CHILDREN", "SCHOOL_CHILDREN", "WOMAN_IN_ODD_HAT", "WOMAN_IN_ODD_HAT", "MOTHER", "NOTEBOOK", "MOTHER", "CHANGE", "MOTHER", "MOTHER", "MOTHER", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "CONVENTION_CENTER", "BUSTLING_CROWD", "MUSICIAN", "MUSICIAN", "musicians_change", "CHANGE", "MUSICIAN", "MUSICIAN", "MUSICIAN", "musicians_change", "CHANGE", "MARCYS_PIZZA", "MAN_IN_RATTY_HAT", "NOTEBOOK", "PURPLE_LINE", "PURPLE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "BULLETIN_BOARD", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "RED_LINE", "RED_LINE", "CHURCH_STREET", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "SODA_MACHINE", "SODA", "SODA_MACHINE", "RED_LINE", "RED_LINE", "TWIN_BROOKS", "MAINTENANCE_MAN", "MAP_POSTER", "MAN_IN_RATTY_HAT", "MAP_POSTER", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "RED_LINE", "RED_LINE", "SPRING_HILL", "RED_LINE", "RED_LINE", "LOBBY", "CUSTODIAN", "CUSTODIAN", "CUSTODIAN", "CUSTODIAN", "OVERTURNED_TRASHCAN", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_0", "NEWSPAPER_VENDING_MACHINE", "OVERTURNED_TRASHCAN", "OVERTURNED_TRASHCAN", "CUSTODIAN", "NEWSPAPER_VENDING_MACHINE", "SECURITY_DEPOT_SPRING_HILL_STATION", "ORANGE_LINE", "ORANGE_LINE", "LOBBY", "SODA", "CHANGE", "SKATER_DUDE", "SKATER_DUDE", "SKATER_DUDE", "ORANGE_LINE", "LOBBY", "SKATER_DUDE", "ORANGE_LINE", "ORANGE_LINE", "LOBBY", "ORANGE_LINE", "ORANGE_LINE", "NORWOOD", "CAPITOL_HEIGHTS", "GREEN_SUIT_MAN", "GREEN_SUIT_MAN", "ORANGE_LINE", "ORANGE_LINE", "LOBBY", "SHIFTY_MAN", "SHIFTY_MAN", "SHIFTY_MAN", "GREEN_SUIT_MAN", "TROPICAL_T_SHIRT_MAN", "TROPICAL_T_SHIRT_MAN", "TRASH_CAN_CAPITOL_HEIGHTS", "ODD_KEY", "ODD_KEY", "SPIKY_HAIR_GUY", "SPIKY_HAIR_GUY", "SPIKY_HAIR_GUY", "MARK", "MARK", "ORANGE_LINE", "ORANGE_LINE", "LOBBY", "YELLOW_LINE", "YELLOW_LINE", "LOBBY", "GREEN_LINE", "GREEN_LINE", "LOBBY", "ORANGE_LINE", "ORANGE_LINE", "IRIS_LAKE", "SODA", "ODD_KEY", "NOTEBOOK", "MAP", "CHANGE", "TICKET_INSPECTOR", "SODA", "INFRACTIONS_INSTRUCTIONS_POSTER", "INFRACTIONS_ROOM_DOOR", "INFRACTIONS_COMPUTER", "INFRACTIONS_CARD_READER", "INFRACTIONS_COMPUTER", "INFRACTIONS_CARD_READER", "INFRACTIONS_COMPUTER", "INFRACTIONS_ROOM_DOOR", "INFRACTIONS_PRINTER", "INFRACTIONS_PRINTER", "INFRACTIONS_COMPUTER", "INFRACTIONS_CARD_READER", "INFRACTIONS_COMPUTER", "INFRACTIONS_INSTRUCTIONS_POSTER", "INFRACTIONS_ROOM_DOOR", "SODA", "GRIZZLED_SECURITY_GUARD", "RED_LINE_PASS", "CHANGE", "SODA", "MURAL", "MURAL", "BIRD", "BIRD", "CENTRAL_GUARD_OFFICE_ENTRANCE", "COMMUTERS_ST_MARKS", "BROKEN_PAYPHONE", "BLUE_LINE", "BLUE_LINE", "LOBBY", "ORANGE_LINE", "ORANGE_LINE", "IRIS_LAKE", "GIRL_IN_YELLOW", "NOTEBOOK", "NOTEBOOK", "CONCERT_POSTER", "MAINTENANCE_DOOR_IRIS_LAKE_TO_WEST_MULBERRY", "ODD_KEY", "MAINTENANCE_DOOR_IRIS_LAKE_TO_WEST_MULBERRY", "GRAFFITI_IRIS_LAKE", "TRASHED_NEWSPAPERS", "TRASHED_NEWSPAPERS", "TRASHED_NEWSPAPERS", "TRASHED_NEWSPAPERS", "TRASHED_NEWSPAPERS", "TRASHED_NEWSPAPERS", "ORANGE_LINE", "ORANGE_LINE", "NORWOOD", "LIVING_STATUE", "CHANGE", "LIVING_STATUE", "CHANGE", "OLD_LADIES", "OLD_LADIES", "OLD_LADIES", "OLD_LADIES", "TRASH_CAN_NORWOOD", "MAN_IN_RATTY_HAT", "NOTEBOOK", "SLEEPING_MAN", "CHANGE", "SLEEPING_MAN", "help_a_guy_out", "CHANGE", "SLEEPING_MAN", "SLEEPING_MAN", "SLEEPING_MAN", "ORANGE_LINE", "ORANGE_LINE", "ST_MARKS", "ORANGE_LINE", "ORANGE_LINE", "UNIVERSITY", "FAKE_COP", "FAKE_COP", "SODA", "ADVERTISEMENT", "ADVERTISEMENT", "MAGAZINE_STAND", "MAGAZINE_STAND", "MAGAZINE_STAND", "MAGAZINE_STAND", "MAGAZINE_STAND", "SECRET_SERVICE_TYPE_GUY", "SECRET_SERVICE_TYPE_GUY", "SECRET_SERVICE_TYPE_GUY", "FRANKS_FRANKS", "FRANKS_FRANKS", "ORANGE_LINE", "ORANGE_LINE", "SPRING_HILL", "NEWSPAPER_VENDING_MACHINE", "ORANGE_LINE", "ORANGE_LINE", "CAPITOL_HEIGHTS", "MARK", "TRASH_CAN_CAPITOL_HEIGHTS", "ORANGE_LINE", "ORANGE_LINE", "SEVENTY_THIRD_STREET", "DISTRESSED_WOMAN", "MISSING_DOG_POSTER_5", "PAYPHONE_SEVENTY_THIRD_STREET", "ABANDONED_JACKET", "ABANDONED_JACKET", "TRASH_CAN_SEVENTY_THIRD_STREET", "BUSINESS_MAN", "BUSINESS_MAN", "BROOM_CLOSET", "PAYPHONE_SEVENTY_THIRD_STREET", "CHANGE", "SODA", "ABANDONED_JACKET", "BUSINESS_MAN", "NOTEBOOK", "ORANGE_LINE", "ORANGE_LINE", "ONE_HUNDRED_FORTH_STREET", "MAINTENANCE_MAN", "MAINTENANCE_MAN", "FLUORESCENT_LIGHTS", "FLUORESCENT_LIGHTS", "FLUORESCENT_LIGHTS", "FLUORESCENT_LIGHTS", "VENDING_MACHINE", "CHANGE", "CONSTRUCTION_AREA", "TRASH_CAN_ONE_HUNDRED_FOURTH_STREET", "ORANGE_LINE", "ORANGE_LINE", "SPRING_HILL", "MISSING_DOG_POSTER_0", "MISSING_DOG_POSTER_5", "RED_LINE", "RED_LINE", "TWIN_BROOKS", "MISSING_DOG_POSTER_5", "MISSING_DOG_POSTER_4", "MISSING_DOG_POSTER_5", "SAFETY_WARNING_POSTER", "MAN_IN_HOT_DOG_SUIT", "MASCOT_PAPERS", "MASCOT_PAPERS", "MAN_IN_HOT_DOG_SUIT", "MAN_IN_HOT_DOG_SUIT", "RED_LINE", "RED_LINE", "CONVENTION_CENTER", "MISSING_DOG_POSTER_4", "MUSICIAN", "MUSICIAN", "musicians_change", "CHANGE", "MARCYS_PIZZA", "YELLOW_LINE", "YELLOW_LINE", "LOBBY", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "CHURCH_STREET", "RED_LINE", "RED_LINE", "EAST_MULBERRY", "MISSING_DOG_POSTER_3", "COFFEE_CART", "RED_LINE", "RED_LINE", "WEST_MULBERRY", "BULLETIN_BOARD", "TRASH_CAN_WEST_MULBERRY", "throw_away_mascot_papers", "MISSING_DOG_POSTER_2", "MISSING_DOG_POSTER_1", "RED_LINE", "RED_LINE", "CHURCH_STREET", "SODA", "MISSING_DOG_POSTER_1", "RED_LINE", "RED_LINE", "SPRING_HILL", "ORANGE_LINE", "ORANGE_LINE", "LOBBY", "RED_LINE", "RED_LINE", "TWIN_BROOKS", "MAN_IN_HOT_DOG_SUIT", "MAN_IN_HOT_DOG_SUIT", "MAN_IN_HOT_DOG_SUIT", "MAN_IN_HOT_DOG_SUIT", "RED_LINE", "RED_LINE", "SPRING_HILL", "ORANGE_LINE", "ORANGE_LINE", "SEVENTY_THIRD_STREET", "TRASH_CAN_SEVENTY_THIRD_STREET", "BROOM_CLOSET", "BROOM_CLOSET", "BROOM_CLOSET", "BROOM_CLOSET", "ODD_KEY", "SODA", "PAYPHONE_SEVENTY_THIRD_STREET", "CHANGE", "PAYPHONE_SEVENTY_THIRD_STREET", "MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET", "MAINTENANCE_DOOR_FORTY_SECOND_STREET_TO_SEVENTY_THIRD_STREET", "BLUE_LINE", "BLUE_LINE", "LOBBY", "SECURITY_CAMERA_FORTY_SECOND_STREET", "GRIZZLED_REPAIRMAN", "confront_repairman", "ELECTRIC_PANEL", "BLUE_LINE", "BLUE_LINE", "just_do_it" ]

        skeleton =
            [ "LOBBY"
            , "CELL_PHONE"
            , "RED_LINE"
            , "RED_LINE"
            , "BROADWAY_STREET"
            , "LOBBY"
            , "CELL_PHONE"
            , "RED_LINE"
            , "RED_LINE"
            , "BROADWAY_STREET"
            , "LOBBY"
            , "CELL_PHONE"
            , "RED_LINE"
            , "RED_LINE"
            , "BROADWAY_STREET"
            , "LOBBY"
            , "CELL_PHONE"
            , "RED_LINE"
            , "RED_LINE"
            , "BROADWAY_STREET"

            --20
            , "LOBBY"
            , "CELL_PHONE"
            , "RED_LINE"
            , "RED_LINE"
            , "BROADWAY_STREET"
            , "LOBBY"
            , "MAP_POSTER"
            , "RED_LINE"
            , "RED_LINE"
            , "BROADWAY_STREET"
            , "LOBBY"
            , "SECURITY_OFFICERS"
            , "RED_LINE"
            , "SECURITY_OFFICERS"
            , "RED_LINE"
            , "RED_LINE"
            , "SPRING_HILL"
            , "LOBBY"
            , "SECURITY_DEPOT_SPRING_HILL_STATION"
            , "SKATER_DUDE"

            -- 40
            , "ORANGE_LINE"
            , "ORANGE_LINE"
            , "CAPITOL_HEIGHTS"
            , "MARK"
            , "ORANGE_LINE"
            , "ORANGE_LINE"
            , "SEVENTY_THIRD_STREET"
            , "TICKET_INSPECTOR"
            , "INFRACTIONS_GREEN_BUTTON"
            , "INFRACTIONS_ROOM_DOOR"
            , "GRIZZLED_SECURITY_GUARD"
            , "ORANGE_LINE"
            , "ORANGE_LINE"
            , "SEVENTY_THIRD_STREET"
            , "BROOM_CLOSET"
            , "PAYPHONE_SEVENTY_THIRD_STREET"
            , "ORANGE_LINE"
            , "ORANGE_LINE"
            , "SPRING_HILL"
            , "RED_LINE"

            -- 60
            , "RED_LINE"
            , "TWIN_BROOKS"
            , "MAN_IN_HOT_DOG_SUIT"
            , "RED_LINE"
            , "RED_LINE"
            , "SPRING_HILL"
            , "ORANGE_LINE"
            , "ORANGE_LINE"
            , "UNIVERSITY"
            , "FRANKS_FRANKS"
            , "MAN_IN_HOT_DOG_SUIT"
            , "ORANGE_LINE"
            , "ORANGE_LINE"
            , "SEVENTY_THIRD_STREET"
            , "PAYPHONE_SEVENTY_THIRD_STREET"
            , "MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET"
            , "confront_repairman"
            , "BLUE_LINE"
            ]

        skip i =
            List.take i skeleton

        scenes =
            [ ( "(Full playthrough)", finalPlayThrough )
            , ( "(Interact with everything)", fullPlay )
            , ( "End", skip 79 )
            , ( "Call boss", skip 75 )
            , ( "Empty broom closet", skip 55 )
            , ( "Recieved orange line pass", skip 51 )
            , ( "Caught", skip 47 )
            , ( "Orange line", skip 43 )
            , ( "Run into skater dude again", skip 39 )
            , ( "Briefcase stolen", skip 33 )
            , ( "Arrive at Twin Brooks", skip 26 )
            , ( "Friday", skip 20 )
            , ( "Thursday", skip 15 )
            , ( "Wednesday", skip 10 )
            , ( "Tuesday", skip 5 )
            , ( "Beginning", [] )
            ]
    in
    div [ class "SelectScene" ]
        [ h1 [] [ text "Select a scene to jump to:" ]
        , ul [] <|
            List.map
                (\( k, v ) ->
                    li [ onClick <| LoadScene v ] [ text k ]
                )
                scenes
        ]


titleView : String -> Html Msg
titleView title =
    div [ class "Scene TitleScene" ]
        [ div [ class "TitleContent" ]
            [ h1 [ class "Title" ] [ text title ]
            , span [ class "StoryLine__continue", onClick (Interact "next_day") ] [ text "Continue..." ]
            ]
        ]


endView : Html Msg
endView =
    div [ class "Scene MainTitleScene" ]
        [ div [ class "MainTitleContent" ]
            [ Markdown.toHtml [] "![title](img/title.jpg)\n\nThe end of Part 1 - Thank you for playing!"
            ]
        ]


splashView : Html Msg
splashView =
    div [ class "Scene Splash" ]
        [ div [ class "MainTitleContent" ]
            [ Markdown.toHtml [] "![title](img/title.jpg)"
            , span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ]
            ]
        ]


mainTitleView : String -> Html Msg
mainTitleView story =
    div [ class "Scene MainTitleScene" ]
        [ div [ class "MainTitleContent" ]
            [ Markdown.toHtml [] story
            , span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ]
            ]
        ]


storyView : String -> Html Msg
storyView story =
    let
        lastSeg p =
            String.split "/" p |> List.reverse |> List.head |> Maybe.withDefault p

        linkParser =
            -- this works because only A tags have a `pathname` attribute (which
            -- starts with a `/`)
            Json.map
                (\path -> ( Interact <| lastSeg path, True ))
                (Json.at [ "target", "pathname" ] Json.string)

        catchLinkClicks =
            preventDefaultOn "click" <| Json.map identity linkParser
    in
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( story
          , div [ class "StoryLine__content" ]
                [ Markdown.toHtml [ catchLinkClicks ] story
                , span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ]
                ]
          )
        ]


mapView : Manifest.WorldModel -> Html Msg
mapView worldModel =
    div [ onClick ToggleMap, class "map" ] <|
        [ img [ class "map__image", src <| "img/" ++ Subway.mapImage ] []
        ]
            ++ List.map
                (\i ->
                    img [ class "map__image", src <| "img/map-passage-" ++ String.fromInt i ++ ".png" ] []
                )
                (getStat "PLAYER" "mapLevel" worldModel |> Maybe.withDefault 0 |> List.range 1)


notebookView : Model -> Html Msg
notebookView model =
    div [ class "Notebook__scrim", onClick ToggleNotebook ] [ NoteBook.view model ]
