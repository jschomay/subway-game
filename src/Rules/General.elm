module Rules.General exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "ridingTheTrain"
            """
            ON: *.station
            DO: PLAYER.location=$
            """
        |> rule_______________________ "outOfServiceStations"
            """
            ON: *.station.out_of_service
            """
        |> rule_______________________ "goToLobby"
            """
            ON: LOBBY
            DO: PLAYER.-at_turnstile
            """
        |> rule_______________________ "goToLineTurnstile"
            """
            ON: *.line
            IF: PLAYER.!at_turnstile
            DO: PLAYER.line=$.at_turnstile
            """
        |> rule_______________________ "goToLinePlatform"
            """
            ON: *.line
            IF: PLAYER.at_turnstile
                *.valid_on=$.location=PLAYER
            DO: PLAYER.-at_turnstile
            """
        |> rule_______________________ "jumpTurnstileFail"
            """
            ON: *.line
            DO: PLAYER
            """
        |> rule_______________________ "checkMap"
            """
            ON: *.map
            """
        |> rule_______________________ "notebookInstructions"
            """
            ON: NOTEBOOK.new
            DO: NOTEBOOK.-new.silent
            """
        |> rule_______________________ "inspectPasses"
            """
            ON: *.pass
            DO: (*.pass.new).-new
            """
        |> rule_______________________ "trashcan"
            """
            ON: *.trashcan
            """
