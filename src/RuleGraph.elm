port module RuleGraph exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD
import List.Extra as List
import LocalTypes exposing (..)
import Manifest exposing (WorldModel)
import Narrative.Rules as Rules
import Narrative.WorldModel as WorldModel
import Rules
import Set exposing (Set)


{-| Graph of how rules can be reached, expressed as a Dict
-}
type alias Deps =
    Dict String Edge


{-| All of the rule IDs that that the node is reachable from, along with the length of the path to get there, and the list of reachable rules from that path.

If an edge between the same two rules can be created in multiple ways, it only tracks the shortest path, and it concat the list of reachable rules (TODO if there is a cycle, concat might be a bug?)

-}
type alias Edge =
    Dict String { pathLength : Int, reachableRules : List String }


type alias Req =
    WorldModel -> Bool


type alias Flags =
    {}


type alias Model =
    { rules : Rules
    , startingState : WorldModel
    , selectedRule : String
    , graph : Deps
    }


type Msg
    = SelectRule String
    | SelectEdge String


startLabel =
    "__start__"


main : Program Flags Model Msg
main =
    Browser.document
        { init = always init
        , view = \model -> { title = "Subway Graph", body = [ view model ] }
        , update = update
        , subscriptions = subscriptions
        }


port drawGraph : String -> Cmd msg


init : ( Model, Cmd Msg )
init =
    let
        model =
            { rules = Rules.rules
            , startingState = Manifest.initialWorldModel
            , selectedRule = ""
            , graph = Dict.empty
            }
                |> (\m -> { m | graph = buildGraph m })
    in
    ( model, drawGraph <| (\x -> Debug.log x "" |> always x) <| toDOT model )


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
                WorldModel.MatchAny queries ->
                    List.map (\query store -> WorldModel.query [ query ] store |> List.isEmpty |> not) queries

                WorldModel.Match id queries ->
                    if List.isEmpty queries then
                        [ always True ]

                    else
                        List.map (\query store -> WorldModel.assert id [ query ] store) queries

        applyRule : Rule -> WorldModel -> WorldModel
        applyRule rule state =
            -- TODO need to get the trigger in here to properly apply trigger matching bulk updates
            WorldModel.applyChanges rule.changes "TODO this will never match" state

        addDep : String -> String -> Int -> List String -> Deps -> Deps
        addDep depId ruleId pathLength reachableRules graph =
            -- TODO take a record instead of positional args
            Dict.get ruleId graph
                |> Maybe.withDefault Dict.empty
                |> (\existingDeps -> Dict.insert ruleId (Dict.insert depId { pathLength = pathLength, reachableRules = reachableRules } existingDeps) graph)

        findReachableRules : WorldModel -> Rules
        findReachableRules worldModel =
            model.rules
                |> Dict.filter (\id rule -> isReachable worldModel rule)

        -- no when edge already exists
        -- also no when has no conditions (general rules) -- NOTE this could be too agressive if authors don't add any conditions at all (like main plot conditions)
        skip : String -> String -> Rule -> Deps -> Bool
        skip depId ruleId rule deps =
            List.isEmpty rule.conditions
                -- || List.isEmpty rule.changes
                -- False
                || (Dict.get ruleId deps
                        |> Maybe.map (Dict.member depId)
                        |> Maybe.withDefault False
                   )

        -- adds rule to deps and recurs
        followRule : Int -> String -> WorldModel -> String -> Rule -> Deps -> Deps
        followRule pathLength previousRuleId currentWorldModel ruleId rule deps =
            if skip previousRuleId ruleId rule deps then
                -- update edge to keep the shortest path
                Dict.update ruleId
                    (Maybe.map <|
                        -- TODO concat reachableRules?
                        Dict.update previousRuleId (Maybe.map (\dep -> { dep | pathLength = Basics.min dep.pathLength pathLength }))
                    )
                    deps

            else if List.isEmpty rule.changes then
                addDep previousRuleId ruleId pathLength [] deps
                    -- add dep to itself to differentiate it from dead ends, but not make the graph more complex
                    |> addDep ruleId ruleId (pathLength + 1) []
                -- OR
                -- draw line back to the previous node
                -- |> addDep ruleId previousRuleId (pathLength + 1)

            else
                findReachableRules (applyRule rule currentWorldModel)
                    |> (\reachableRules ->
                            Dict.foldl
                                (followRule (pathLength + 1) ruleId (applyRule rule currentWorldModel))
                                (addDep previousRuleId ruleId pathLength (Dict.keys reachableRules) deps)
                                reachableRules
                       )
    in
    findReachableRules model.startingState
        |> Dict.foldl (followRule 0 startLabel model.startingState) (Dict.singleton startLabel Dict.empty)


update msg model =
    case msg of
        SelectRule ruleId ->
            let
                newModel =
                    { model | selectedRule = ruleId }
            in
            ( newModel, drawGraph <| toDOT newModel )

        SelectEdge edgeId ->
            let
                newModel =
                    -- TODO set edgeId
                    { model | selectedRule = "" }
            in
            ( newModel, drawGraph <| toDOT newModel )


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

        selectGraphElement =
            -- This could be a node OR an edge, so we need to figure out which one in order to send the correct message
            -- Note that the target will always be one layer down from <g>, where the id is located, so we need to use `parentElement`
            -- Also this is svg, so we need to look into `attributes`, which is a NameNodeMap that we need to dig into further
            JD.at [ "target", "parentElement", "attributes" ] <|
                JD.map2
                    (\class id ->
                        case class of
                            "node" ->
                                SelectRule id

                            "edge" ->
                                SelectEdge id

                            _ ->
                                -- clicking anything else should deselect everything
                                SelectRule ""
                    )
                    (JD.at [ "class", "value" ] JD.string)
                    (JD.at [ "id", "value" ] JD.string)
    in
    div [ class "RuleGraph" ]
        [ div []
            [ text "Rules Visualizer"
            , ul [] <| List.map rule <| Dict.keys model.rules
            ]
        , div
            [ id "graph"
            , class "Graph"
            , on "click" selectGraphElement
            ]
            [ text "loading" ]
        ]


toDOT : Model -> String
toDOT { selectedRule, rules, graph } =
    let
        color from to i =
            if from == selectedRule then
                "red"

            else if to == selectedRule then
                "green"

            else
                case i of
                    0 ->
                        "\"#000000\""

                    1 ->
                        "\"#333333\""

                    2 ->
                        "\"#666666\""

                    3 ->
                        "\"#999999\""

                    _ ->
                        "\"#bbbbbb\""

        edgeWeight to i =
            if isTexture to Dict.empty then
                "1"

            else
                case i of
                    0 ->
                        "9"

                    1 ->
                        "6"

                    2 ->
                        "3"

                    _ ->
                        "1"

        -- sorts by path length, then "normalizes" the values
        -- ex: 4, 7, 3, 7, 8 -> 1, 2, 3, 3, 4
        -- TODO this could be a lot clearer
        rank : Edge -> List ( String, ( Int, { pathLength : Int, reachableRules : List String } ) )
        rank edge =
            -- TODO optimize?
            edge
                |> Dict.toList
                |> List.sortBy (\( _, { pathLength } ) -> pathLength)
                |> List.groupWhile (\( _, a ) ( _, b ) -> a.pathLength == b.pathLength)
                -- [(1, [1,1]), (2,[])]
                |> List.map (\( x, xs ) -> x :: xs)
                -- [[1,1,1], [2]]
                |> List.indexedMap (\i group -> List.map (Tuple.mapSecond (\original -> ( i, original ))) group)
                |> List.concat

        buildEdge to deps =
            -- TODO colorize valid paths when an edge is selected
            -- going forward: current edge's "to" is in the selected rule's reachableRules
            -- going back: current edge's reachableRules includes the "to" of the selected rule
            -- (first I need to tag edge ids as `from|to` so I can parse from and to out)
            deps
                |> rank
                |> List.map
                    (\( from, ( i, original ) ) ->
                        "\""
                            ++ (from ++ "\" -> \"" ++ to ++ "\" ")
                            ++ ("[penwidth=" ++ edgeWeight to i)
                            ++ (", color=" ++ color from to i)
                            -- ++ (", xlabel=" ++ String.fromInt original.pathLength)
                            ++ (", tooltip=\"" ++ String.join "\n" original.reachableRules ++ "\"")
                            ++ "]\n"
                    )
                |> String.join ""

        allDeps =
            -- NOT including deps for rules with no conditions
            Dict.foldl
                (\ruleId deps ids ->
                    if Dict.member ruleId generalRules then
                        ids

                    else
                        Dict.foldl
                            (\depId _ acc -> Set.insert depId acc)
                            ids
                            deps
                )
                Set.empty
                graph

        generalRules =
            rules
                |> Dict.filter (\id rule -> List.isEmpty rule.conditions)

        unreachable_rules =
            Dict.diff rules graph
                |> Dict.foldl
                    (\id rule acc ->
                        "\""
                            ++ id
                            ++ "\" ["
                            ++ (if id == selectedRule then
                                    selectedAttrs

                                else
                                    ""
                               )
                            ++ "]\n"
                            ++ acc
                    )
                    "\n"

        isStart key _ =
            key == startLabel

        isTexture key _ =
            Dict.get key rules
                |> Maybe.map (.changes >> List.isEmpty)
                |> Maybe.withDefault False

        isDeadEnd key _ =
            not <| Set.member key allDeps

        hasNoConditions key _ =
            case Dict.get key generalRules of
                Nothing ->
                    False

                _ ->
                    True

        nodeAttrs key deps =
            nodeAttrsGeneral key deps ++ ", " ++ nodeAttrsByType key deps

        nodeWeight i =
            if i <= 2 then
                "10"

            else if i <= 4 then
                "15"

            else if i <= 8 then
                "20"

            else
                "30"

        nodeAttrsGeneral key deps =
            -- "fontsize=" ++ nodeWeight (Dict.size deps) ++ ""
            "fontsize=14"

        nodeAttrsByType key deps =
            if selectedRule == key then
                selectedAttrs

            else if isStart key deps then
                "style=filled, fontcolor=white, color=green"

            else if hasNoConditions key deps then
                "style=filled, fontcolor=white, color=orange"

            else if isDeadEnd key deps then
                "style=filled, fontcolor=white, color=red"

            else if isTexture key deps then
                "style=filled, fontcolor=white, color=lightblue"

            else
                ""

        selectedAttrs =
            "fontsize=20, style=filled, fontcolor=white, color=blue"

        nodes =
            Dict.toList graph
                |> List.foldl
                    (\( key, deps ) acc ->
                        "\""
                            ++ key
                            ++ "\" [id=\""
                            ++ key
                            ++ "\", "
                            ++ nodeAttrs key deps
                            ++ "]\n"
                            ++ acc
                    )
                    "\n"

        edges =
            graph
                |> Dict.foldl
                    (\rule deps acc ->
                        acc ++ buildEdge rule deps
                    )
                    ""
    in
    """
    digraph G {

      subgraph cluster_0 {
        node [style=filled, color=red, fontcolor=white];
        label = "Unreachable rules";
        """
        ++ unreachable_rules
        ++ """
      }

    node [style=filled]
    """
        ++ edges
        ++ nodes
        ++ "\n}"
