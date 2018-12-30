module Views.Station.Connections exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Murmur3
import Subway exposing (..)
import Views.Shared as Shared


{-| shows the lines servicing this station
-}
view : City.Map -> Station -> List (Html Msg)
view map currentStation =
    let
        direction lineInfo =
            -- 45deg from -90 to +90 (90 = up)
            modBy 5 (Murmur3.hashString 1234 ((City.stationInfo currentStation |> .name) ++ lineInfo.name)) * 45 - 180

        connectionView line =
            let
                lineInfo =
                    City.lineInfo line

                from =
                    lineInfo |> .stations |> List.head |> Maybe.map (City.stationInfo >> .name) |> Maybe.withDefault ""

                to =
                    lineInfo |> .stations |> List.reverse |> List.head |> Maybe.map (City.stationInfo >> .name) |> Maybe.withDefault ""
            in
            div
                [ class "Connection"
                , onClick <| Go (Platform line)
                ]
                [ div
                    [ class "Connection__number"
                    , style "color" (Shared.toColor lineInfo.color)
                    , style "borderColor" (Shared.toColor lineInfo.color)
                    ]
                    [ text <| String.fromInt lineInfo.number ]
                , div [ class "Connection__info" ]
                    [ div [ class "Connection__name" ] [ text lineInfo.name ]
                    , div [ class "Connection__end_points" ] [ text <| String.join " • " [ from, to ] ]
                    ]
                ]

        connections =
            Subway.connections City.config map currentStation
    in
    List.map connectionView connections
