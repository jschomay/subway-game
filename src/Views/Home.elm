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
            Rules.query "*.item.location=home" worldModel

        readyToLeave =
            List.all identity
                [ Rules.assert "cellPhone.location=player" worldModel
                , Rules.assert "briefcase.location=player" worldModel
                , Rules.assert "redLinePass.location=player" worldModel
                , Rules.assert "presentation.location=briefcase" worldModel
                ]

        leaveLink =
            if readyToLeave then
                div
                    [ class "Home__leave"
                    , onClick <| BoardTrain Red "TwinBrooks"
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
