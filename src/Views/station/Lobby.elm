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
                            |> Maybe.map (always distraction.id)
                    )

        characters =
            query
                [ HasTag "character"
                , HasLink "location" currentStationEntityID
                ]
                worldModel

        items =
            query
                [ HasTag "item"
                , HasLink "location" currentStationEntityID
                ]
                worldModel

        inventory =
            query
                [ HasTag "item"
                , HasLink "location" "player"
                ]
                worldModel

        sectionView name list =
            if List.isEmpty list then
                text ""

            else
                div [ class "Sign__section" ]
                    [ div [ class "Sign__header2" ] [ text name ]
                    , div [ class "Sign__list" ] list
                    ]

        interactableItemView : ( Manifest.ID, String ) -> Html Msg
        interactableItemView ( id, name ) =
            div [ class "Sign__item Sign__item--interactable", onClick <| Interact id ]
                [ text name ]

        nonInteractableItemView name =
            div [ class "Sign__item" ] [ text name ]

        chapterInfoView =
            div [ class "Sign Sign--chapter" ]
                [ div [ class "Sign__header1" ] [ text fullChapterName ]
                , sectionView "Goals" <| List.map nonInteractableItemView goals
                , sectionView "Distractions" <| List.map nonInteractableItemView distractions
                ]

        stationInfoView =
            div [ class "Sign Sign--station" ]
                [ div [ class "Sign__header1" ] [ text stationName ]
                , sectionView "Conneting lines" <| Connections.view map currentStation
                ]

        interactablesView =
            div [ class "Sign Sign--interactables" ]
                [ sectionView "On this platform" <| List.map (Tuple.mapSecond .name >> interactableItemView) (characters ++ items)
                , sectionView "Inventory" <| List.map (Tuple.mapSecond .name >> interactableItemView) inventory
                ]
    in
    -- TODO make goals/distractions clickable with narrative
    div [ class "Lobby" ]
        [ div [ class "Lobby__scene" ]
            [ chapterInfoView
            , stationInfoView
            , interactablesView
            ]
        ]
