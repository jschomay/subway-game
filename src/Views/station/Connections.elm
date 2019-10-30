module Views.Station.Connections exposing (byLine, forStation)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Murmur3
import Subway exposing (..)
import Views.Shared as Shared


byLine : Line -> Html Msg
byLine line =
    let
        lineInfo =
            Subway.lineInfo line

        -- direction =
        --     -- 45deg from -90 to +90 (90 = up)
        --     modBy 5 (Murmur3.hashString 1234 (currentStation ++ lineInfo.name)) * 45 - 180
    in
    div
        [ class <| "Connection " ++ lineInfo.id
        , onClick <| Interact <| lineInfo.id
        ]
        [ text <| String.fromInt lineInfo.number ]


forStation : Subway.Map -> Station -> Html Msg
forStation map currentStation =
    div [ class "Connections" ] <|
        List.map byLine <|
            List.sortBy (Subway.lineInfo >> .number) <|
                Subway.connectingLines map currentStation
