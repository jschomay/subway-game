module Views.Station.Platform exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Subway exposing (..)
import Views.Shared as Shared


{-| shows line map for a line
-}
view : Subway.Map City.Station City.Line -> Station -> Line -> Html Msg
view map currentStation line =
    let
        lineInfoView lineInfo =
            div [ class "Line_map__info" ]
                [ lineNumberView lineInfo
                , text <| .name <| lineInfo
                ]

        lineNumberView lineInfo =
            div
                [ class "Line_map__number"
                , style "color" (Shared.toColor lineInfo.color)
                , style "borderColor" (Shared.toColor lineInfo.color)
                ]
                [ text <| String.fromInt lineInfo.number ]

        lineConnectionView lineInfo =
            div
                [ class "Stop__connection"
                , style "border-color" (Shared.toColor lineInfo.color)
                , style "color" (Shared.toColor lineInfo.color)
                ]
                [ text <| String.fromInt lineInfo.number ]

        connections station =
            Subway.connections City.config map station

        stopView currentLine station =
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
                    List.map (City.lineInfo >> lineConnectionView) (List.filter ((/=) currentLine) <| connections station)
                , div
                    [ classList
                        [ ( "Stop__dot", True )
                        , ( "Stop__dot--current", station == currentStation )
                        ]
                    , style "borderColor" (Shared.toColor <| .color <| lineInfo <| currentLine)
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
            [ lineInfoView <| City.lineInfo line
            , div [ class "Line_map__stops" ] <|
                [ div
                    [ class "Line_map__line"
                    , style "background" (Shared.toColor <| .color <| lineInfo <| line)
                    ]
                    []
                ]
                    ++ List.map (stopView line) (City.lineInfo line |> .stations)
            ]
        ]
