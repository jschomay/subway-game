module Views.Station.CentralGuardOffice exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Views.Shared as Shared


view : Manifest.WorldModel -> Html Msg
view worldmodel =
    let
        interactiveView : ( Manifest.ID, DisplayComponent a ) -> Html Msg
        interactiveView ( id, { name } ) =
            div [ class "Station__interactable", onClick <| Interact id ]
                [ text name ]

        characters =
            query
                [ HasTag "character"
                , HasLink "location" <| Match "centralGuardOffice" []
                ]
                worldmodel

        items =
            query
                [ HasTag "item"
                , HasLink "location" <| Match "centralGuardOffice" []
                ]
                worldmodel

        inventory =
            query
                [ HasTag "item"
                , HasLink "location" <| Match "player" []
                ]
                worldmodel
    in
    -- TODO this needs to be figured out
    div [ class "CentralGuardOffice" ]
        [ h2 [ class "CentralGuardOffice--top" ] [ text "Central Guard Office" ]
        , p [ class "CentralGuardOffice--content" ] [ text "You are caught! (end of demo, more to come later)" ]
        ]
