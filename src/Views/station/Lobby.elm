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


        section list =
            if List.isEmpty list then
                []

            else
                div [ class "Station__interactables_divider" ] []
                    :: list
    in
    div [ class "Station" ]
        [ div [ class "Station__scene" ] <|
            [ div [ class "Station__interactables" ] <|
                div [ class "Station__name" ] [ text (stationInfo currentStation |> .name) ]
                    :: (section <| List.map interactiveView characters)
                    ++ (section <| List.map interactiveView items)
                    ++ (section <| Connections.view map currentStation)

            ]
        ]
