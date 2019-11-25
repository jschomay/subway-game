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
    | Orange
    | Blue
    | Purple


type alias Station =
    String


type alias StationInfo =
    { name : String
    }


stations : Dict Station StationInfo
stations =
    Dict.fromList
        [ ( "ONE_HUNDRED_FOURTH_STREET", { name = "104th Street" } )
        , ( "FOURTY_SECOND_STREET", { name = "42nd Street" } )
        , ( "SEVENTY_THIRD_STREET", { name = "73rd Street" } )
        , ( "BROADWAY_STREET", { name = "Broadway Street" } )
        , ( "BURLINGTON", { name = "Burlington" } )
        , ( "CAPITOL_HEIGHTS", { name = "Capitol Heights" } )
        , ( "CHURCH_STREET", { name = "Church Street" } )
        , ( "CONVENTION_CENTER", { name = "Convention Center" } )
        , ( "EAST_MULBERRY", { name = "East Mulberry" } )
        , ( "FAIRVIEW", { name = "Fairview" } )
        , ( "HIGHLAND", { name = "Highland" } )
        , ( "IRIS_LAKE", { name = "Iris Lake" } )
        , ( "MACARTHURS_PARK", { name = "MacArthur's Park" } )
        , ( "MUSEUM", { name = "Museum" } )
        , ( "NORWOOD", { name = "Norwood" } )
        , ( "PARK_AVE", { name = "Park Street" } )
        , ( "RIVERSIDE", { name = "Riverside" } )
        , ( "SAMUAL_STREET", { name = "Samual Street" } )
        , ( "SPRING_HILL", { name = "Spring Hill" } )
        , ( "ST_MARKS", { name = "St. Mark's" } )
        , ( "TWIN_BROOKS", { name = "Twin Brooks" } )
        , ( "UNIVERSITY", { name = "University" } )
        , ( "WALTER_HILL", { name = "Walter Hill" } )
        , ( "WESTGATE", { name = "Westgate" } )
        , ( "WEST_MULBERRY", { name = "West Mulberry" } )
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

        "ORANGE_LINE" ->
            Just Orange

        "BLUE_LINE" ->
            Just Blue

        "PURPLE_LINE" ->
            Just Purple

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
                , "ST_MARKS"
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

        Orange ->
            { number = 4
            , name = "Orange Line"
            , id = "ORANGE_LINE"
            , color = orange
            , stations =
                [ "IRIS_LAKE"
                , "NORWOOD"
                , "ST_MARKS"
                , "UNIVERSITY"
                , "SPRING_HILL"
                , "CAPITOL_HEIGHTS"
                , "SEVENTY_THIRD_STREET"
                , "ONE_HUNDRED_FOURTH_STREET"
                ]
            }

        Blue ->
            { number = 5
            , name = "Blue Line"
            , id = "BLUE_LINE"
            , color = blue
            , stations =
                [ "ONE_HUNDRED_FOURTH_STREET"
                , "SEVENTY_THIRD_STREET"
                , "FOURTY_SECOND_STREET"
                , "MUSEUM"
                , "BROADWAY_STREET"
                , "ST_MARKS"
                , "PARK_AVE"
                , "WESTGATE"
                ]
            }

        Purple ->
            { number = 6
            , name = "Purple Line"
            , id = "PURPLE_LINE"
            , color = purple
            , stations =
                [ "HIGHLAND"
                , "FAIRVIEW"
                , "EAST_MULBERRY"
                , "CHURCH_STREET"
                , "MUSEUM"
                , "CONVENTION_CENTER"
                , "UNIVERSITY"
                , "WALTER_HILL"
                ]
            }


stationsOnLine : Line -> ( Line, List Station )
stationsOnLine line =
    ( line, lineInfo line |> .stations )


fullMap : Map
fullMap =
    [ Red, Green, Yellow, Orange, Blue, Purple ]
        |> List.map stationsOnLine


mapImage : String
mapImage =
    "subway-map-full.jpg"


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
