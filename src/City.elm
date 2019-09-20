module City exposing
    ( Line(..)
    , LineInfo
    , Map
    , Station
    , StationInfo
    , fullMap
    , lineInfo
    , mapImage
    , stationInfo
    , stations
    )

import Color exposing (..)
import Dict exposing (Dict)
import SubwaySimple


type alias Map =
    SubwaySimple.Map Line Station


type Line
    = Red
    | Yellow
    | Green


type alias Station =
    String


type alias StationInfo =
    { name : String
    }


stations : Dict Station StationInfo
stations =
    Dict.fromList
        [ ( "MetroCenter", { name = "Metro Center" } )
        , ( "FederalTriangle", { name = "Federal Triangle" } )
        , ( "MacArthursPark", { name = "MacArthur's Park" } )
        , ( "ChurchStreet", { name = "Church Street" } )
        , ( "SpringHill", { name = "Spring Hill" } )
        , ( "TwinBrooks", { name = "Twin Brooks" } )
        , ( "CapitolHeights", { name = "Capitol Heights" } )
        , ( "EastMulberry", { name = "East Mulberry" } )
        , ( "WestMulberry", { name = "West Mulberry" } )
        , ( "Burlington", { name = "Burlington" } )
        , ( "SamualStreet", { name = "Samual Street" } )
        ]


stationInfo : Station -> StationInfo
stationInfo station =
    Dict.get station stations
        |> Maybe.withDefault { name = "ERRORR getting station: " ++ station }


type alias LineInfo =
    { name : String
    , id : String
    , number : Int
    , color : Color
    , stations : List Station
    }


lineInfo : Line -> LineInfo
lineInfo line =
    case line of
        Red ->
            { number = 1
            , name = "Red Line"
            , id = "redLine"
            , color = red
            , stations =
                [ "WestMulberry"
                , "EastMulberry"
                , "ChurchStreet"
                , "MetroCenter"
                , "FederalTriangle"
                , "SpringHill"
                , "TwinBrooks"
                ]
            }

        Yellow ->
            { number = 2
            , name = "Yellow Line"
            , id = "yellowLine"
            , color = yellow
            , stations =
                [ "MetroCenter"
                , "FederalTriangle"
                , "CapitolHeights"
                , "MacArthursPark"
                ]
            }

        Green ->
            { number = 3
            , name = "Green Line"
            , id = "greenLine"
            , color = green
            , stations =
                [ "Burlington"
                , "SamualStreet"
                , "CapitolHeights"
                , "FederalTriangle"
                ]
            }


stationsOnLine : Line -> ( Line, List Station )
stationsOnLine line =
    ( line, lineInfo line |> .stations )


fullMap : Map
fullMap =
    [ Red, Green, Yellow ]
        |> List.map stationsOnLine


mapImage : String
mapImage =
    "map-red-yellow-green.png"
