module Rules.Quests exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "meetingScreamingChild"
            """
            ON: MOTHER.!met
            DO: MOTHER.met
            """
        |> rule_______________________ "offerToHelpScreamingChild"
            """
            ON: MOTHER.met.screaming_child_quest=0
            DO: DOLLAR_BILL.location=PLAYER
                MOTHER.screaming_child_quest=1
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
        -----------------------------
        |> rule_______________________ "ratty_hat_man_advice_1"
            """
            ON: MAN_IN_RATTY_HAT
            DO: $.location=TWIN_BROOKS.ratty_hat_man_advice+1
            """
        |> rule_______________________ "ratty_hat_man_advice_2"
            """
            ON: MAN_IN_RATTY_HAT.ratty_hat_man_advice=1
            DO: $.location=NORWOOD.ratty_hat_man_advice+1
            """
        |> rule_______________________ "ratty_hat_man_advice_3"
            """
            ON: MAN_IN_RATTY_HAT.ratty_hat_man_advice=2
            DO: $.location=PARK_AVE.ratty_hat_man_advice+1
            """
        |> rule_______________________ "ratty_hat_man_advice_4"
            """
            ON: MAN_IN_RATTY_HAT.ratty_hat_man_advice=3
            DO: $.location=HIGHLAND.ratty_hat_man_advice+1
            """
        |> rule_______________________ "ratty_hat_man_advice_5"
            """
            ON: MAN_IN_RATTY_HAT.ratty_hat_man_advice=4
            DO: $.location=offscreen.ratty_hat_man_advice+1
            """
