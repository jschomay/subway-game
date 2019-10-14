module Views.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Rules
import Subway exposing (..)
import Views.Shared as Shared


view : Manifest.WorldModel -> Html Msg
view worldModel =
    let
        items =
            Rules.unsafeQuery "*.item.location=home" worldModel

        readyToLeave =
            List.all identity
                [ Rules.unsafeAssert "CELL_PHONE.location=PLAYER" worldModel
                , Rules.unsafeAssert "BRIEFCASE.location=PLAYER" worldModel
                , Rules.unsafeAssert "RED_LINE_PASS.location=PLAYER" worldModel
                , Rules.unsafeAssert "PRESENTATION.location=briefcase" worldModel
                ]

        leaveLink =
            if readyToLeave then
                div
                    [ class "Home__leave"
                    , onClick <| BoardTrain Red "TWIN_BROOKS"
                    ]
                    [ text "Go to the metro station" ]

            else
                text ""
    in
    div [ class "Scene Home" ]
        [ p [ class "Home__content" ]
            [ div [ class "Home__items" ] <|
                List.map (Tuple.mapSecond .name >> Shared.interactableItemView) items

            -- TODO if ready to leave:
            , leaveLink
            ]
        ]
