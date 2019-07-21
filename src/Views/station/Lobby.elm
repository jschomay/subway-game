module Views.Station.Lobby exposing (view)

import Array
import City exposing (..)
import Constants
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Views.Shared as Shared
import Views.Station.Connections as Connections


view : City.Map -> Manifest.WorldModel -> Station -> Html Msg
view map worldModel currentStation =
    let
        currentStationEntityID =
            currentStation |> stationInfo |> .id |> String.fromInt

        stationName =
            (stationInfo currentStation |> .name) ++ " Station"

        ( chapterNumber, chapterName, goals ) =
            getStat "player" "mainPlot" worldModel
                |> Maybe.andThen
                    (\plotLevel ->
                        Array.get (plotLevel - 1) Constants.chapters
                            |> Maybe.map (\( chapterName_, goals_ ) -> ( plotLevel, chapterName_, goals_ ))
                    )
                |> Maybe.withDefault ( 0, "Error, can't find current chapter", [] )

        fullChapterName =
            "Chapter "
                ++ String.fromInt chapterNumber
                ++ ": "
                ++ chapterName

        distractions =
            Constants.distractions
                |> List.filterMap
                    (\distraction ->
                        getStat "player" distraction.id worldModel
                            |> Maybe.map (always distraction.name)
                    )

        characters =
            query
                [ HasTag "character"
                , HasLink "location" <| Match currentStationEntityID []
                ]
                worldModel

        items =
            query
                [ HasTag "item"
                , HasLink "location" <| Match currentStationEntityID []
                ]
                worldModel

        inventory =
            query
                [ HasTag "item"
                , HasLink "location" <| Match "player" []
                ]
                worldModel

        sectionView name list =
            if List.isEmpty list then
                text ""

            else
                div [ class "Sign__section" ]
                    [ div [ class "Sign__header3" ] [ text name ]
                    , div [ class "Sign__list" ] list
                    ]

        interactableItemView : ( Manifest.ID, String ) -> Html Msg
        interactableItemView ( id, name ) =
            div [ class "Sign__item Sign__item--interactable", onClick <| Interact id ]
                [ text name ]

        inventoryItemView : ( Manifest.ID, Entity ) -> Html Msg
        inventoryItemView ( id, entity ) =
            div [ class <| "Inventory__item icon--" ++ id, onClick <| Interact id ] []

        nonInteractableItemView name =
            div [ class "Sign__item" ] [ text name ]

        chapterInfoView =
            div [ class "Sign Sign--chapter" ]
                [ div [ class "Sign__header2" ] [ text fullChapterName ]

                -- TODO make goals/distractions clickable with narrative
                , sectionView "Goals" <| List.map nonInteractableItemView goals
                , sectionView "Distractions" <| List.map nonInteractableItemView distractions
                ]

        stationInfoView =
            div [ class "Sign Sign--station" ]
                [ div [ class "Sign__header1" ] [ text stationName ]
                , div [ class "Sign__split" ]
                    [ div [ class "Sign__left" ] [ Connections.forStation map currentStation ]
                    , div [ class "Sign__right" ] <| List.map (Tuple.mapSecond .name >> interactableItemView) (characters ++ items)
                    ]
                ]

        inventoryView =
            div [ class "Sign Sign--inventory" ]
                [ div [ class "Sign__header2" ] [ text "Inventory" ]
                , div [ class "Inventory" ] <| List.map inventoryItemView inventory
                ]
    in
    div [ class "Lobby" ]
        [ div [ class "Lobby__scene" ]
            [ stationInfoView
            , chapterInfoView
            , inventoryView
            ]
        ]
