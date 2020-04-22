module Rules.Chapter2 exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "checkBroomClosetButNotBriefcase"
            """
            ON: BROOM_CLOSET
            IF: PLAYER.find_briefcase=3
            DO: PLAYER.find_briefcase=4.call_boss=1
            """
        |> rule_______________________ "needCoinsForPayphone"
            """
            ON: PAYPHONE_SEVENTY_THIRD_STREET
            IF: PLAYER.call_boss=1
            """
        |> rule_______________________ "ponderingCallingBossOnTrain"
            """
            ON: *.station.!out_of_service
            IF: PLAYER.call_boss=1
            DO: PLAYER.location=$
            """
        |> rule_______________________ "tryingToCallBossWithCellphone"
            """
            ON: CELL_PHONE
            IF: PLAYER.call_boss=1
            """
