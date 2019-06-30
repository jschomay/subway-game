module Views.Shared exposing (arrow, exit, toColor)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


arrow : Int -> Html msg
arrow direction =
    div
        [ class "Arrow" ]
        [ text " " ]


exit : msg -> Html msg
exit msg =
    div [ class "Exit", onClick msg ] [ arrow -180, div [ class "Exit__text" ] [ text "Exit" ] ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> (\{ red, green, blue } -> "rgb(" ++ String.fromInt red ++ "," ++ String.fromInt green ++ "," ++ String.fromInt blue ++ ")")
