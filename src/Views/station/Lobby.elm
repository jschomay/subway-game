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

        section name list =
            if List.isEmpty list then
                div [ class "Interactables__section" ] <|
                    [ div [ class "Interactables__section_name" ]
                        [ text name ]
                    , div [ class "Noninteractable" ] [ text "None" ]
                    ]

            else
                div [ class "Interactables__section" ] <|
                    [ div [ class "Interactables__section_name" ] [ text name ] ]
                        ++ list

        ( chapterNumber, chapterName, goals ) =
            getStat "player" "mainPlot" worldModel
                |> Maybe.andThen
                    (\plotLevel ->
                        Array.get (plotLevel - 1) Constants.chapters
                            |> Maybe.map (\( chapterName_, goals_ ) -> ( plotLevel, chapterName_, goals_ ))
                    )
                |> Maybe.withDefault ( 0, "Error, can't find current chapter", [] )

        chapterNameView =
            text <|
                "Chapter "
                    ++ String.fromInt chapterNumber
                    ++ ": "
                    ++ chapterName

        goalView name =
            div [ class "Interactable" ] [ text name ]

        distractions =
            Constants.distractions
                |> List.filterMap
                    (\distraction ->
                        getStat "player" distraction.id worldModel
                            |> Maybe.map (always distraction)
                    )

        distractionView { name } =
            div [ class "Interactable" ] [ text name ]
    in
    -- TODO make goals/distractions clickable with narrative
    div [ class "Station" ]
        [ div [ class "Station__scene" ] <|
            [ div [ class "Interactables Interactables--character" ]
                [ div [ class "Chapter__name" ] [ chapterNameView ]
                , section "Goals" <| List.map goalView goals
                , section "Distractions" <| List.map distractionView distractions
                , section "Inventory" <| List.map interactiveView inventory
                ]
            , div [ class "Interactables Interactables--platform" ]
                [ div [ class "Station__name" ] [ text (stationInfo currentStation |> .name) ]
                , section "On this platform:" <| List.map interactiveView (characters ++ items)
                , section "Conneting lines:" <| Connections.view map currentStation
                ]
            ]
        ]
