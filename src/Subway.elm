module Subway exposing
    ( Map
    , connections
    , getStation
    , graphViz
    , init
    , nextStop
    )

import Dict
import Graph exposing (..)
import Graph.DOT as Graph exposing (..)
import IntDict
import List.Extra as List


type Map station line
    = Map (Graph station (Connection line station))


type alias Connection line station =
    List ( line, station )



-- TODO change edges to just have a line (because there's no gurantee that each semgment will have the same terminus
-- then derive all of the stations (and the staring and ending points) from the graph
-- might not even need to make a track go in both directions?


init :
    (station -> Int)
    -> List station
    -> List ( line, List station )
    -> Map station line
init stationToId stations lines =
    let
        toNode station =
            Node (stationToId station) station

        toEdge : station -> station -> line -> station -> Edge ( line, station )
        toEdge from to line direction =
            Edge (stationToId from) (stationToId to) ( line, direction )

        buildEdges : ( line, List station ) -> List (Edge ( line, station ))
        buildEdges ( line, stops ) =
            case List.last stops of
                Nothing ->
                    []

                Just finalStop ->
                    let
                        makeEdge currentStop ( maybePreviousStop, acc ) =
                            case maybePreviousStop of
                                Nothing ->
                                    ( Just currentStop, acc )

                                Just previousStop ->
                                    ( Just currentStop, toEdge previousStop currentStop line finalStop :: acc )
                    in
                    List.foldl makeEdge ( Nothing, [] ) stops
                        |> Tuple.second

        goBothDirections : ( line, List station ) -> List ( line, List station )
        goBothDirections ( line, stops ) =
            [ ( line, stops ), ( line, List.reverse stops ) ]

        mergedLines :
            List ( line, List station )
            -> List (Edge (Connection line station))
        mergedLines lines_ =
            lines_
                |> List.concatMap goBothDirections
                |> List.concatMap buildEdges
                |> List.sortWith ordEdge
                |> List.groupWhile eqEdge
                |> List.map (\( h, t ) -> h :: t)
                |> List.concatMap (List.foldl mergeEdges [])

        ordEdge a b =
            if a.from == b.from then
                compare a.to b.to

            else
                compare a.from b.from

        eqEdge a b =
            a.from == b.from && a.to == b.to

        -- mergeEdges :
        --     Edge (line, station)
        --     -> List (Edge (line, station))
        --     -> List (Edge (line, station))
        mergeEdges new merged =
            case merged of
                [] ->
                    [ { from = new.from, to = new.to, label = [ new.label ] } ]

                existing :: _ ->
                    [ { from = existing.from, to = existing.to, label = new.label :: existing.label } ]
    in
    Map <| Graph.fromNodesAndEdges (List.map toNode stations) <| mergedLines lines


getStation : Map station line -> Int -> Maybe station
getStation (Map map) id =
    Graph.get id map
        |> Maybe.map (.node >> .label)


connections : Map station line -> Int -> List ( line, station )
connections (Map map) stationId =
    let
        toTrains lines =
            lines
                |> IntDict.values
                |> List.concat

        toConnections context =
            toTrains context.outgoing
    in
    Graph.get stationId map
        |> Maybe.map toConnections
        |> Maybe.withDefault []


nextStop : Map station line -> ( line, station ) -> Int -> Maybe station
nextStop (Map graph) connection currentStationId =
    let
        findNextStop context =
            context.outgoing
                |> IntDict.foldl
                    (\to lines acc ->
                        if List.member connection lines then
                            Just to

                        else
                            acc
                    )
                    Nothing
                |> Maybe.andThen (\a -> Graph.get a graph)
                |> Maybe.map (.node >> .label)
    in
    Graph.get currentStationId graph |> Maybe.andThen findNextStop


graphViz : (station -> String) -> (line -> String) -> Map station line -> String
graphViz stationToString lineToString (Map graph) =
    let
        -- use dot, very loopy
        graphStyles =
            { defaultStyles
                | rankdir = Graph.LR
                , graph = "nodesep=1"
                , node = "shape=box, style=rounded"
                , edge = "penwidth=2"
            }

        -- use dot, more angular, collapses some lines
        graphStyles2 =
            { defaultStyles
                | rankdir = Graph.LR
                , graph = "nodesep=0.5, splines=false"
                , node = "shape=box, style=rounded"
                , edge = "penwidth=2, weight=1"
            }

        -- use circo style, most clear, hard to tell which labels go to which lines
        graphStyles3 =
            { defaultStyles
                | rankdir = Graph.LR
                , graph = "nodesep=0.3, mindist=4"
                , node = "shape=box, style=rounded"
                , edge = "penwidth=2"
            }
    in
    Graph.outputWithStylesAndAttributes graphStyles3
        (\n -> Dict.fromList [ ( "label", stationToString n ) ])
        (\e -> Dict.fromList [ ( "label", String.join " / " <| List.map (Tuple.first >> lineToString) e ) ])
        graph
