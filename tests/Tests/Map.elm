module Tests.Map exposing (all)

import Map exposing (..)
import ElmTest.Extra exposing (..)
import Expect


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
                    Expect.equal (connectingTrains Map.fullMap Central) <|
                        [ Train Green InComing
                        , Train Yellow OutGoing
                        , Train Green OutGoing
                        ]
            , test "mid-line 2" <|
                \() ->
                    Expect.equal (connectingTrains Map.fullMap Market) <|
                        [ Train Yellow InComing
                        , Train Red InComing
                        , Train Yellow OutGoing
                        , Train Red OutGoing
                        ]
            , test "terminal 1" <|
                \() ->
                    Expect.equal (connectingTrains Map.fullMap EastEnd) <|
                        [ Train Green InComing
                        , Train Yellow InComing
                        , Train Red InComing
                        ]
            , test "terminal 2" <|
                \() ->
                    Expect.equal (connectingTrains Map.fullMap WestEnd) <|
                        [ Train Green OutGoing
                        , Train Red OutGoing
                        ]
            ]
        , describe "nextStop"
            [ test "incoming" <|
                \() ->
                    Expect.equal (Just Central) <|
                        nextStop fullMap (Train Yellow InComing) Market
            , test "outgoing" <|
                \() ->
                    Expect.equal (Just EastEnd) <|
                        nextStop fullMap (Train Yellow OutGoing) Market
            , test "end of line" <|
                \() ->
                    Expect.equal Nothing <|
                        nextStop fullMap (Train Yellow InComing) Central
            ]
        ]
