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
view worldmodel =
    let
        interactiveView : ( Manifest.ID, DisplayComponent a ) -> Html Msg
        interactiveView ( id, { name } ) =
            div [ class "Station__interactable", onClick <| Interact id ]
                [ text name ]

        characters =
            Rules.query "*.character.location=centralGuardOffice" worldmodel

        items =
            Rules.query "*.item.location=centralGuardOffice" worldmodel

        inventory =
            Rules.query "*.item.location=player" worldmodel
    in
    -- TODO this needs to be figured out
    div [ class "Scene CentralGuardOffice" ]
        [ h2 [ class "CentralGuardOffice--top" ] [ text "Central Guard Office" ]
        , p [ class "CentralGuardOffice--content" ]
            [ p [] [ text "You are caught! " ]
            , p [] [ text "End of demo, thanks for playing!" ]
            , p [] [ text "Made on the ", a [ href "http://elmnarrativeengine.com" ] [ text "Elm Narrative Engine" ] ]
            , p [] [ text "Contact ", a [ href "mailto:jeff@elmnarrativeengine.com" ] [ text "jeff@elmnarrativeengine.com" ] ]
            ]
        ]
