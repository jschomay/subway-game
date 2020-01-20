module Rules.Quests exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "meetingScreamingChild"
            """
            ON: MOTHER.screaming_child_quest=0
            DO: MOTHER.screaming_child_quest=1
            """
        |> rule_______________________ "offerToHelpScreamingChild"
            """
            ON: MOTHER.screaming_child_quest=1
            DO: DOLLAR_BILL.location=PLAYER
            """
        |> rule_______________________ "getSodaForScreamingChild"
            """
            ON: SODA_MACHINE
            IF: MOTHER.screaming_child_quest=1
                DOLLAR_BILL.location=PLAYER
            DO: DOLLAR_BILL.location=offscreen
                SODA.location=PLAYER
                CHANGE.location=PLAYER.amount+25
            """
        |> rule_______________________ "giveSodaToScreamingChild"
            """
            ON: MOTHER.screaming_child_quest=1
            IF: SODA.location=PLAYER
            DO: SODA.location=offscreen
                MOTHER.screaming_child_quest=2
            """
