port module RuleGraph exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (WorldModel)
import Narrative.Rules as Rules
import Narrative.WorldModel as WorldModel
import Rules


type alias Deps =
    -- TODO use set instead of list (to avoid double arrows)
    Dict String (List String)


type alias Req =
    WorldModel -> Bool


type alias Flags =
    {}


type alias Model =
    { rules : Rules
    , startingState : WorldModel
    , selectedRule : String
    }


type Msg
    = SelectRule String


main : Program Flags Model Msg
main =
    Browser.document
        { init = always init
        , view = \model -> { title = "Subway!", body = [ view model ] }
        , update = update
        , subscriptions = subscriptions
        }


port drawGraph : String -> Cmd msg


init : ( Model, Cmd Msg )
init =
    let
        model =
            { rules = Rules.rules
            , startingState = Manifest.worldModel
            , selectedRule = "start"
            }
    in
    ( model, drawGraph <| toDOT <| buildGraph model )


buildGraph : Model -> Deps
buildGraph model =
    let
        breakRuleIntoReqs : Rule -> List Req
        breakRuleIntoReqs rule =
            -- becomes a list of predicates fns with one query each
            List.concatMap breakMatcherIntoReqs <| rule.trigger :: rule.conditions

        breakMatcherIntoReqs matcher =
            case matcher of
                Rules.MatchAny queries ->
                    List.map (\query store -> WorldModel.query [ query ] store |> List.isEmpty |> not) queries

                Rules.Match id queries ->
                    if List.isEmpty queries then
                        [ always True ]

                    else
                        List.map (\query store -> WorldModel.assert id [ query ] store) queries

        applyRuleToState state rule =
            WorldModel.applyChanges rule.changes state

        isDep req rule =
            rule |> applyRuleToState model.startingState |> req

        -- Dict depId [ruleId]
        addDepForRule depId ruleId deps =
            Dict.get depId deps
                |> Maybe.withDefault []
                |> (\satisfies -> Dict.insert depId (ruleId :: satisfies) deps)

        startingStateSatisfies rule =
            List.foldl (\fn acc -> acc && fn model.startingState) True <| breakRuleIntoReqs rule

        validatePath : String -> List String -> Deps -> Maybe Deps
        validatePath from path knownDeps =
            -- if done, return deps
            -- if from satisfies head, add to path and recur
            -- if not, return Nothing
            case path of
                [] ->
                    -- TODO
                    Nothing

                to :: remaining ->
                    Nothing

        buildSubGraph : String -> Rule -> List String -> Deps -> Deps
        buildSubGraph ruleId rule path knownDeps =
            -- TODO need to validate path to stop recursion and get proper results!!!!!!!!!!
            -- (need to pass path forward and not add rules into knownDeps until validated)
            if
                (List.isEmpty <| breakRuleIntoReqs rule)
                    || startingStateSatisfies rule
            then
                knownDeps
                    |> addDepForRule "start" ruleId
                    |> validatePath ruleId path
                    |> Maybe.withDefault knownDeps

            else
                breakRuleIntoReqs rule
                    |> List.foldl (reduceReqs ruleId path) (Just knownDeps)
                    |> Maybe.withDefault (Dict.singleton "UNREACHABLE" [ ruleId ])

        reduceReqs : String -> List String -> Req -> Maybe Deps -> Maybe Deps
        reduceReqs ruleId path req knownDeps =
            case knownDeps of
                Nothing ->
                    Nothing

                Just deps ->
                    Dict.foldl (depsForReq ruleId req path) deps model.rules
                        |> (\newDeps ->
                                if newDeps == deps then
                                    Nothing

                                else
                                    Just newDeps
                           )

        depsForReq : String -> Req -> List String -> String -> Rule -> Deps -> Deps
        depsForReq ruleId req path depId dep knownDeps =
            if not <| isDep req dep then
                knownDeps

            else if Dict.member depId knownDeps then
                addDepForRule depId ruleId knownDeps

            else
                buildSubGraph depId dep path knownDeps

        -- addDepForRule "TODO subgraph" depId knownDeps
    in
    Dict.get model.selectedRule model.rules
        |> Maybe.map (\rule -> buildSubGraph model.selectedRule rule [ model.selectedRule ] Dict.empty)
        |> Maybe.withDefault Dict.empty


update msg model =
    case msg of
        SelectRule ruleId ->
            let
                newModel =
                    { model | selectedRule = ruleId }
            in
            ( newModel, drawGraph <| toDOT <| buildGraph newModel )


subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    let
        classes r =
            [ ( "Rule", True )
            , ( "Rule--selected", r == model.selectedRule )
            ]

        rule r =
            li [ classList <| classes r, onClick <| SelectRule r ] [ text r ]
    in
    div [ class "RuleGraph" ]
        [ div []
            [ text "Rules Visualizer"
            , ul [] <| List.map rule <| Dict.keys model.rules
            ]
        , div [ id "graph", class "Graph" ] [ text "loading" ]
        ]


toDOT : Deps -> String
toDOT dict =
    let
        edgesFrom from tos =
            List.map (\to -> "\"" ++ to ++ "\" -> \"" ++ from ++ "\"\n") tos
                |> String.join ""

        nodes =
            Dict.keys dict
                |> List.foldl (\key acc -> "\"" ++ key ++ "\"\n" ++ acc) "\n"

        edges =
            dict
                |> Dict.foldl
                    (\from to acc ->
                        acc ++ edgesFrom from to
                    )
                    ""
    in
    "digraph G {\n"
        ++ edges
        ++ nodes
        ++ "\n}"


graphExample =
    """
digraph G {

    node [style=filled]
    edge [fontcolor=gray]

  start -> findClosedPoliceOffice
  findClosedPoliceOffice -> rideWithoutTicketToLostFound [label="+1 rule breaker"]
  rideWithoutTicketToLostFound -> caught

  start -> followThief [label="+1 bravery"]
  followThief -> lockedMaintDoor
  followThief -> randomPerson
  followThief -> redHerringPaper
  lockedMaintDoor -> stealKeyCardFromMaintMan [label="start 'down the rabit hole' (woman in yellow)"]
  stealKeyCardFromMaintMan -> unlockDoor [label="+2 rule breaker get key card"]
  unlockDoor -> caught [label="lose keycard"]

  caught -> end


  start [label="case stolen", color=lightblue];
  end [label="guard office", color=lightblue];
  rideWithoutTicketToLostFound [label="ride without ticket (only available wo/ key card)"]
}
"""
