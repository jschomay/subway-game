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
view : Subway.Map -> Station -> Line -> Maybe Station -> Html Msg
view map currentStation line restrictDestination =
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
                    -- This dance is necessary because of the order boarding a train
                    -- and applying the rule happens in Main
                    -- It's not great, but the best I can think of now
                    if station == currentStation then
                        NoOp

                    else if restrictDestination == Nothing then
                        BoardTrain line station

                    else if restrictDestination == Just station then
                        BoardTrain line station

                    else
                        -- let the matching rule control what happens and don't board
                        Interact station
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
