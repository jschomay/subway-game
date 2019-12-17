module Views.Goals exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import Narrative.WorldModel exposing (..)
import Rules


view : Manifest.WorldModel -> Html Msg
view worldModel =
    let
        goalListItemView title subGoals level =
            li [ class "Sign__section" ]
                [ div [ class "Sign__header3" ] [ text title ]
                , List.drop (level - 1) subGoals
                    |> List.head
                    |> Maybe.map
                        (\t ->
                            ul [ class "Sign__list" ]
                                [ li [ class "Sign__item--list" ] [ text t ] ]
                        )
                    |> Maybe.withDefault (text "")
                ]

        goalListView goals_ =
            List.foldl
                (\( stat, title, subGoals ) acc ->
                    case getStat "PLAYER" stat worldModel of
                        Just level ->
                            if level > 0 then
                                goalListItemView title subGoals level :: acc

                            else
                                acc

                        Nothing ->
                            acc
                )
                []
                goals_
                |> List.reverse
                |> ul [ class "Sign__goals_group" ]
    in
    div [ class "Sign Sign--chapter" ]
        [ h3 [ class "Sign__header2" ] [ text "Goals:" ]
        , goalListView goals
        , h3 [ class "Sign__header2" ] [ text "Distractions:" ]
        , goalListView distractions
        ]


goals : List ( String, String, List String )
goals =
    [ ( "present_proposal"
      , "Present proposal"
      , [ "Get to work by 6:30am"
        , "Get to work by 6:45am"
        , "Get to work by 7:00am"
        ]
      )
    , ( "find_briefcase"
      , "Find stolen briefcase!"
      , [ "Report it stolen?"
        , "Talk to Mark @ Spring Hill?"
        , "Broom closet @ 73rd"
        ]
      )
    ]


distractions : List ( String, String, List String )
distractions =
    [ ( "who_was_girl_in_yellow"
      , "Who was that girl in yellow?"
      , []
      )
    ]
