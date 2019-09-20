module Views.Station.Connections exposing (byLine, forStation)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Murmur3
import Subway exposing (..)
import SubwaySimple exposing (Map, connections)
import Views.Shared as Shared


byLine : Line -> Html Msg
byLine line =
    let
        lineInfo =
            City.lineInfo line

        -- from =
        --     lineInfo |> .stations |> List.head |> Maybe.map (City.stationInfo >> .name) |> Maybe.withDefault ""
        -- to =
        --     lineInfo |> .stations |> List.reverse |> List.head |> Maybe.map (City.stationInfo >> .name) |> Maybe.withDefault ""
        -- direction =
        --     -- 45deg from -90 to +90 (90 = up)
        --     modBy 5 (Murmur3.hashString 1234 ((City.stationInfo currentStation |> .name) ++ lineInfo.name)) * 45 - 180
    in
    div
        [ class <| "Connection " ++ lineInfo.id
        , onClick <| Go (Turnstile line)
        ]
        [ text <| String.fromInt lineInfo.number ]


forStation : City.Map -> Station -> Html Msg
forStation map currentStation =
    div [ class "Connections" ] <|
        List.map byLine <|
            List.sortBy (City.lineInfo >> .number) <|
                SubwaySimple.connections map currentStation
