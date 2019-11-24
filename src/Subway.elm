module Subway exposing
    ( Line(..)
    , LineInfo
    , Map
    , Station
    , StationInfo
    , connectingLines
    , fullMap
    , idToLine
    , lineInfo
    , mapImage
    , stationInfo
    , stations
    )

import Color exposing (..)
import Dict exposing (Dict)


{-| A list of lines with all of the stops on each line
-}
type alias Map =
    List ( Line, List Station )


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
        [ ( "BROADWAY_STREET", { name = "Broadway Street" } )
        , ( "CONVENTION_CENTER", { name = "Convention Center" } )
        , ( "MACARTHURS_PARK", { name = "MacArthur's Park" } )
        , ( "CHURCH_STREET", { name = "Church Street" } )
        , ( "SPRING_HILL", { name = "Spring Hill" } )
        , ( "TWIN_BROOKS", { name = "Twin Brooks" } )
        , ( "CAPITOL_HEIGHTS", { name = "Capitol Heights" } )
        , ( "EAST_MULBERRY", { name = "East Mulberry" } )
        , ( "WEST_MULBERRY", { name = "West Mulberry" } )
        , ( "BURLINGTON", { name = "Burlington" } )
        , ( "SAMUAL_STREET", { name = "Samual Street" } )
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


idToLine : String -> Maybe Line
idToLine id =
    case id of
        "RED_LINE" ->
            Just Red

        "YELLOW_LINE" ->
            Just Yellow

        "GREEN_LINE" ->
            Just Green

        _ ->
            Nothing


lineInfo : Line -> LineInfo
lineInfo line =
    case line of
        Red ->
            { number = 1
            , name = "Red Line"
            , id = "RED_LINE"
            , color = red
            , stations =
                [ "WEST_MULBERRY"
                , "EAST_MULBERRY"
                , "CHURCH_STREET"
                , "BROADWAY_STREET"
                , "CONVENTION_CENTER"
                , "SPRING_HILL"
                , "TWIN_BROOKS"
                ]
            }

        Yellow ->
            { number = 2
            , name = "Yellow Line"
            , id = "YELLOW_LINE"
            , color = yellow
            , stations =
                [ "RIVERSIDE"
                , "BROADWAY_STREET"
                , "CONVENTION_CENTER"
                , "CAPITOL_HEIGHTS"
                , "MACARTHURS_PARK"
                ]
            }

        Green ->
            { number = 3
            , name = "Green Line"
            , id = "GREEN_LINE"
            , color = green
            , stations =
                [ "BURLINGTON"
                , "SAMUAL_STREET"
                , "CAPITOL_HEIGHTS"
                , "CONVENTION_CENTER"
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
    "map-red-yellow-green.jpg"


{-| Returns all lines servicing the supplied station. Does not specify an order
(can't return a `Set` because `line` isn't comparable).
-}
connectingLines : Map -> Station -> List Line
connectingLines map currentStation =
    List.foldl
        (\( line, stations_ ) acc ->
            if List.member currentStation stations_ then
                line :: acc

            else
                acc
        )
        []
        map
