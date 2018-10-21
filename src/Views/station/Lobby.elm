module Views.Station.Lobby exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Views.Shared as Shared


view : Station -> Html Msg
view currentStation =
    let
        toTrains =
            div [ class "Station__connections", onClick <| Go Hall ] <|
                [ span [ class "icon icon--train" ] [], Shared.arrow 0 ]
    in
    div [ class "Station Station--lobby" ] <|
        List.filterMap identity
            [ Just <|
                div [ class "Station__top" ] <|
                    [ h2 [ class "Station__name" ] [ text (stationInfo currentStation |> .name) ]
                    , toTrains
                    ]
            ]
