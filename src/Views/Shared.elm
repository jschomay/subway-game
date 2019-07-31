module Views.Shared exposing (arrow, exit, interactableItemView, nonInteractableItemView, toColor)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)


interactableItemView : ( Manifest.ID, String ) -> Html Msg
interactableItemView ( id, name ) =
    div [ class "Sign__item Sign__item--interactable", onClick <| Interact id ]
        [ text name ]


nonInteractableItemView : String -> Html Msg
nonInteractableItemView name =
    div [ class "Sign__item" ] [ text name ]


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
