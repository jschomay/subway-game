module Views.Station.Lobby exposing (view)

import City exposing (..)
import Components exposing (Entity)
import Engine exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest
import Views.Shared as Shared


view : Engine.Model -> Station -> Html Msg
view engineModel currentStation =
    let
        toTrains =
            div [ class "Station__connections", onClick <| Go Hall ] <|
                [ span [ class "icon icon--train" ] [], Shared.arrow 0 ]

        interactiveView interactable =
            div [ class "Station__interactable", onClick <| Interact interactable ]
                [ text <| .name <| Components.getDisplayInfo <| Manifest.findEntity <| interactable ]
    in
    div [ class "Station Station--lobby" ]
        [ div [ class "Station__top" ] <|
            [ h2 [ class "Station__name" ] [ text (stationInfo currentStation |> .name) ]
            , toTrains
            ]
        , div [ class "Station__scene" ] <|
            [ div [ class "Station__interactables" ] <|
                div [ class "Station__interactables_title" ] [ text "Characters" ]
                    :: (List.map interactiveView <| getCharactersInCurrentLocation engineModel)
            , div [ class "Station__interactables" ] <|
                div [ class "Station__interactables_title" ] [ text "Items" ]
                    :: (List.map interactiveView <| getItemsInCurrentLocation engineModel)
            , div [ class "Station__interactables" ] <|
                div [ class "Station__interactables_title" ] [ text "Inventory" ]
                    :: (List.map interactiveView <| getItemsInInventory engineModel)
            ]
        ]
