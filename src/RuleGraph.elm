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
    ( model, drawGraph <| (\x -> Debug.log x "" |> always x) <| toDOT <| buildGraph model )


{-| Generate full deps graph of all possible paths through rules.

Logic:

  - From starting state, find all reachable rules, adding to deps graph
  - For each rule, apply changes, then recur (for rules no already in deps graph)
  - Regenerate entire graph on rule change (may be able to optimize what needs to change)

-}
buildGraph : Model -> Deps
buildGraph model =
    let
        isReachable : WorldModel -> Rule -> Bool
        isReachable worldModel rule =
            rule
                |> breakRuleIntoReqs
                |> List.all (\req -> req worldModel)

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

        applyRule : Rule -> WorldModel -> WorldModel
        applyRule rule state =
            WorldModel.applyChanges rule.changes state

        -- Dict depId [ruleId]
        addDep : String -> String -> Deps -> Deps
        addDep depId ruleId graph =
            Dict.get depId graph
                |> Maybe.withDefault []
                |> (\satisfies -> Dict.insert depId (ruleId :: satisfies) graph)

        findReachableRules : WorldModel -> Rules
        findReachableRules worldModel =
            model.rules
                |> Dict.filter (\id rule -> isReachable worldModel rule)

        -- TODO rename to needsToBeAdded?
        -- this probably only returns true if there is the link from -> [to]
        -- also shouldn't go to itself?
        -- also might not want an arrow in both directions??
        -- ignore rules without changes?
        inDeps : String -> String -> Rule -> Deps -> Bool
        inDeps from to rule deps =
            -- List.isEmpty rule.changes
            Dict.get from deps
                |> Maybe.map (List.member to)
                |> Maybe.withDefault False

        -- adds rule to deps and recurs
        followRule : String -> WorldModel -> String -> Rule -> Deps -> Deps
        followRule fromId currentWorldModel ruleId rule deps =
            if inDeps fromId ruleId rule deps then
                deps

            else
                findReachableRules (applyRule rule currentWorldModel)
                    |> Dict.foldl
                        (followRule ruleId (applyRule rule currentWorldModel))
                        (addDep fromId ruleId deps)
    in
    findReachableRules model.startingState
        |> Dict.foldl (followRule "start" model.startingState) Dict.empty


{-| Traces all possible paths to get to selected rule from starting state
-}
highlightPathsToRule : String -> Deps -> Deps
highlightPathsToRule ruleId deps =
    -- Dict.get model.selectedRule model.rules
    --     |> Maybe.map (\rule -> go model.selectedRule rule [ model.selectedRule ] Dict.empty)
    --     |> Maybe.withDefault Dict.empty
    deps


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
            List.map (\to -> "\"" ++ from ++ "\" -> \"" ++ to ++ "\"\n") tos
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
