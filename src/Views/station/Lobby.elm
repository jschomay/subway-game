module Views.Station.Lobby exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Views.Shared as Shared


view : Manifest.WorldModel -> Station -> Html Msg
view worldmodel currentStation =
    let
        toTrains =
            div [ class "Station__connections", onClick <| Go Hall ] <|
                [ span [ class "icon icon--train" ] [], Shared.arrow 0 ]

        interactiveView : ( Manifest.ID, DisplayComponent a ) -> Html Msg
        interactiveView ( id, { name } ) =
            div [ class "Station__interactable", onClick <| Interact id ]
                [ text name ]

        currentStationEntityID =
            currentStation |> stationInfo |> .id |> String.fromInt

        characters =
            query
                [ HasTag "character"
                , HasLink "location" currentStationEntityID
                ]
                worldmodel

        items =
            query
                [ HasTag "item"
                , HasLink "location" currentStationEntityID
                ]
                worldmodel

        inventory =
            query
                [ HasTag "item"
                , HasLink "location" "player"
                ]
                worldmodel
    in
    div [ class "Station Station--lobby" ]
        [ div [ class "Station__top" ] <|
            [ h2 [ class "Station__name" ] [ text (stationInfo currentStation |> .name) ]
            , toTrains
            ]
        , div [ class "Station__scene" ] <|
            [ div [ class "Station__interactables" ] <|
                div [ class "Station__interactables_title" ] [ text "Characters" ]
                    :: List.map interactiveView characters
            , div [ class "Station__interactables" ] <|
                div [ class "Station__interactables_title" ] [ text "Items" ]
                    :: List.map interactiveView items
            , div [ class "Station__interactables" ] <|
                div [ class "Station__interactables_title" ] [ text "Inventory" ]
                    :: List.map interactiveView inventory
            ]
        ]
