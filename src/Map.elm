module Map exposing (..)

import Color exposing (..)
import Graph exposing (..)
import Graph.GraphViz as Graph exposing (..)
import IntDict
import List.Extra as List


type Direction
    = InComing
    | OutGoing


type Line
    = Red
    | Yellow
    | Green


type Train
    = Train Line Direction


type alias TrainInfo =
    { number : Int, color : Color, terminalStation : Station }


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


trainInfo : Train -> TrainInfo
trainInfo train =
    case train of
        Train Red InComing ->
            { number = 1, color = red, terminalStation = EastEnd }

        Train Red OutGoing ->
            { number = 1, color = red, terminalStation = WestEnd }

        Train Yellow InComing ->
            { number = 2, color = yellow, terminalStation = EastEnd }

        Train Yellow OutGoing ->
            { number = 2, color = yellow, terminalStation = Market }

        Train Green InComing ->
            { number = 3, color = green, terminalStation = Central }

        Train Green OutGoing ->
            { number = 3, color = green, terminalStation = WestEnd }


addStation : Station -> Node Station
addStation station =
    Node (stationId station) station


addLine : Station -> Station -> Line -> Edge Line
addLine from to line =
    Edge (stationId from) (stationId to) line


allStations : List (Node Station)
allStations =
    [ addStation Central
    , addStation Market
    , addStation EastEnd
    , addStation WestEnd
    ]


redLine : List (Edge Line)
redLine =
    [ addLine WestEnd Market Red
    , addLine Market EastEnd Red
    ]


greenLine : List (Edge Line)
greenLine =
    [ addLine WestEnd Central Green
    , addLine Central EastEnd Green
    ]


yellowLine : List (Edge Line)
yellowLine =
    [ addLine Central Market Yellow
    , addLine Market EastEnd Yellow
    ]


fullMap : Map
fullMap =
    map allStations [ redLine, greenLine, yellowLine ]


map : List (Node Station) -> List (List (Edge Line)) -> Map
map stations lines =
    let
        mergedLines =
            List.concat lines
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
        Map <| Graph.fromNodesAndEdges stations mergedLines


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
