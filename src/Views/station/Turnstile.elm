module Views.Station.Turnstile exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Subway exposing (..)
import Views.Shared as Shared


{-| shows line map for a line
-}
view : Manifest.WorldModel -> Line -> Html Msg
view worldModel line =
    let
        lineInfo =
            City.lineInfo line

        canEnter =
            query [ HasLink "validOn" (Match lineInfo.id []), HasLink "location" (Match "player" []) ] worldModel
                |> List.isEmpty
                |> not
    in
    div [ class "Turnstile" ]
        [ div [ class "Turnstile__dialog" ] <|
            if canEnter then
                [ div [ class "Turnstile__status" ]
                    [ div [ class "Turnstile__icon icon--enter" ] []
                    , div [ class "Turnstile__status_text" ] [ text "Please proceed" ]
                    ]
                , div [ class "Turnstile__buttons" ]
                    [ div
                        [ class "Turnstile__button"
                        , onClick <| Go <| Platform line
                        ]
                        [ text "Continue" ]
                    ]
                ]

            else
                [ div [ class "Turnstile__status" ]
                    [ div [ class "Turnstile__icon icon--no-enter" ] []
                    , div [ class "Turnstile__status_text" ] [ text "Invalid ticket" ]
                    ]
                , div [ class "Turnstile__buttons" ]
                    [ div
                        [ class "Turnstile__button"
                        , onClick <| Go <| Lobby
                        ]
                        [ text "Go back" ]
                    , div
                        [ class "Turnstile__button"
                        , onClick <| Go <| Platform line
                        ]
                        [ text "Jump turnstile" ]
                    ]
                ]
        ]