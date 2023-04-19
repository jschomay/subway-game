module Views.Station.Lobby exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Syntax.NarrativeParser as NarrativeParser
import Rules
import Set
import Subway exposing (..)
import Views.Shared as Shared
import Views.Station.Connections as Connections


view : Subway.Map -> Manifest.WorldModel -> Station -> Html Msg
view map worldModel currentStation =
    let
        -- This is a partial config allowing variable text
        -- Only the worldmodel has actual data
        config =
            { cycleIndex = 0
            , propKeywords = Dict.empty
            , trigger = ""
            , worldModel = worldModel
            }

        stationName =
            worldModel
                |> Dict.get currentStation
                |> Maybe.map (\s -> s.name ++ " Station")
                |> Maybe.withDefault ("ERRORR getting station: " ++ currentStation)

        characters =
            Rules.unsafeQuery ("*.character.!hidden.location=" ++ currentStation) worldModel

        items =
            Rules.unsafeQuery ("*.item.!hidden.location=" ++ currentStation) worldModel

        sectionView name list =
            if List.isEmpty list then
                text ""

            else
                div [ class "Sign__section" ]
                    [ div [ class "Sign__header3" ] [ text name ]
                    , ul [ class "Sign__list" ] list
                    ]

        nonInteractableItemView name =
            li [ class "Sign__item Sign__item--list" ] [ text name ]

        interactableItemView wm ( id, { name, inworldID } ) =
            div [ class "Sign__item Sign__item--interactable", onClick <| Interact id ]
                [ text <| Maybe.withDefault name <| List.head <| NarrativeParser.parse config name
                , if inworldID /= Nothing then
                    img [ src "img/icons/chat.svg", class "Sign__chat-icon" ] []

                  else
                    text ""
                ]

        stationInfoView =
            div [ class "Sign Sign--station" ]
                [ div [ class "Sign__header1" ] [ text stationName ]
                , div [ class "Sign__split" ]
                    [ div [ class "Sign__left" ] [ Connections.forStation map currentStation ]
                    , div [ class "Sign__right" ] <| List.map (interactableItemView worldModel) (characters ++ items)
                    ]
                ]
    in
    div [ class "Scene Lobby" ]
        [ div [ class "Lobby__scene" ]
            [ stationInfoView
            , Shared.inventoryView worldModel
            ]
        ]
