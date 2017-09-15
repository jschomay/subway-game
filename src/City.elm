module City exposing (..)

import Subway exposing (..)
import Color exposing (..)


type Line
    = Red
    | Yellow
    | Green


type Station
    = Central
    | Market
    | WestEnd
    | EastEnd


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
        Central ->
            { id = 1
            , name = "Central"
            }

        Market ->
            { id = 2
            , name = "Market"
            }

        EastEnd ->
            { id = 3
            , name = "EastEnd"
            }

        WestEnd ->
            { id = 4
            , name = "WestEnd"
            }


lineInfo : Line -> LineInfo
lineInfo line =
    case line of
        Red ->
            { number = 1
            , name = "Red"
            , color = red
            }

        Green ->
            { number = 2
            , name = "Green"
            , color = green
            }

        Yellow ->
            { number = 3
            , name = "Yellow"
            , color = yellow
            }


stations : List Station
stations =
    [ Central, Market, WestEnd, EastEnd ]


redLine : ( Line, List Station )
redLine =
    ( Red, [ WestEnd, Market, EastEnd ] )


greenLine : ( Line, List Station )
greenLine =
    ( Green, [ WestEnd, Central, EastEnd ] )


yellowLine : ( Line, List Station )
yellowLine =
    ( Yellow, [ Central, Market, EastEnd ] )


map : Map Station Line
map =
    Subway.init (stationInfo >> .id) stations [ redLine, greenLine, yellowLine ]
