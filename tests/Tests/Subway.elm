module Tests.Subway exposing (all)

import Expect
import Graph
import Subway exposing (..)
import Test exposing (..)


type Line
    = Red
    | Blue
    | Green


type Station
    = Central
    | Market
    | WestEnd
    | EastEnd


stationToId : Station -> Int
stationToId station =
    case station of
        Central ->
            1

        Market ->
            2

        EastEnd ->
            3

        WestEnd ->
            4


stationToName : Station -> String
stationToName station =
    case station of
        Central ->
            "Central"

        Market ->
            "Market"

        EastEnd ->
            "EastEnd"

        WestEnd ->
            "WestEnd"


lineToName : Line -> String
lineToName line =
    case line of
        Red ->
            "Red"

        Green ->
            "Green"

        Blue ->
            "Blue"


lineToId : Line -> Int
lineToId line =
    case line of
        Red ->
            1

        Green ->
            2

        Blue ->
            3


redLine : ( Line, List Station )
redLine =
    ( Red, [ WestEnd, Market, EastEnd ] )


greenLine : ( Line, List Station )
greenLine =
    ( Green, [ WestEnd, Central, EastEnd, Market ] )


blueLine : ( Line, List Station )
blueLine =
    ( Blue, [ Central, Market, EastEnd ] )


map : Map Station Line
map =
    Subway.init stationToId [ redLine, greenLine, blueLine ]



{-

                                    red / green / blue
                         / ----------------------------- o EastEnd
                       / / --------------------------- / |
                     / /-----------------------------/   |
                   / /                                   |
            Market o                                     |
                   | \                   / ------------- /
                   |   \  blue line    /    green line
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
   blue line - Central, Market, EastEnd





-}


all : Test
all =
    let
        graphViz =
            Subway.graphViz
                stationToName
                lineToName
                map
                ++ "\n"

        logGraphViz =
            Debug.log graphViz "Copy and paste into http://viz-js.com/"
    in
    describe "Subway"
        [ describe "init"
            [ test "correctly builds graph" <|
                \() ->
                    Expect.equal graphViz """digraph G {
  rankdir=LR
  graph [nodesep=0.3, mindist=4]
  node [shape=box, style=rounded]
  edge [penwidth=2]

  1 -> 2 [label="Blue"]
  1 -> 3 [label="Green"]
  2 -> 3 [label="Blue / Red"]
  3 -> 2 [label="Green"]
  4 -> 1 [label="Green"]
  4 -> 2 [label="Red"]

  1 [label="Central"]
  2 [label="Market"]
  3 [label="EastEnd"]
  4 [label="WestEnd"]
}
"""
            ]
        , describe "connectingTrains" <|
            let
                config =
                    { stationToId = stationToId, lineToId = lineToId }
            in
            [ test "Central" <|
                \() ->
                    Expect.equal (connections config map Central) <|
                        [ Blue, Green ]
            , test "Market" <|
                \() ->
                    Expect.equal (connections config map Market) <|
                        [ Blue, Red, Green ]
            , test "EastEnd" <|
                \() ->
                    Expect.equal (connections config map EastEnd) <|
                        [ Green, Blue, Red ]
            , test "WestEnd" <|
                \() ->
                    Expect.equal (connections config map WestEnd) <|
                        [ Green, Red ]
            ]
        ]
