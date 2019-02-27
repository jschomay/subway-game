port module RuleGraph exposing (main)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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


{-| All of the rule IDs that that the node is reachable from, along with the length of the path to get there.

If an edge between the same two rules can be created in multiple ways, it only tracks the shortest path.

-}
type alias Edge =
    Dict String Int


type alias Req =
    WorldModel -> Bool


type alias Flags =
    {}


type alias Model =
    { rules : Rules
    , startingState : WorldModel
    , selectedRule : String
    , deps : Deps
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
            , selectedRule = ""
            , deps = Dict.empty
            }
                |> (\m -> { m | deps = buildGraph m })
    in
    ( model, drawGraph <| (\x -> Debug.log x "" |> always x) <| toDOT model.rules <| model.deps )


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

        addDep : String -> String -> Int -> Deps -> Deps
        addDep depId ruleId pathLength graph =
            Dict.get ruleId graph
                |> Maybe.withDefault Dict.empty
                |> (\existingDeps -> Dict.insert ruleId (Dict.insert depId pathLength existingDeps) graph)

        findReachableRules : WorldModel -> Rules
        findReachableRules worldModel =
            model.rules
                |> Dict.filter (\id rule -> isReachable worldModel rule)

        -- TODO rename to needsToBeAdded or alreadyConnected?
        -- this probably only returns true if there is the link between the two nodes
        inDeps : String -> String -> Rule -> Deps -> Bool
        inDeps depId ruleId rule deps =
            Dict.get ruleId deps
                |> Maybe.map (Dict.member depId)
                |> Maybe.withDefault False

        -- adds rule to deps and recurs
        followRule : Int -> String -> WorldModel -> String -> Rule -> Deps -> Deps
        followRule pathLength previousRuleId currentWorldModel ruleId rule deps =
            if inDeps previousRuleId ruleId rule deps then
                -- keep the shorter path for this edge
                Dict.update ruleId
                    (Maybe.map <|
                        Dict.update previousRuleId (Maybe.map (Basics.min pathLength))
                    )
                    deps

            else if List.isEmpty rule.changes then
                -- add dep to itself to differentiate it from dead ends, but not make the graph more complex
                addDep previousRuleId ruleId pathLength deps
                    |> addDep ruleId ruleId (pathLength + 1)

            else
                findReachableRules (applyRule rule currentWorldModel)
                    |> Dict.foldl
                        (followRule (pathLength + 1) ruleId (applyRule rule currentWorldModel))
                        (addDep previousRuleId ruleId pathLength deps)
    in
    findReachableRules model.startingState
        |> Dict.foldl (followRule 0 "__start__" model.startingState) (Dict.singleton "__start__" Dict.empty)


{-| Traces all possible paths to get to selected rule from starting state
-}
highlightPathsToRule : String -> Deps -> Deps
highlightPathsToRule selectedRuleId fullDeps =
    -- TODO fix logic repitition here and in buildGraph
    let
        depsForRule : String -> Edge
        depsForRule ruleId =
            Dict.get ruleId fullDeps
                |> Maybe.withDefault Dict.empty

        -- Dict ruleId [depIds]
        addDep : String -> String -> Int -> Deps -> Deps
        addDep depId ruleId pathLength graph =
            Dict.get ruleId graph
                |> Maybe.withDefault Dict.empty
                |> (\existingDeps -> Dict.insert ruleId (Dict.insert depId pathLength existingDeps) graph)

        inDeps : String -> String -> Deps -> Bool
        inDeps depId ruleId deps =
            Dict.get ruleId deps
                |> Maybe.map (Dict.member depId)
                |> Maybe.withDefault False

        buildFilteredGraph rule depId pathLength deps =
            if inDeps depId rule deps then
                deps

            else
                depsForRule depId
                    |> Dict.foldl (buildFilteredGraph depId) (addDep depId rule pathLength deps)
    in
    -- get all deps for selected rule
    -- for each one, add to accumulated filtered deps graph
    -- and recur
    depsForRule selectedRuleId
        |> Dict.foldl (buildFilteredGraph selectedRuleId) (Dict.singleton "__start__" Dict.empty)


update msg model =
    case msg of
        SelectRule ruleId ->
            let
                newModel =
                    { model | selectedRule = ruleId }
            in
            ( newModel, drawGraph <| toDOT model.rules <| highlightPathsToRule ruleId model.deps )


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


toDOT : Rules -> Deps -> String
toDOT rules graph =
    let
        color i =
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

        weight i =
            case i of
                0 ->
                    "9"

                1 ->
                    "6"

                2 ->
                    "3"

                _ ->
                    "1"

        -- sorts by path length, the "normalizes" the values
        -- ex: 4, 7, 3, 7, 8 -> 1, 2, 3, 3, 4
        rank : Edge -> List ( String, Int )
        rank edge =
            -- TODO optimize?
            edge
                |> Dict.toList
                |> List.sortBy Tuple.second
                |> List.groupWhile (\( _, a ) ( _, b ) -> a == b)
                -- [(1, [1,1]), (2,[])]
                |> List.map (\( x, xs ) -> x :: xs)
                -- [[1,1,1], [2]]
                |> List.indexedMap (\i group -> List.map (Tuple.mapSecond (always i)) group)
                |> List.concat

        buildEdge rule deps =
            deps
                |> rank
                |> List.map
                    (\( from, i ) ->
                        "\""
                            ++ (from ++ "\" -> \"" ++ rule ++ "\" ")
                            ++ ("[penwidth=" ++ weight i)
                            ++ (", color=" ++ color i)
                            ++ "]\n"
                    )
                |> String.join ""

        allDeps =
            Dict.foldl
                (\_ deps ids ->
                    Dict.foldl
                        (\depId _ acc -> Set.insert depId acc)
                        ids
                        deps
                )
                Set.empty
                graph

        isStart _ deps =
            Dict.isEmpty deps

        isTexture key _ =
            Dict.get key rules
                |> Maybe.map (.changes >> List.isEmpty)
                |> Maybe.withDefault False

        isEnd key _ =
            -- TODO this doesn't always trigger, because it will be a dep to a rule with no conditions
            not <| Set.member key allDeps

        nodeAttrs key deps =
            if isStart key deps then
                "style=filled, fontcolor=white, color=green shape=box, fontsize=20"

            else if isEnd key deps then
                "style=filled, fontcolor=white, color=red, shape=box, fontsize=20"

            else if isTexture key deps then
                "style=filled, color=lightblue"

            else
                ""

        nodes =
            Dict.toList graph
                |> List.foldl (\( key, deps ) acc -> "\"" ++ key ++ "\" [" ++ nodeAttrs key deps ++ "]\n" ++ acc) "\n"

        edges =
            graph
                |> Dict.foldl
                    (\rule deps acc ->
                        acc ++ buildEdge rule deps
                    )
                    ""
    in
    "digraph G {\n"
        ++ "node [style=filled]"
        ++ edges
        ++ nodes
        ++ "\n}"



-- TODO add any rules that aren't in the graph in orange
-- TODO make work with selected rule
-- TODO highlight the selected node in the graph
