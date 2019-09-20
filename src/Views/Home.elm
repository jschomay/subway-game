module Views.Home exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Views.Shared as Shared


view : Manifest.WorldModel -> Html Msg
view worldModel =
    let
        items =
            query
                [ HasTag "item"
                , HasLink "location" <| Match "home" []
                ]
                worldModel

        readyToLeave =
            List.all identity
                [ assert "cellPhone" [ HasLink "location" (Match "player" []) ] worldModel
                , assert "briefcase" [ HasLink "location" (Match "player" []) ] worldModel
                , assert "redLinePass" [ HasLink "location" (Match "player" []) ] worldModel
                , assert "presentation" [ HasLink "location" (Match "briefcase" []) ] worldModel
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
