module Views.NoteBook exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import Rules


view : NoteBookPage -> Manifest.WorldModel -> Html Msg
view page worldModel =
    let
        goalListItemView title subGoals level =
            li [ classList [ ( "Notebook__item", True ), ( "done", level >= List.length subGoals ) ] ]
                [ div [ class "Notebook__subheading" ] [ text title ]
                , ul [ class "Notebook__sublist" ]
                    (List.take level subGoals
                        |> List.map
                            (\t ->
                                li [ class "Notebook__subitem" ] [ text t ]
                            )
                    )
                ]

        getGoal goalId =
            case String.split "." goalId of
                [ id, stat ] ->
                    getStat id stat worldModel

                _ ->
                    Nothing

        goalListView goals_ =
            List.foldl
                (\( goalId, title, subGoals ) acc ->
                    case getGoal goalId of
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

        togglePage =
            stopPropagationOn "click" <| Json.succeed ( ToggleNotebookPage, True )
    in
    div [ class "Notebook" ] <|
        case page of
            Goals ->
                [ div
                    [ class "Notebook__page Notebook__page--goals" ]
                    [ div [ class "Notebook__tab", togglePage ] [ text "Distractions" ]
                    , h3 [ class "Notebook__header", togglePage ] [ text "Goals" ]
                    , goalListView goals
                    ]
                ]

            Distractions ->
                [ div
                    [ class "Notebook__page Notebook__page--distractions" ]
                    [ div [ class "Notebook__tab", togglePage ] [ text "Goals" ]
                    , h3 [ class "Notebook__header", togglePage ] [ text "Distractions" ]
                    , goalListView distractions
                    ]
                ]


goals : List ( String, String, List String )
goals =
    [ ( "PLAYER.present_proposal"
      , "Present proposal"
      , [ "Get to work by 6:30am"
        , "Get to work by 6:45am"
        , "Get to work by 7:00am"
        , ""
        ]
      )
    , ( "PLAYER.find_briefcase"
      , "Find stolen briefcase!"
      , [ "Report it stolen?"
        , "Talk to Mark @ Spring Hill?"
        , "Broom closet @ 73rd"
        , ""
        ]
      )
    , ( "PLAYER.call_boss"
      , "Call Mr. Harris"
      , [ "", "" ]
      )
    ]


distractions : List ( String, String, List String )
distractions =
    [ ( "GIRL_IN_YELLOW.who_was_girl_in_yellow_quest"
      , "Who was that girl in yellow?"
      , [ "", "" ]
      )
    , ( "MOTHER.screaming_child_quest"
      , "Stop the kid from screaming."
      , [ "Find a soda for the kid", "" ]
      )
    , ( "DISTRESSED_WOMAN.missing_dog_posters_quest"
      , "Hang up the missing dog posters."
      , [ "", "", "", "", "", "" ]
      )
    , ( "MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1"
      , "Help the hot dog mascot work at Fort Frank"
      , [ "", "", "" ]
      )
    ]
