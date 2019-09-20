module Views.Station.Platform exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import SubwaySimple
import Views.Shared as Shared
import Views.Station.Connections as Connections


{-| shows line map for a line
-}
view : City.Map -> Station -> Line -> Html Msg
view map currentStation line =
    let
        lineInfo =
            City.lineInfo line

        lineInfoView =
            div [ class "Line_map__info" ]
                [ Connections.byLine line
                , text <| lineInfo.name
                ]

        connections : City.Station -> List City.Line
        connections station =
            SubwaySimple.connections map station
                |> List.sortBy (City.lineInfo >> .number)

        stopView transferLine station =
            div
                [ class "Stop"
                , onClick <|
                    if station /= currentStation then
                        BoardTrain line station

                    else
                        NoOp
                ]
            <|
                [ div [ class "Stop__connections" ] <|
                    List.map Connections.byLine (List.filter ((/=) transferLine) <| connections station)
                , div
                    [ classList
                        [ ( "Stop__dot", True )
                        , ( line |> City.lineInfo |> .id, True )
                        , ( "Stop__dot--current", station == currentStation )
                        ]
                    ]
                    []
                , div
                    [ classList
                        [ ( "Stop__name", True )
                        , ( "Stop__name--current", station == currentStation )
                        ]
                    ]
                    [ text <| .name <| City.stationInfo station ]
                ]
    in
    div [ class "Scene Platform" ]
        [ Shared.exit (Go Lobby)
        , div
            [ class "Line_map" ]
            [ lineInfoView
            , div [ class "Line_map__stops" ] <|
                [ div
                    [ class <| "Line_map__line " ++ lineInfo.id ]
                    []
                ]
                    ++ List.map (stopView line) lineInfo.stations
            ]
        ]
