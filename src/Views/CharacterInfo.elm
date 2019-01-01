module Views.CharacterInfo exposing (view)

import Array
import Color
import Constants exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as JD
import LocalTypes exposing (..)
import Manifest
import Narrative.WorldModel exposing (..)


view : Manifest.WorldModel -> Html Msg
view worldModel =
    let
        inventoryItem ( id, { name, description } ) =
            div [ class "CharacterInfo__item CharacterInfo__item--inventory", stopPropagationOn "click" <| JD.succeed ( Interact id, True ) ]
                [ text name ]

        plotItem { id, name, chapters } =
            case getStat "player" id worldModel of
                Nothing ->
                    text "None"

                Just plotLevel ->
                    div [ class "CharacterInfo__item" ]
                        [ div [ class "CharacterInfo__item_header" ]
                            [ text <|
                                name
                                    ++ ", Chapter "
                                    ++ String.fromInt plotLevel
                            ]
                        , div []
                            [ text <|
                                (Array.get (plotLevel - 1) chapters
                                    |> Maybe.withDefault "Complete"
                                )
                            ]
                        ]

        statItem { id, name } =
            div [ class "CharacterInfo__item" ]
                [ div []
                    [ text <|
                        name
                            ++ ": "
                            ++ (getStat "player" id worldModel
                                    |> Maybe.withDefault 0
                                    |> String.fromInt
                               )
                    ]
                ]

        inventory =
            query
                [ HasTag "item"
                , HasLink "location" "player"
                ]
                worldModel
    in
    div [ onClick ToggleCharacterInfo, class "CharacterInfo" ]
        [ div [ class "CharacterInfo__display" ]
            [ div [ class "CharacterInfo__section" ] <|
                div [ class "CharacterInfo__title" ] [ text "Inventory" ]
                    :: List.map inventoryItem inventory
            , div [ class "CharacterInfo__section" ] <|
                div [ class "CharacterInfo__title" ] [ text "Character stats" ]
                    :: List.map statItem Constants.characterStats
                    ++ div [ class "CharacterInfo__title" ] [ text "Goals" ]
                    :: List.map plotItem Constants.goals
                    ++ div [ class "CharacterInfo__title" ] [ text "Distractions" ]
                    :: List.map plotItem Constants.distractions
            ]
        ]
