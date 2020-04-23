module Views.Station.CentralGuardOffice exposing (view)

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
        interactableItemView ( id, name ) =
            div [ class "Sign__item Sign__item--interactable", onClick <| Interact id ]
                [ text name ]

        characters =
            Rules.unsafeQuery "*.character.location=CENTRAL_GUARD_OFFICE" worldModel

        items =
            Rules.unsafeQuery "*.item.location=CENTRAL_GUARD_OFFICE" worldModel
    in
    div [ class "Scene CentralGuardOffice" ]
        [ div [ class "CentralGuardOffice--content Sign__right" ] <|
            List.map (Tuple.mapSecond .name >> interactableItemView) (characters ++ items)
        , Shared.inventoryView worldModel
        ]
