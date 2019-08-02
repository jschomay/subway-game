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
import Views.Home as Home
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
    ( { worldModel = Manifest.initialWorldModel
      , loaded = False
      , story = []
      , rules = Rules.rules
      , scene = Home
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


{-| "Ticks" the narrative engine, and displays the story content
-}
updateStory : String -> Model -> Model
updateStory trigger model =
    case Narrative.Rules.findMatchingRule trigger model.rules model.worldModel of
        Nothing ->
            let
                defaultChanges =
                    defaultUpdate trigger model.worldModel

                defaultStory =
                    if assert trigger [ HasTag "silent" ] model.worldModel then
                        []

                    else
                        Dict.get trigger model.worldModel
                            |> Maybe.map (.description >> List.singleton)
                            |> Maybe.withDefault []
            in
            { model
                | story = defaultStory
                , pendingChanges = Just ( trigger, defaultChanges )
            }
                |> specialEvents trigger

        Just ( matchedRuleID, matchedRule ) ->
            let
                debug =
                    Debug.log "Matched rule:" matchedRuleID

                defaultChanges =
                    defaultUpdate trigger model.worldModel

                ( currentNarrative, updatedNarrative ) =
                    Narrative.update matchedRule.narrative
            in
            { model
              -- make sure rule changes are second so that they can overrite default changes if needed
                | pendingChanges = Just <| ( trigger, defaultChanges ++ matchedRule.changes )
                , story = currentNarrative
                , rules = Dict.insert matchedRuleID { matchedRule | narrative = updatedNarrative } model.rules
            }
                |> specialEvents matchedRuleID


specialEvents : String -> Model -> Model
specialEvents ruleId model =
    case ruleId of
        "map" ->
            { model | showMap = not model.showMap }

        "checkMap" ->
            { model | showMap = not model.showMap }

        other ->
            if List.member other [ "goToLinePlatform", "jumpYellowLineTurnstile" ] then
                -- This is kind of janky, but it works for now
                { model | scene = Platform <| Maybe.withDefault Red <| getCurrentLine model }

            else
                model


{-| Sometimes you need to react to an interaction regardless of which rule matches. For example, things like moving to a locaiton, or taking an item.
This happens before `updateStory`, so you can always override these changes in the rules if need.
Warning, this should be used sparingly!
-}
defaultUpdate : String -> Manifest.WorldModel -> List ChangeWorld
defaultUpdate interactableId worldModel =
    -- TODO this messes up the graph (plus overriding wouldn't actually work, since you can't "undo" or "set to previous value"), fix with:
    --- *** make these actual rules and remember to add the change to any more specific rule (though you'll need the `@` to match the selected interactable in the change if it is generic)
    --- ~~add these as rules with manual triggers and call updateStory again with manual trigger~~
    if assert interactableId [ HasTag "station" ] worldModel then
        -- move to selected station
        [ Update "player" [ SetLink "location" interactableId ] ]

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


getCurrentLine : Model -> Maybe City.Line
getCurrentLine model =
    case model.scene of
        Turnstile line ->
            Just line

        _ ->
            Nothing


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
                    delay introDelay (Interact "player")
                )

            LoadScene ( model_, history ) ->
                List.foldl
                    (\id modelTuple ->
                        modelTuple
                            |> updateAndThen (update <| Interact id)
                            |> updateAndThen
                                (\m ->
                                    let
                                        ( trigger, changes ) =
                                            m.pendingChanges
                                                |> Maybe.map identity
                                                |> Maybe.withDefault ( "", [] )
                                    in
                                    ( { m
                                        | pendingChanges = Nothing
                                        , worldModel = applyChanges changes trigger m.worldModel
                                      }
                                    , Cmd.none
                                    )
                                )
                    )
                    ( { model_ | selectScene = False }, Cmd.none )
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
                -- TODO check if allowed to show map (ie. map in inventory, scene lobby, etc)
                ( { model | showMap = not model.showMap }
                , Cmd.none
                )

            Go area ->
                -- TODO would be best to move all of `model.scene` into the world model, but for now, just duplicate the line color there
                ( { model | scene = area }, Cmd.none )

            BoardTrain line station ->
                ( { model | scene = Train { line = line, status = InTransit } }
                , delay departingDelay (Interact (station |> stationInfo |> .id |> String.fromInt))
                )

            Continue ->
                if List.length model.story > 1 then
                    ( { model | story = List.drop 1 model.story }, Cmd.none )

                else
                    (case model.scene of
                        Train train ->
                            ( { model | scene = Train <| changeTrainStatus Arriving train }
                            , delay arrivingDelay <| Disembark
                            )

                        _ ->
                            ( model, Cmd.none )
                    )
                        |> updateAndThen
                            (\m ->
                                let
                                    ( trigger, changes ) =
                                        m.pendingChanges
                                            |> Maybe.map identity
                                            |> Maybe.withDefault ( "", [] )
                                in
                                ( { m
                                    | worldModel = applyChanges changes trigger model.worldModel
                                    , pendingChanges = Nothing
                                    , story = []
                                  }
                                , Cmd.none
                                )
                            )

            Disembark ->
                ( { model | scene = Lobby }
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
    let
        atTurnstile =
            case model.scene of
                Turnstile _ ->
                    True

                _ ->
                    False

        turnStileMessage =
            case model.scene of
                Turnstile line ->
                    Interact <| .id <| lineInfo line

                _ ->
                    NoOp
    in
    case key of
        " " ->
            if model.showMap then
                ToggleMap

            else if not <| List.isEmpty model.story then
                Continue

            else if atTurnstile then
                turnStileMessage

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

        scene =
            if assert "player" [ HasTag "caught" ] model.worldModel then
                CentralGuardOffice

            else
                model.scene

        map =
            City.fullMap

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
        selectSceneView model

    else
        -- keyed so fade in animations play
        Html.Keyed.node "div"
            [ class "game" ]
            [ case scene of
                Home ->
                    ( "home", Home.view model.worldModel )

                CentralGuardOffice ->
                    ( "centralGuardOffice", CentralGuardOffice.view model.worldModel )

                Lobby ->
                    ( "lobby", Lobby.view map model.worldModel currentStation )

                Platform line ->
                    ( "platform", Platform.view map currentStation line )

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
                    |> Maybe.map storyView
                    |> Maybe.withDefault (text "")
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
            ( model, [ "player" ] )

        lostBriefcase =
            ( { model
                | scene = Lobby
              }
            , Tuple.second beginning ++ [ "cellPhone", "cellPhone", "briefcase", "presentation", "redLinePass", "6", "mapPoster", "1", "largeCrowd" ]
            )

        centralGuardOffice =
            ( { model
                | scene = CentralGuardOffice
              }
            , Tuple.second lostBriefcase ++ [ "2", "policeOffice", "yellowline" ]
            )
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


mapView : Html Msg
mapView =
    div [ onClick ToggleMap, class "map" ]
        [ img [ class "map__image", src <| "img/" ++ City.mapImage ] []
        ]
