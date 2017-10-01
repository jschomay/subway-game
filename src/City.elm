module City exposing (..)

import Subway exposing (..)
import Color exposing (..)


type Line
    = Red
    | Yellow


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


type MapImage
    = RedMap
    | RedYellowMap


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

        Yellow ->
            { number = 2
            , name = "Yellow Line"
            , color = yellow
            }


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


yellowLine : ( Line, List Station )
yellowLine =
    ( Yellow
    , [ MetroCenter
      , FederalTriangle
      , CapitolHeights
      , MacArthursPark
      ]
    )


map : List ( Line, List Station ) -> Map Station Line
map lines =
    Subway.init (stationInfo >> .id) (List.concatMap Tuple.second lines) lines


mapImage : MapImage -> String
mapImage map =
    case map of
        RedMap ->
            """

  Red Line:

        WestMulberry
             |
             |
        EastMulberry
             |
             |
        ChurchStreet
             |
             |
        MetroCenter
             |
             |
        FederalTriangle
             |
             |
        SpringHill
             |
             |
        TwinBrooks

"""

        RedYellowMap ->
            """

   Red Line:         Yellow Line:

         WestMulberr       MetroCenter
              |                 |
              |                 |
         EastMulberr       FederalTriangle
              |                 |
              |                 |
         ChurchStree       CapitolHeights
              |                 |
              |                 |
         MetroCenter       MacArthursPark
              |
              |
         FederalTria
              |
              |
         SpringHill
              |
              |
         TwinBrooks

"""



-- TODO, undo linking the map to the mapimage because the game might want them to be out of sync, this means
