module Views.Station.Platform exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Subway exposing (..)
import Views.Shared as Shared
import Views.Station.Connections as Connections


{-| shows line map for a line
-}
view : Subway.Map City.Station City.Line -> Station -> Line -> Html Msg
view map currentStation line =
    let
        lineInfo =
            City.lineInfo line

        lineInfoView =
            div [ class "Line_map__info" ]
                [ Connections.byLine line
                , text <| lineInfo.name
                ]

        connections station =
            Subway.connections City.config map station

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
                    [ text <| .name <| stationInfo station ]
                ]
    in
    div [ class "Platform" ]
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
