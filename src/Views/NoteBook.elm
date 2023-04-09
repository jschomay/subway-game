module Views.NoteBook exposing (view)

import Browser.Events exposing (onClick)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (..)
import LocalTypes exposing (..)
import Manifest exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import Rules


view :
    { m
        | worldModel : Manifest.WorldModel
        , noteBookPage : NoteBookPage
        , persistKey : String
        , history : List String
    }
    -> Html Msg
view { worldModel, noteBookPage, persistKey, history } =
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

        saveItemView s =
            li [ class "Notebook__item" ]
                [ span [ click (Persist <| Load s), class "Notebook__item--savedGame" ] [ text s ]
                , span [ click (Persist <| Delete s), class "Notebook__item-delete" ] [ text "(delete)" ]
                ]

        savesView saves =
            saves
                |> List.sort
                |> List.map saveItemView
                |> ul [ class "Notebook__content" ]

        click msg =
            custom "click" <| Json.succeed { message = msg, stopPropagation = True, preventDefault = True }
    in
    div [ class "Notebook" ] <|
        [ div [ class "Notebook__tabs" ]
            [ div [ class "Notebook__tab Notebook__tab--goals", click <| ToggleNotebookPage Goals ] [ text "Goals" ]
            , div [ class "Notebook__tab Notebook__tab--distractions", click <| ToggleNotebookPage Distractions ] [ text "Distractions" ]
            , div [ class "Notebook__tab Notebook__tab--savedGames", click (Persist ListSaves) ] [ text "Saved games" ]
            ]
        ]
            ++ (case noteBookPage of
                    Goals ->
                        [ h3 [ class "Notebook__header" ] [ text "Goals" ]
                        , goalListView goals
                        ]

                    Distractions ->
                        [ h3 [ class "Notebook__header" ] [ text "Distractions" ]
                        , goalListView distractions
                        ]

                    SavedGames saves ->
                        [ h3 [ class "Notebook__header" ] [ text "Saved games" ]
                        , input
                            [ class "Notebook__persistKeyInput"
                            , id "persistKeyInput"
                            , click NoOp
                            , onInput (Persist << PersistKeyUpdate)
                            , Html.Attributes.value persistKey
                            ]
                            []
                        , p [ class "Notebook__save-new", click <| Persist <| Save persistKey history ] [ text "Save new" ]
                        , savesView saves
                        ]
               )


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
        , "Talk to Mark @ Capitol Heights?"
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
      , [ "", "", "" ]
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
