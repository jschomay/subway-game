module Subway exposing
    ( Line(..)
    , LineInfo
    , Map
    , Station
    , connectingLines
    , fullMap
    , idToLine
    , lineInfo
    , mapImage
    )

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


type alias LineInfo =
    { name : String
    , id : String
    , number : Int
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
            , stations =
                [ "IRIS_LAKE"
                , "NORWOOD"
                , "ST_MARKS"
                , "UNIVERSITY"
                , "SPRING_HILL"
                , "CAPITOL_HEIGHTS"
                , "SEVENTY_THIRD_STREET"
                , "ONE_HUNDRED_FORTH_STREET"
                ]
            }

        Blue ->
            { number = 5
            , name = "Blue Line"
            , id = "BLUE_LINE"
            , stations =
                [ "ONE_HUNDRED_FORTH_STREET"
                , "SEVENTY_THIRD_STREET"
                , "FORTY_SECOND_STREET"
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
