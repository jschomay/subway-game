module Views.Train exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import LocalTypes exposing (..)
import Markdown


view :
    { line : Line
    , arrivingAtStation : Maybe Station
    }
    -> Html Msg
view { line, arrivingAtStation } =
    let
        background =
            div [ class "train__background" ] []

        foreground =
            div [ class "train__foreground" ]
                [ div [ class "train__top" ] <|
                    [ div [ class "train__ticker" ] [ div [ class "train__info" ] [ text display ] ]
                    ]
                , div [ class "train__doors" ] <|
                    [ div [ class "train__door train__door--left" ] []
                    , div [ class "train__door train__door--right" ] []
                    ]
                ]

        display =
            arrivingAtStation
                |> Maybe.map (\station -> "Arriving at: " ++ (stationInfo station |> .name))
                |> Maybe.withDefault (.name <| lineInfo line)
    in
    div [ class "train" ] <|
        List.filterMap identity
            [ Just background
            , Just foreground
            ]
