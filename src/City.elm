module City exposing
    ( Line(..)
    , LineInfo
    , Map
    , MapImage(..)
    , Station(..)
    , StationInfo
    , allLines
    , config
    , fullMap
    , lineInfo
    , map
    , mapImage
    , mapLines
    , stationInfo
    )

import Color exposing (..)
import Subway exposing (..)


type alias Map =
    Subway.Map Station Line


type Line
    = Red
    | Yellow
    | Green


type Station
    = MetroCenter
    | FederalTriangle
    | MacArthursPark
    | ChurchStreet
    | SpringHill
    | TwinBrooks
    | CapitolHeights
    | EastMulberry
    | WestMulberry
    | Burlington
    | SamualStreet


type MapImage
    = RedMap
    | RedYellowMap
    | RedYellowGreenMap


type alias StationInfo =
    { id : Int
    , name : String
    }


type alias LineInfo =
    { name : String
    , number : Int
    , color : Color
    , stations : List Station
    }


stationInfo : Station -> StationInfo
stationInfo station =
    case station of
        MetroCenter ->
            { id = 1
            , name = "Metro Center"
            }

        FederalTriangle ->
            { id = 2
            , name = "Federal Triangle"
            }

        MacArthursPark ->
            { id = 3
            , name = "MacArthur's Park"
            }

        ChurchStreet ->
            { id = 4
            , name = "Church Street"
            }

        SpringHill ->
            { id = 5
            , name = "Spring Hill"
            }

        TwinBrooks ->
            { id = 6
            , name = "Twin Brooks"
            }

        CapitolHeights ->
            { id = 7
            , name = "Capitol Heights"
            }

        EastMulberry ->
            { id = 8
            , name = "East Mulberry"
            }

        WestMulberry ->
            { id = 9
            , name = "West Mulberry"
            }

        Burlington ->
            { id = 10
            , name = "Burlington"
            }

        SamualStreet ->
            { id = 11
            , name = "Samual Street"
            }


lineInfo : Line -> LineInfo
lineInfo line =
    case line of
        Red ->
            { number = 1
            , name = "Red Line"
            , color = red
            , stations =
                [ WestMulberry
                , EastMulberry
                , ChurchStreet
                , MetroCenter
                , FederalTriangle
                , SpringHill
                , TwinBrooks
                ]
            }

        Yellow ->
            { number = 2
            , name = "Yellow Line"
            , color = yellow
            , stations =
                [ MetroCenter
                , FederalTriangle
                , CapitolHeights
                , MacArthursPark
                ]
            }

        Green ->
            { number = 3
            , name = "Green Line"
            , color = green
            , stations =
                [ Burlington
                , SamualStreet
                , CapitolHeights
                , FederalTriangle
                ]
            }


config : Subway.Config Station Line
config =
    { stationToId = stationInfo >> .id
    , lineToId = lineInfo >> .number
    }


stationsOnLine : Line -> ( Line, List Station )
stationsOnLine line =
    ( line, lineInfo line |> .stations )


allLines : List Line
allLines =
    [ Red, Yellow, Green ]


fullMap : Map
fullMap =
    map allLines


map : List Line -> Map
map lines =
    Subway.init (stationInfo >> .id) (List.map stationsOnLine lines)


mapLines : Int -> List Line
mapLines level =
    case level of
        1 ->
            [ Red ]

        2 ->
            [ Red, Yellow ]

        3 ->
            [ Red, Yellow, Green ]

        _ ->
            [ Red, Yellow, Green ]


mapImage : Int -> String
mapImage level =
    case level of
        1 ->
            "map-red.png"

        2 ->
            "map-red-yellow.png"

        3 ->
            "map-red-yellow-green.png"

        _ ->
            "map-red-yellow-green.png"
