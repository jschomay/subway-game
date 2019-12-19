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
            li [ class "Notebook__item" ]
                [ div [ class "Notebook__subheading" ] [ text title ]
                , ul [ class "Notebook__sublist" ]
                    (List.take level subGoals
                        |> List.map
                            (\t ->
                                li [ class "Notebook__subitem" ] [ text t ]
                            )
                    )
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
                |> ul [ class "Notebook__content" ]
    in
    div [ class "Notebook" ]
        [ div [ class "Notebook__page" ]
            [ h3 [ class "Notebook__header" ] [ text "Goals:" ]
            , goalListView goals
            ]
        , div [ class "Notebook__page" ]
            [ h3 [ class "Notebook__header" ] [ text "Distractions:" ]
            , goalListView distractions
            ]
        ]


goals : List ( String, String, List String )
goals =
    [ ( "present_proposal"
      , "Present proposal"
      , [ "Get to work by 6:30am"
        , "Get to work by 6:45am"
        , "Get to work by 7:00am"
        , ""
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
