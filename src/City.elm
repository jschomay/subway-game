module City exposing (..)

import Subway exposing (..)
import Color exposing (..)


type Line
    = Red


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


type alias StationInfo =
    { id : Int
    , name : String
    }


type alias LineInfo =
    { name : String
    , number : Int
    , color : Color
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


lineInfo : Line -> LineInfo
lineInfo line =
    case line of
        Red ->
            { number = 1
            , name = "Red Line"
            , color = red
            }


stations : List Station
stations =
    [ MetroCenter
    , FederalTriangle
    , MacArthursPark
    , ChurchStreet
    , SpringHill
    , TwinBrooks
    , CapitolHeights
    , EastMulberry
    , WestMulberry
    ]


redLine : ( Line, List Station )
redLine =
    ( Red
    , [ WestMulberry
      , EastMulberry
      , ChurchStreet
      , MetroCenter
      , FederalTriangle
      , SpringHill
      , TwinBrooks
      ]
    )


map : Map Station Line
map =
    Subway.init (stationInfo >> .id) stations [ redLine ]
