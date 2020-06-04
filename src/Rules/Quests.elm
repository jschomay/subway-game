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
            DO: CHANGE.location=PLAYER.amount+50
                MOTHER.screaming_child_quest=1
            """
        |> rule_______________________ "keepBotheringMother"
            """
            ON: MOTHER.met.screaming_child_quest=1
            """
        |> rule_______________________ "getSodaForScreamingChild"
            """
            ON: SODA_MACHINE
            IF: MOTHER.screaming_child_quest=1
                CHANGE.location=PLAYER.amount>49
                SODA.!location=PLAYER
            DO: CHANGE.amount-50
                SODA.location=PLAYER
            """
        |> rule_______________________ "giveSodaToScreamingChild"
            """
            ON: MOTHER.screaming_child_quest=1
            IF: SODA.location=PLAYER
            DO: SODA.location=offscreen
                MOTHER.screaming_child_quest=2
                PLAYER.good_will+2
            """
        |> rule_______________________ "noMoreScreamingChild"
            """
            ON: MOTHER.screaming_child_quest=2
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
        ------------------------
        |> rule_______________________ "meet_the_man_in_the_hot_dog_suit"
            """
            ON: MAN_IN_HOT_DOG_SUIT.location=TWIN_BROOKS
            DO: MASCOT_PAPERS.location=PLAYER
                MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=1
            """
        |> rule_______________________ "give_mascot_papers_to_frank"
            """
            ON: FRANKS_FRANKS
            IF: MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=1
            DO: MASCOT_PAPERS.location=offscreen
                MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=2.location=UNIVERSITY
            """
        |> rule_______________________ "check_up_on_hot_dog_guy_at_franks_franks"
            """
            ON: MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=2
            DO: MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=3
                CHANGE.location=PLAYER.amount+50
                PLAYER.good_will+3
            """
        |> rule_______________________ "throw_away_mascot_papers"
            """
            ON: "throw_away_mascot_papers"
            DO: MASCOT_PAPERS.location=offscreen
                PLAYER.good_will-1
                MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=100
            """
        |> rule_______________________ "hot_dog_man_rebuffed"
            """
            ON: MAN_IN_HOT_DOG_SUIT.location=TWIN_BROOKS.job_hunt_quest_1=100
            """
        |> rule_______________________ "man_in_hot_dog_suit_wants_more"
            """
            ON: MAN_IN_HOT_DOG_SUIT.job_hunt_quest_1=3
            """
