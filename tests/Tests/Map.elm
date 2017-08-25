module Tests.Map exposing (all)

import Map exposing (..)
import ElmTest.Extra exposing (..)
import Expect
import Fuzz exposing (..)


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


all : ElmTest.Extra.Test
all =
    describe "Map"
        [ describe "connectingTrains"
            [ test "mid-line" <|
                \() ->
                    Expect.equal (connectingTrains Map.map Central) <|
                        [ Train Green InComing
                        , Train Yellow OutGoing
                        , Train Green OutGoing
                        ]
            , test "mid-line 2" <|
                \() ->
                    Expect.equal (connectingTrains Map.map Market) <|
                        [ Train Yellow InComing
                        , Train Red InComing
                        , Train Yellow OutGoing
                        , Train Red OutGoing
                        ]
            , test "terminal 1" <|
                \() ->
                    Expect.equal (connectingTrains Map.map EastEnd) <|
                        [ Train Green InComing
                        , Train Yellow InComing
                        , Train Red InComing
                        ]
            , test "terminal 2" <|
                \() ->
                    Expect.equal (connectingTrains Map.map WestEnd) <|
                        [ Train Green OutGoing
                        , Train Red OutGoing
                        ]
            ]
        ]
