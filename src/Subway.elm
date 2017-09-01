module Subway exposing (..)

import Color exposing (..)
import Graph exposing (..)
import Graph.GraphViz as Graph exposing (..)
import IntDict
import List.Extra as List
import Tuple


type Direction
    = InComing
    | OutGoing


type Line
    = Red
    | Yellow
    | Green


type alias LineInfo =
    { line : Line, name : String, number : Int, color : Color, stops : List Station }


type Train
    = Train Line Direction


type alias TrainInfo msg =
    { number : Int, name : String, color : Color, direction : Station, msg : (Train -> msg) -> msg }


type alias StationInfo msg =
    { name : String, connections : List (TrainInfo msg) }


type Station
    = Central
    | Market
    | EastEnd
    | WestEnd


type Map
    = Map (Graph Station (List Line))



{-

                                         red line
                         / ----------------------------- o EastEnd
                       / / --------------------------- / |
                     / /           yellow line           |
                   / /                                   |
            Market o                                     |
                   | \                   / ------------- /
                   |   \               /    green line
        red line   |     \           /
         ---------/        \       /
       /                     \ --- o Central
       |                           |
       |                           |
       |                           |
       |         green line        |
       o ------------------------- /
    WestEnd


   red line - WestEnd, Market, EastEnd
   green line - WestEnd, Central, EastEnd
   yellow line - Central, Market, EastEnd

-}


stationId : Station -> Int
stationId station =
    case station of
        Central ->
            1

        Market ->
            2

        EastEnd ->
            3

        WestEnd ->
            4


stationInfo : Station -> StationInfo msg
stationInfo station =
    (case station of
        Central ->
            "Central"

        Market ->
            "Market"

        EastEnd ->
            "East End"

        WestEnd ->
            "West End"
    )
        |> \name -> { name = name, connections = connectingTrains fullMap station |> List.map trainInfo }


trainInfo : Train -> TrainInfo msg
trainInfo train =
    let
        lastStop stops direction =
            case direction of
                OutGoing ->
                    List.last stops |> Maybe.withDefault Central

                InComing ->
                    List.head stops |> Maybe.withDefault Central

        toInfo lineInfo direction =
            { number = lineInfo.number, name = lineInfo.name, color = lineInfo.color, direction = lastStop lineInfo.stops direction, msg = \msg -> msg train }
    in
        case train of
            Train Red direction ->
                toInfo redLine direction

            Train Yellow direction ->
                toInfo yellowLine direction

            Train Green direction ->
                toInfo greenLine direction


addStation : Station -> Node Station
addStation station =
    Node (stationId station) station


addLine : Station -> Station -> Line -> Edge Line
addLine from to line =
    Edge (stationId from) (stationId to) line


stations : List Station
stations =
    [ Central, Market, EastEnd, WestEnd ]


redLine : LineInfo
redLine =
    { line = Red
    , number = 1
    , name = "Red line"
    , color = red
    , stops = [ WestEnd, Market, EastEnd ]
    }


greenLine : LineInfo
greenLine =
    { line = Green
    , number = 2
    , name = "Green line"
    , color = green
    , stops = [ WestEnd, Central, EastEnd ]
    }


yellowLine : LineInfo
yellowLine =
    { line = Yellow
    , number = 3
    , name = "Yellow line"
    , color = yellow
    , stops = [ Central, Market, EastEnd ]
    }


fullMap : Map
fullMap =
    map stations [ redLine, greenLine, yellowLine ]


map : List Station -> List LineInfo -> Map
map stations lines =
    let
        toEdges : LineInfo -> List (Edge Line)
        toEdges { line, stops } =
            let
                makeEdge stop ( lastStop, acc ) =
                    case lastStop of
                        Nothing ->
                            ( Just stop, acc )

                        Just lastStop ->
                            ( Just stop, (addLine lastStop stop line) :: acc )
            in
                List.foldl makeEdge ( Nothing, [] ) stops
                    |> Tuple.second

        mergedLines =
            List.concatMap toEdges lines
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
        Map <| Graph.fromNodesAndEdges (List.map addStation stations) mergedLines


connectingTrains : Map -> Station -> List Train
connectingTrains (Map map) station =
    let
        toTrains : Direction -> IntDict.IntDict (List Line) -> List Train
        toTrains direction lines =
            lines
                |> IntDict.values
                |> List.concat
                |> List.map (flip Train direction)

        toConnections : NodeContext Station (List Line) -> List Train
        toConnections context =
            toTrains InComing context.incoming ++ toTrains OutGoing context.outgoing
    in
        Graph.get (stationId station) map
            |> Maybe.map toConnections
            |> Maybe.withDefault []


nextStop : Map -> Train -> Station -> Maybe Station
nextStop (Map map) (Train line direction) previousStation =
    let
        findNextStop : NodeContext Station (List Line) -> Maybe Station
        findNextStop context =
            (if direction == InComing then
                context.incoming
             else
                context.outgoing
            )
                |> IntDict.foldl
                    (\to lines acc ->
                        if List.member line lines then
                            Just to
                        else
                            acc
                    )
                    Nothing
                |> Maybe.andThen (flip Graph.get map)
                |> Maybe.map (.node >> .label)
    in
        Graph.get (stationId previousStation) map
            |> Maybe.andThen findNextStop


draw : String
draw =
    let
        graphStyles =
            { defaultStyles
                | rankdir = Graph.LR
                , graph = "nodesep=1"
                , node = "shape=box, style=rounded"
                , edge = "penwidth=2"
            }

        (Map map_) =
            fullMap
    in
        map_
            |> Graph.mapEdges
                (\e ->
                    { attrs = "label=\"" ++ (String.join "\n" <| List.map Basics.toString e) ++ "\"" }
                )
            |> Graph.mapNodes (\n -> { text = Basics.toString n, attrs = "" })
            |> Graph.outputWithStylesWithOverrides graphStyles
