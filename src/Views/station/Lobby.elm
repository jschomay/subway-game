module Views.Station.Lobby exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Views.Shared as Shared
import Views.Station.Connections as Connections


view : City.Map -> Manifest.WorldModel -> Station -> Html Msg
view map worldmodel currentStation =
    let
        interactiveView : ( Manifest.ID, DisplayComponent a ) -> Html Msg
        interactiveView ( id, { name } ) =
            div [ class "Interactable", onClick <| Interact id ]
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

        section name list =
            if List.isEmpty list then
                text ""

            else
                div [ class "Interactables__section" ] <|
                    [ div [ class "Interactables__section_name" ] [ text name ] ]
                        ++ list
    in
    div [ class "Station" ]
        [ div [ class "Station__scene" ] <|
            [ div [ class "Interactables" ]
                [ div [ class "Station__name" ] [ text (stationInfo currentStation |> .name) ]
                , section "On this platform:" <| List.map interactiveView (characters ++ items)
                , section "Conneting lines:" <| Connections.view map currentStation
                ]
            ]
        ]
