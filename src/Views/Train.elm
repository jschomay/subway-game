module Views.Train exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import LocalTypes exposing (..)
import Manifest exposing (WorldModel)
import Markdown
import Subway exposing (..)


view :
    { line : Line
    , arrivingAtStation : Maybe Station
    , worldModel : WorldModel
    }
    -> Html Msg
view { line, arrivingAtStation, worldModel } =
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

        stationName station =
            worldModel
                |> Dict.get station
                |> Maybe.map (\s -> s.name ++ " Station")
                |> Maybe.withDefault ("ERRORR getting station: " ++ station)

        display =
            arrivingAtStation
                |> Maybe.map (\station -> "Arriving at: " ++ stationName station)
                |> Maybe.withDefault (.name <| lineInfo line)

        displayView =
            div [ class "train__ticker" ] [ div [ class "train__info" ] [ text display ] ]
    in
    div [ class "Scene train" ] [ displayView ]
