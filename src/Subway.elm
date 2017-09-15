module Subway
    exposing
        ( Map
        , init
        , connections
        , nextStop
        , graphViz
        )

import Graph exposing (..)
import Graph.GraphViz as Graph exposing (..)
import IntDict
import List.Extra as List


type Map station line
    = Map (Graph station (List ( line, station )))


init :
    (station -> Int)
    -> List station
    -> List ( line, List station )
    -> Map station line
init stationToId stations lines =
    let
        toNode station =
            Node (stationToId station) station

        toEdge from to line direction =
            Edge (stationToId from) (stationToId to) ( line, direction )

        buildEdges ( line, stops ) =
            case List.last stops of
                Nothing ->
                    []

                Just finalStop ->
                    let
                        makeEdge currentStop ( previousStop, acc ) =
                            case previousStop of
                                Nothing ->
                                    ( Just currentStop, acc )

                                Just previousStop ->
                                    ( Just currentStop, (toEdge previousStop currentStop line finalStop) :: acc )
                    in
                        List.foldl makeEdge ( Nothing, [] ) stops
                            |> Tuple.second

        goBothDirections ( line, stops ) =
            [ ( line, stops ), ( line, List.reverse stops ) ]

        mergedLines =
            lines
                |> List.concatMap goBothDirections
                |> List.concatMap buildEdges
                |> List.sortWith ordEdge
                |> List.groupWhile eqEdge
                |> List.concatMap (List.foldl mergeEdges [])

        ordEdge a b =
            if a.from == b.from then
                compare a.to b.to
            else
                compare a.from b.from

        eqEdge a b =
            a.from == b.from && a.to == b.to

        mergeEdges new merged =
            case merged of
                [] ->
                    [ { new | label = [ new.label ] } ]

                existing :: _ ->
                    [ { existing | label = new.label :: existing.label } ]
    in
        Map <| Graph.fromNodesAndEdges (List.map toNode stations) mergedLines


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
                |> Maybe.andThen (flip Graph.get graph)
                |> Maybe.map (.node >> .label)
    in
        Graph.get currentStationId graph |> Maybe.andThen findNextStop


graphViz : Map station line -> String
graphViz (Map graph) =
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

        colorized ( color, end ) =
            "<FONT COLOR=\"" ++ Basics.toString color ++ "\">" ++ Basics.toString end ++ "</FONT>"
    in
        graph
            |> Graph.mapEdges
                (\e ->
                    { attrs = "label=<" ++ (String.join "<BR/>" <| List.map colorized e) ++ ">" }
                )
            |> Graph.mapNodes (\n -> { text = Basics.toString n, attrs = "" })
            |> Graph.outputWithStylesWithOverrides graphStyles3
