module Tests.Subway exposing (all)

import Subway exposing (..)
import ElmTest.Extra exposing (..)
import Expect


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


all : ElmTest.Extra.Test
all =
    describe "Subway"
        [ describe "init"
            [ test "correctly builds graph" <|
                \() ->
                    let
                        x =
                            Debug.log (Subway.graphViz map ++ "\n") "Copy and paste into http://viz-js.com/"
                    in
                        Expect.equal (Subway.graphViz map) """digraph G {
  rankdir=LR
  graph [nodesep=0.3, mindist=4]
  node [shape=box, style=rounded]
  edge [penwidth=2]

  "Central" -> "Market" [label=<<FONT COLOR="Blue">EastEnd</FONT>>]
  "Central" -> "EastEnd" [label=<<FONT COLOR="Green">EastEnd</FONT>>]
  "Central" -> "WestEnd" [label=<<FONT COLOR="Green">WestEnd</FONT>>]
  "Market" -> "Central" [label=<<FONT COLOR="Blue">Central</FONT>>]
  "Market" -> "EastEnd" [label=<<FONT COLOR="Blue">EastEnd</FONT><BR/><FONT COLOR="Red">EastEnd</FONT>>]
  "Market" -> "WestEnd" [label=<<FONT COLOR="Red">WestEnd</FONT>>]
  "EastEnd" -> "Central" [label=<<FONT COLOR="Green">WestEnd</FONT>>]
  "EastEnd" -> "Market" [label=<<FONT COLOR="Blue">Central</FONT><BR/><FONT COLOR="Red">WestEnd</FONT>>]
  "WestEnd" -> "Central" [label=<<FONT COLOR="Green">EastEnd</FONT>>]
  "WestEnd" -> "Market" [label=<<FONT COLOR="Red">EastEnd</FONT>>]

  "Central"
  "Market"
  "EastEnd"
  "WestEnd"
}"""
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
