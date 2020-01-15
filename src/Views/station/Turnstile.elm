module Views.Station.Turnstile exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Rules
import Subway exposing (..)
import Views.Shared as Shared


{-| shows line map for a line
-}
view : Manifest.WorldModel -> Line -> Html Msg
view worldModel line =
    let
        lineInfo =
            Subway.lineInfo line

        canEnterQuery =
            "*.valid_on=" ++ lineInfo.id ++ ".location=PLAYER"

        canEnter =
            Rules.unsafeQuery canEnterQuery worldModel
                |> List.isEmpty
                |> not
    in
    div [ class "Scene Turnstile" ]
        [ div [ class "Turnstile__dialog" ] <|
            if canEnter then
                [ div [ class "Turnstile__status" ]
                    [ img [ class "Turnstile__icon", src "img/icons/enter.svg" ] []
                    , div []
                        [ div [ class "Turnstile__status_text" ] [ text "Ticket valid" ]
                        , div [ class "Turnstile__status_sub_text" ] [ text "Please proceed" ]
                        ]
                    ]
                , div [ class "Turnstile__buttons" ]
                    [ div
                        [ class "Turnstile__button"
                        , onClick <| Interact <| lineInfo.id
                        ]
                        [ text "Continue" ]
                    ]
                ]

            else
                [ div [ class "Turnstile__status" ]
                    [ img [ class "Turnstile__icon", src "img/icons/no_entry.svg" ] []
                    , div []
                        [ div [ class "Turnstile__status_text" ] [ text "Invalid ticket" ]
                        , div [ class "Turnstile__status_sub_text" ] [ text "Do not enter" ]
                        ]
                    ]
                , div [ class "Turnstile__buttons" ]
                    [ div
                        [ class "Turnstile__button"
                        , onClick <| Interact "LOBBY"
                        ]
                        [ text "Go back" ]
                    , div
                        [ class "Turnstile__button"
                        , onClick <| Interact <| lineInfo.id
                        ]
                        [ text "Jump turnstile" ]
                    ]
                ]
        ]
