port module RuleGraph exposing (main)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import LocalTypes exposing (..)
import Rules


type alias Flags =
    {}


type alias Model =
    { rules : Rules }


type Msg
    = NoOP


main : Program Flags Model Msg
main =
    Browser.document
        { init = always init
        , view = \model -> { title = "Subway!", body = [ view model ] }
        , update = update
        , subscriptions = subscriptions
        }


port drawGraph : String -> Cmd msg


init =
    ( { rules = Rules.rules }, drawGraph graph )


update msg model =
    ( model, Cmd.none )


subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [ class "RuleGraph" ]
        [ div []
            [ text "Rules Visualizer"
            , ul [] <| List.map (li [] << List.singleton << text) <| Dict.keys model.rules
            ]
        , div [ id "graph", class "Graph" ] [ text "loading" ]
        ]


graph =
    """
digraph G {

    node [style=filled]
    edge [fontcolor=gray]

  start -> findClosedPoliceOffice
  findClosedPoliceOffice -> rideWithoutTicketToLostFound [label="+1 rule breaker"]
  rideWithoutTicketToLostFound -> caught

  start -> followThief [label="+1 bravery"]
  followThief -> lockedMaintDoor
  followThief -> randomPerson
  followThief -> redHerringPaper
  lockedMaintDoor -> stealKeyCardFromMaintMan [label="start 'down the rabit hole' (woman in yellow)"]
  stealKeyCardFromMaintMan -> unlockDoor [label="+2 rule breaker get key card"]
  unlockDoor -> caught [label="lose keycard"]

  caught -> end


  start [label="case stolen", color=lightblue];
  end [label="guard office", color=lightblue];
  rideWithoutTicketToLostFound [label="ride without ticket (only available wo/ key card)"]
}
"""
