module Tests.Subway exposing (all)

import Subway exposing (..)
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
-- TODO, after limiting exports these tests need to be refactored to only deal with exposed methods (trainInfo for example)


all : ElmTest.Extra.Test
all =
    describe "Subway"
        [ describe "connectingTrains"
            [ test "mid-line" <|
                \() ->
                    Expect.equal (connectingTrains Subway.fullMap Central) <|
                        [ Train Green InComing True
                        , Train Yellow OutGoing True
                        , Train Green OutGoing True
                        ]
            , test "mid-line 2" <|
                \() ->
                    Expect.equal (connectingTrains Subway.fullMap Market) <|
                        [ Train Yellow InComing True
                        , Train Red InComing True
                        , Train Yellow OutGoing True
                        , Train Red OutGoing True
                        ]
            , test "terminal 1" <|
                \() ->
                    Expect.equal (connectingTrains Subway.fullMap EastEnd) <|
                        [ Train Green InComing True
                        , Train Yellow InComing True
                        , Train Red InComing True
                        ]
            , test "terminal 2" <|
                \() ->
                    Expect.equal (connectingTrains Subway.fullMap WestEnd) <|
                        [ Train Green OutGoing True
                        , Train Red OutGoing True
                        ]
            ]
        , describe "nextStop"
            [ test "incoming" <|
                \() ->
                    Expect.equal (Just Central) <|
                        nextStop fullMap (Train Yellow InComing True) Market
            , test "outgoing" <|
                \() ->
                    Expect.equal (Just EastEnd) <|
                        nextStop fullMap (Train Yellow OutGoing True) Market
            , test "end of line" <|
                \() ->
                    Expect.equal Nothing <|
                        nextStop fullMap (Train Yellow InComing True) Central
            ]
        ]
