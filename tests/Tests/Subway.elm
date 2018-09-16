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


stations : List Station
stations =
    [ Central, Market, WestEnd, EastEnd ]


redLine : ( Line, List Station )
redLine =
    ( Red, [ WestEnd, Market, EastEnd ] )


greenLine : ( Line, List Station )
greenLine =
    ( Green, [ WestEnd, Central, EastEnd ] )


blueLine : ( Line, List Station )
blueLine =
    ( Blue, [ Central, Market, EastEnd ] )


map : Map Station Line
map =
    Subway.init stationToId stations [ redLine, greenLine, blueLine ]



{-

                                         red line
                         / ----------------------------- o EastEnd
                       / / --------------------------- / |
                     / /           blue line             |
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
  1 -> 4 [label="Green"]
  2 -> 1 [label="Blue"]
  2 -> 3 [label="Blue / Red"]
  2 -> 4 [label="Red"]
  3 -> 1 [label="Green"]
  3 -> 2 [label="Blue / Red"]
  4 -> 1 [label="Green"]
  4 -> 2 [label="Red"]

  1 [label="Central"]
  2 [label="Market"]
  3 [label="EastEnd"]
  4 [label="WestEnd"]
}
"""
            ]
        , describe "connectingTrains"
            [ test "Central" <|
                \() ->
                    Expect.equal (connections map (stationToId Central)) <|
                        [ ( Blue, EastEnd )
                        , ( Green, EastEnd )
                        , ( Green, WestEnd )
                        ]
            , test "Market" <|
                \() ->
                    Expect.equal (connections map (stationToId Market)) <|
                        [ ( Blue, Central )
                        , ( Blue, EastEnd )
                        , ( Red, EastEnd )
                        , ( Red, WestEnd )
                        ]
            , test "EastEnd" <|
                \() ->
                    Expect.equal (connections map (stationToId EastEnd)) <|
                        [ ( Green, WestEnd )
                        , ( Blue, Central )
                        , ( Red, WestEnd )
                        ]
            , test "WestEnd" <|
                \() ->
                    Expect.equal (connections map (stationToId WestEnd)) <|
                        [ ( Green, EastEnd )
                        , ( Red, EastEnd )
                        ]
            ]
        , describe "nextStop"
            [ test "midline" <|
                \() ->
                    Expect.equal (Just Central) <|
                        nextStop map ( Blue, Central ) (stationToId Market)
            , test "midline2" <|
                \() ->
                    Expect.equal (Just Market) <|
                        nextStop map ( Blue, Central ) (stationToId EastEnd)
            , test "end of line" <|
                \() ->
                    Expect.equal Nothing <|
                        nextStop map ( Blue, Central ) (stationToId Central)
            , test "invalid" <|
                \() ->
                    Expect.equal Nothing <|
                        nextStop map ( Blue, Central ) (stationToId WestEnd)
            ]
        ]
