module Views.Station.Platform exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Subway exposing (..)
import Views.Shared as Shared
import Views.Station.Connections as Connections


{-| shows line map for a line
-}
view : Subway.Map -> Station -> Line -> Html Msg
view map currentStation line =
    let
        lineInfo =
            Subway.lineInfo line

        lineInfoView =
            div [ class "Line_map__info" ]
                [ Connections.byLine line
                , text <| lineInfo.name
                ]

        connections : Subway.Station -> List Subway.Line
        connections station =
            Subway.connectingLines map station
                |> List.sortBy (Subway.lineInfo >> .number)

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
                        , ( line |> Subway.lineInfo |> .id, True )
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
                    [ text <| .name <| Subway.stationInfo station ]
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
