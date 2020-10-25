module Views.Shared exposing (arrow, exit, inventoryView, toColor)

import Color
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Rules
import Set


arrow : Int -> Html msg
arrow direction =
    div
        [ class "Arrow" ]
        [ text " " ]


exit : msg -> Html msg
exit msg =
    div [ class "Exit", onClick msg ] [ arrow -180, div [ class "Exit__text" ] [ text "Exit" ] ]


toColor : Color.Color -> String
toColor color =
    Color.toRgb color
        |> (\{ red, green, blue } -> "rgb(" ++ String.fromInt red ++ "," ++ String.fromInt green ++ "," ++ String.fromInt blue ++ ")")


inventoryView : Manifest.WorldModel -> Html Msg
inventoryView worldModel =
    let
        inventory =
            Rules.unsafeQuery
                "*.item.location=PLAYER"
                worldModel

        groupedEntityTags =
            [ "pass", "missing_dog_poster" ]

        getIcon id =
            List.foldl
                (\groupTag acc ->
                    if acc == Nothing && Rules.unsafeAssert (id ++ "." ++ groupTag) worldModel then
                        Just groupTag

                    else
                        acc
                )
                Nothing
                groupedEntityTags
                |> Maybe.withDefault id
                |> (\name ->
                        "img/icons/" ++ String.toLower name ++ ".svg"
                   )

        groupInventory : List ( Manifest.ID, Entity ) -> List ( Manifest.ID, Entity )
        groupInventory =
            List.foldr
                (\(( id, entity ) as e) ( entities, existingGroups ) ->
                    List.foldl
                        (\groupTag ( keep, groups ) ->
                            if not <| Rules.unsafeAssert (id ++ "." ++ groupTag) worldModel then
                                ( keep && True, groups )

                            else if Set.member groupTag groups then
                                ( keep && False, groups )

                            else
                                ( keep && True, Set.insert groupTag groups )
                        )
                        ( True, existingGroups )
                        groupedEntityTags
                        |> (\( keep, updatedGroups ) ->
                                if keep then
                                    ( e :: entities, updatedGroups )

                                else
                                    ( entities, updatedGroups )
                           )
                )
                ( [], Set.empty )
                >> Tuple.first

        inventoryItemView : ( Manifest.ID, Entity ) -> Html Msg
        inventoryItemView ( id, entity ) =
            div
                [ classList
                    [ ( "Inventory__item", True )
                    , ( "Inventory__item--new", Rules.unsafeAssert (id ++ ".new") worldModel )
                    ]
                , onClick <| Interact id
                ]
                [ img [ src <| getIcon id ] []
                ]
    in
    div [ class "Sign Sign--inventory" ]
        [ div [ class "Inventory" ] <| List.map inventoryItemView <| groupInventory inventory
        ]
