module Subway exposing
    ( Map
    , connections
    , getStation
    , graphViz
    , init
    )

-- TODO will need to add `line -> all serviced stations` (maybe with connections at each station?) used to make the line map to choose which station to go to

import Dict
import Graph exposing (..)
import Graph.DOT as Graph exposing (..)
import IntDict
import List.Extra as List


type
    Map stationId lineId
    -- the edge lables hold all of the "overlapping" lines between 2 stations
    = Map (Graph stationId (List lineId))


type alias StationsAlongLine lineId stationId =
    -- all of the stations connected by a line
    ( lineId, List stationId )



-- TODO change edges to just have a line (because there's no gurantee that each semgment will have the same terminus
-- then derive all of the stations (and the staring and ending points) from the graph
-- might not even need to make a track go in both directions?


init :
    (station -> Int)
    -> List station
    -> List (StationsAlongLine line station)
    -> Map station line
init stationToId stations lines =
    let
        -- TODO derive stations from lines
        toNode station =
            Node (stationToId station) station

        lineToEdges : StationsAlongLine line station -> List (Edge line)
        lineToEdges ( line, stops ) =
            let
                makeEdge currentStop ( maybePreviousStop, acc ) =
                    case maybePreviousStop of
                        Nothing ->
                            ( Just currentStop, acc )

                        Just previousStop ->
                            ( Just currentStop, Edge previousStop currentStop line :: acc )
            in
            stops
                |> List.map stationToId
                |> List.foldl makeEdge ( Nothing, [] )
                |> Tuple.second

        makeEdges :
            List (StationsAlongLine line station)
            -> List (Edge (List line))
        makeEdges lines_ =
            lines_
                |> List.concatMap lineToEdges
                -- would be done here, but different lines might connect the same 2 stations, so we need to "merge" overlapping edges
                |> List.sortWith ordEdge
                -- |> List.groupWhile eqEdge
                -- groupWhile returns a "non-empty list" which looks like `(a, List a)`, so we need to turn that into a "normal" list
                -- |> List.map (\( h, t ) -> h :: t)
                -- |> List.concatMap (List.foldl mergeEdges [])
                |> List.foldl mergeEdges []

        ordEdge a b =
            if a.from == b.from then
                compare a.to b.to

            else
                compare a.from b.from

        eqEdge a b =
            a.from == b.from && a.to == b.to

        mergeEdges :
            Edge line
            -> List (Edge (List line))
            -> List (Edge (List line))
        mergeEdges newEdge acc =
            -- if the edge connecs the same stations as the previous edge (given they are sorted), throw it out, but append its label (line id) to the label of the previous one (list of line ids)
            case acc of
                [] ->
                    -- wrap lable in list
                    [ { from = newEdge.from, to = newEdge.to, label = [ newEdge.label ] } ]

                prevEdge :: rest ->
                    if eqEdge prevEdge newEdge then
                        -- throw out new edge, adjust label of previous edge
                        { from = prevEdge.from, to = prevEdge.to, label = newEdge.label :: prevEdge.label } :: rest

                    else
                        -- add new edge and wrap label in list
                        { from = newEdge.from, to = newEdge.to, label = [ newEdge.label ] } :: acc

        -- TODO remove this version (and calls to it above, plus grouping) if above works
        -- mergeEdges :
        --     Edge line
        --     -> List (Edge (List line))
        --     -> List (Edge (List line))
        -- mergeEdges new merged =
        --     case merged of
        --         [] ->
        --             [ { from = new.from, to = new.to, label = [ new.label ] } ]
        --         existing :: _ ->
        --             [ { from = existing.from, to = existing.to, label = new.label :: existing.label } ]
    in
    Map <| Graph.fromNodesAndEdges (List.map toNode stations) <| makeEdges lines


getStation : Map station line -> Int -> Maybe station
getStation (Map map) id =
    Graph.get id map
        |> Maybe.map (.node >> .label)



{- | Given a map and a station, get all of the lines that stop at that station.

   Also requires some config helpers
-}


connections :
    { stationToId : station -> Int
    , lineToId : line -> comparable
    }
    -> Map station line
    -> station
    -> List line
connections { stationToId, lineToId } (Map map) station =
    let
        toTrains lines =
            lines
                |> IntDict.values
                |> List.concat
                |> List.uniqueBy lineToId

        toConnections context =
            toTrains <| IntDict.union context.outgoing context.incoming
    in
    Graph.get (stationToId station) map
        |> Maybe.map toConnections
        |> Maybe.withDefault []


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
        (\e -> Dict.fromList [ ( "label", String.join " / " <| List.map lineToString e ) ])
        graph
