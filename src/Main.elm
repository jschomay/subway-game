port module Main exposing (main)

import Browser
import Constants exposing (..)
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
import Narrative
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import NarrativeContent
import Process
import Rules
import Rules.Parser
import Set
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
    { debug : Bool }


main : Program Flags (Result (List ( String, Rules.Parser.ParseError )) Model) Msg
main =
    let
        -- TODO pull this code out to encapsulate the types and view
        -- TODO make these return a Result instead of this tuple
        ( initialWorldModel, entityParseErrors ) =
            Manifest.initialWorldModel

        ruleParseErrors =
            Rules.parseErrors

        narrativeParseErrors =
            NarrativeContent.parseErrors

        parsedData =
            -- TODO use Result.map3 (or fold of something) instead of this
            -- The question is if I want only the first parse error to render, or all errors
            -- to render
            case entityParseErrors ++ ruleParseErrors ++ narrativeParseErrors of
                [] ->
                    Ok initialWorldModel

                errors ->
                    Err errors
    in
    Browser.document
        { init =
            \flags ->
                case parsedData of
                    Ok data ->
                        init data flags |> Tuple.mapFirst Ok

                    Err errors ->
                        ( Err errors, Cmd.none )
        , view =
            \model ->
                case model of
                    Ok m ->
                        { title = "Subway!", body = [ view m ] }

                    Err errors ->
                        { title = "Errors found"
                        , body =
                            [ div
                                [ style "background" "black"
                                , style "color" "red"
                                , style "padding" "4em"
                                , style "display" "flex"
                                , style "flex-direction" "column"
                                , style "align-items" "center"
                                , style "justify-content" "center"
                                ]
                                [ h1 [] [ text "Errors when parsing!  Please fix:" ]
                                , ul [ style "width" "100%" ] <|
                                    List.map
                                        -- TODO this should already be a nice string or
                                        -- tuple
                                        (\( s, e ) ->
                                            li
                                                [ style "margin-bottom" "2em"
                                                ]
                                                [ text <| Rules.Parser.deadEndsToString e
                                                , pre
                                                    [ style "background" "white"
                                                    , style "padding" "1em"
                                                    , style "color" "black"
                                                    , style "overflow" " auto"
                                                    , style "width" "100%"
                                                    ]
                                                    [ code [] [ text s ] ]
                                                ]
                                        )
                                        errors
                                ]
                            ]
                        }
        , update =
            \msg model ->
                case model of
                    Ok m ->
                        update msg m |> Tuple.mapFirst Ok

                    Err e ->
                        ( Err e, Cmd.none )
        , subscriptions =
            \model ->
                Result.map subscriptions model
                    |> Result.withDefault Sub.none
        }


init : Manifest.WorldModel -> Flags -> ( Model, Cmd Msg )
init initialWorldModel flags =
    let
        debug =
            if flags.debug then
                Just
                    { debugSearchWorldModelText = ""
                    , lastMatchedRule = "Game started"
                    , lastInteraction = "begin game"
                    }

            else
                Nothing
    in
    ( { worldModel = initialWorldModel
      , loaded = False
      , story = []
      , ruleMatchCounts = Dict.empty
      , scene = Title (dayText initialWorldModel)
      , showMap = False
      , gameOver = False
      , debug = debug
      , showSelectScene = flags.debug
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
                        NarrativeContent.t trigger
                            |> parseNarrative model trigger trigger
            in
            -- no need to apply special events or pending changes (no changes,
            -- and no rule id to match).
            ( { model | story = newStory, ruleMatchCounts = newMatchCounts }, Cmd.none )

        Just ( matchedRuleID, matchedRule ) ->
            let
                newDebug =
                    Maybe.map (\debug -> { debug | lastMatchedRule = matchedRuleID, lastInteraction = trigger }) model.debug

                ( newStory, newMatchCounts ) =
                    parseNarrative model matchedRuleID trigger (NarrativeContent.t matchedRuleID)
            in
            ( { model
                | pendingChanges = Just ( trigger, matchedRule.changes, matchedRuleID )
                , story = newStory
                , debug = newDebug
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


parseNarrative : Model -> RuleID -> ID -> String -> ( Narrative.Narrative, Dict String Int )
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

        "goToLineTurnstile" ->
            ( { model | scene = Turnstile <| Maybe.withDefault Red <| getCurrentLine model.worldModel }, Cmd.none )

        "goToLobby" ->
            ( { model | scene = Lobby }, Cmd.none )

        -- achievements
        "get_caffeinated_plot_2" ->
            ( model, Process.sleep 300 |> Task.perform (\_ -> Achievement "get_caffeinated_plot_achievement") )

        other ->
            if List.member other [ "goToLinePlatform" ] then
                -- Remember, if you add another matcher to jump the turnstile, remove
                -- the at_turnstile tag!!!!!!!!
                ( { model | scene = Platform <| Maybe.withDefault Red <| getCurrentLine model.worldModel }, Cmd.none )

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
                , if model.showSelectScene then
                    Cmd.none

                  else
                    -- doesn't need anything special to start events now (starts at
                    -- title screen)
                    Cmd.none
                )

            LoadScene ( model_, history ) ->
                -- TODO maybe this can use a recursive `Process.sleep 0 (Replay id)` to create debuggable history
                List.foldl
                    (\id modelTuple ->
                        modelTuple
                            |> updateAndThen (update <| Interact id)
                            |> updateAndThen applyPendingChanges
                    )
                    ( { model_ | showSelectScene = False }, Cmd.none )
                    history

            Interact interactableId ->
                ( { model | history = model.history ++ [ interactableId ] |> Debug.log "history\n" }
                , Cmd.none
                )
                    |> updateAndThen (updateStory interactableId)
                    |> updateAndThen
                        -- Need to continue automaticaly when riding on the train if
                        -- there is no story, otherwise the train never arrives
                        (\m ->
                            ( m
                            , case ( m.scene, m.story ) of
                                ( Train _, [] ) ->
                                    delay 2000 Continue

                                _ ->
                                    Cmd.none
                            )
                        )

            Delay duration delayedMsg ->
                ( model
                , Task.perform (always delayedMsg) <| Process.sleep duration
                )

            ToggleMap ->
                if Rules.unsafeAssert "MAP.location=PLAYER" model.worldModel then
                    ( { model | showMap = not model.showMap }
                    , Cmd.none
                    )

                else
                    ( model, Cmd.none )

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

            Achievement key ->
                -- TODO probably make a better UI for this
                ( { model | story = [ NarrativeContent.t key ] }
                , Cmd.none
                )

            Disembark ->
                ( { model | scene = Lobby }
                , Cmd.none
                )

            DebugSeachWorldModel text ->
                let
                    newDebug =
                        Maybe.map (\debug -> { debug | debugSearchWorldModelText = text }) model.debug
                in
                ( { model | debug = newDebug }
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
    if not model.loaded || model.showSelectScene then
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
    if not model.loaded then
        div [ class "Loading" ] [ text "Loading..." ]

    else if model.showSelectScene then
        selectSceneView model

    else
        div []
            [ case model.debug of
                Just debug ->
                    debugView model.worldModel debug

                Nothing ->
                    text ""
            , mainView model
            ]


debugView : Manifest.WorldModel -> Debug -> Html Msg
debugView worldModel debug =
    let
        displayWorldModel =
            worldModel
                |> Dict.toList
                |> List.map displayEntity

        displayEntity ( id, { tags, stats, links } ) =
            String.join "." <|
                List.filter (not << String.isEmpty) <|
                    List.map (String.join ".")
                        [ [ id ]
                        , Set.toList tags
                        , Dict.toList stats |> List.map (\( key, value ) -> String.join "=" [ key, String.fromInt value ])
                        , Dict.toList links |> List.map (\( key, value ) -> String.join "=" [ key, value ])
                        ]

        filteredDisplayWorldModel =
            if String.isEmpty debug.debugSearchWorldModelText then
                []

            else
                List.filter (fuzzyMatch debug.debugSearchWorldModelText) displayWorldModel
                    |> List.sortBy
                        (\text ->
                            if String.startsWith (String.toLower debug.debugSearchWorldModelText) (String.toLower text) then
                                -1

                            else
                                0
                        )

        fuzzyMatch search text =
            String.contains (String.toLower search) (String.toLower text)

        stopPropKeydowns tagger =
            stopPropagationOn "keydown" <|
                Json.map alwaysStop (Json.map tagger targetValue)

        alwaysStop x =
            ( x, True )
    in
    div
        [ style "color" "yellow"
        , style "background" "black"
        , style "opacity" "0.9"
        , style "lineHeight" "1.5em"
        , style "zIndex" "99"
        , style "position" "absolute"
        ]
        [ text "Debug mode"
        , input
            [ onInput DebugSeachWorldModel
            , stopPropKeydowns (always NoOp)
            , value debug.debugSearchWorldModelText
            , placeholder "Search world model"
            , style "margin" "0 10px"
            ]
            []
        , span [] [ text <| "Last triggered rule: " ++ debug.lastInteraction ++ " - " ++ debug.lastMatchedRule ]
        , ul [ style "borderTop" "1px solid #333" ] <| List.map (\e -> li [] [ text e ]) filteredDisplayWorldModel
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
            Title title ->
                ( "title", titleView title )

            CentralGuardOffice ->
                ( "centralGuardOffice", CentralGuardOffice.view model.worldModel )

            Lobby ->
                ( "lobby", Lobby.view map model.worldModel currentStation )

            Platform line ->
                ( "platform", Platform.view map currentStation line model.worldModel )

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
        skeleton =
            [ "LOBBY", "CELL_PHONE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY" ]

        -- missing some interactions in intro
        fullPlay =
            [ "LOBBY", "BRIEFCASE", "RED_LINE_PASS", "RED_LINE_PASS", "RED_LINE", "CELL_PHONE", "CELL_PHONE", "CELL_PHONE", "COFFEE_CART", "COFFEE", "COFFEE_CART", "COMMUTER_1", "COMMUTER_1", "LOUD_PAYPHONE_LADY", "COFFEE_CART", "LOUD_PAYPHONE_LADY", "GRAFFITI", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "RED_LINE_PASS", "COFFEE_CART", "COFFEE_CART", "TRASH_DIGGER", "TRASH_DIGGER", "GRAFFITI", "COFFEE", "CELL_PHONE", "CELL_PHONE", "RED_LINE", "RED_LINE", "CONVENTION_CENTER", "BROADWAY_STREET", "LOBBY", "RED_LINE", "SKATER_DUDE", "COFFEE_CART", "COFFEE_CART", "COFFEE", "CELL_PHONE", "CELL_PHONE", "COFFEE", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "COFFEE_CART", "COFFEE_CART", "COFFEE_CART", "COFFEE", "RED_LINE", "RED_LINE", "CHURCH_STREET", "BROADWAY_STREET", "LOBBY", "CELL_PHONE", "COFFEE_CART", "RED_LINE", "RED_LINE", "LOBBY", "RED_LINE", "RED_LINE", "BROADWAY_STREET", "MAP_POSTER", "MAP", "MAP_POSTER", "SAFETY_WARNING_POSTER", "RED_LINE", "RED_LINE", "CONVENTION_CENTER", "MAP", "GREEN_LINE", "GREEN_LINE", "LOBBY", "RED_LINE", "RED_LINE", "LOBBY", "YELLOW_LINE", "LOBBY", "CELL_PHONE", "BRIEFCASE", "RED_LINE_PASS" ]

        skip i =
            ( model, skeleton |> List.take i )

        scenes =
            [ ( "Beginning", ( model, [] ) )
            , ( "Tuesday", skip <| 6 )
            , ( "Wednesday", skip <| 11 )
            , ( "Thursday", skip <| 16 )
            , ( "Friday", skip <| 21 )
            , ( "Arrive at Twin Brooks"
              , ( model, skeleton )
              )
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
