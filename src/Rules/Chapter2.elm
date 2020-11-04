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
                VENDING_MACHINE.coin_in_coin_return
                BROKEN_PAYPHONE.coin_in_coin_return
            """
        |> rule_______________________ "getDogPostersFromDistressedWoman"
            """
            ON: DISTRESSED_WOMAN
            DO: MISSING_DOG_POSTER_1.location=PLAYER
                MISSING_DOG_POSTER_2.location=PLAYER
                MISSING_DOG_POSTER_3.location=PLAYER
                MISSING_DOG_POSTER_4.location=PLAYER
                MISSING_DOG_POSTER_5.location=PLAYER
                DISTRESSED_WOMAN.location=offscreen.missing_dog_posters_quest=1
            """
        |> rule_______________________ "lookAtHangingDogPosters"
            """
            ON: *.missing_dog_poster
            """
        |> rule_______________________ "putUpMissingDogPoster"
            """
            ON: *.missing_dog_poster.location=PLAYER
            DO: $.location=(link PLAYER.location)
                DISTRESSED_WOMAN.missing_dog_posters_quest+1
            """
        |> rule_______________________ "putUpLastMissingDogPoster"
            """
            ON: *.missing_dog_poster.location=PLAYER
            IF: DISTRESSED_WOMAN.missing_dog_posters_quest=5
            DO: $.location=(link PLAYER.location)
                DISTRESSED_WOMAN.missing_dog_posters_quest+1
                PLAYER.good_will+5
            """
        |> rule_______________________ "tryToHangDogPosterOnWrongLine"
            """
            ON: *.missing_dog_poster.location=PLAYER
            IF: PLAYER.!line=RED_LINE
            """
        |> rule_______________________ "tryToHangRedundantDogPosters"
            -- this needs an extra condition to override tryToHangDogPosterOnWrongLine
            """
            ON: *.missing_dog_poster.location=PLAYER
            IF: *.missing_dog_poster.location=(link PLAYER.location)
                DISTRESSED_WOMAN.missing_dog_posters_quest>0
            """
        |> rule_______________________ "throwAwayPosters"
            """
            ON: "throw_away_posters"
            DO: (*.missing_dog_poster).location=offscreen
                PLAYER.good_will-3
                DISTRESSED_WOMAN.missing_dog_posters_quest=100
            """
        |> rule_______________________ "needCoinsForPayphone"
            """
            ON: PAYPHONE_SEVENTY_THIRD_STREET
            IF: PLAYER.call_boss=1
            """
        |> rule_______________________ "useChangeFromMotherToCallBoss"
            """
            ON: PAYPHONE_SEVENTY_THIRD_STREET
            IF: CHANGE.amount=50
                PLAYER.call_boss=1
                MOTHER.screaming_child_quest=1
            DO: CHANGE.amount-50
                PLAYER.good_will-1
                PLAYER.call_boss=2
                MOTHER.location=offscreen.screaming_child_quest=100
                MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET.-hidden
            """
        |> rule_______________________ "collectedEnoughChangeToCallBoss"
            """
            ON: PAYPHONE_SEVENTY_THIRD_STREET
            IF: CHANGE.amount>49
                PLAYER.call_boss=1
            DO: CHANGE.amount-50
                PLAYER.call_boss=2
                MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET.-hidden
            """
        |> rule_______________________ "chaseThiefAgain"
            """
            ON: MAINTENANCE_DOOR_SEVENTY_THIRD_STREET_TO_FORTY_SECOND_STREET
            IF: PLAYER.call_boss=2
            DO: PLAYER.call_boss=3.location=FORTY_SECOND_STREET.mapLevel=1
            """
        |> rule_______________________ "passageLocked"
            """
            ON: MAINTENANCE_DOOR_FORTY_SECOND_STREET_TO_SEVENTY_THIRD_STREET
            """
        |> rule_______________________ "exitPassagewayAtFortySecondStreet"
            """
            ON: "disembark"
            IF: PLAYER.location=FORTY_SECOND_STREET.call_boss=3
            DO: PLAYER.call_boss=4
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
        |> rule_______________________ "askBusinessmanForChange"
            """
            ON: BUSINESS_MAN
            IF: PLAYER.call_boss=1
            DO: BUSINESS_MAN.location=offscreen
            """
        |> rule_______________________ "stealMusiciansChange"
            """
            ON: "musicians_change"
            DO: MUSICIAN.robbed
                CHANGE.amount+50.location=PLAYER
                PLAYER.good_will-3
            """
        |> rule_______________________ "stealMusiciansChangeSecondTime"
            """
            ON: "musicians_change"
            IF: MUSICIAN.robbed
            DO: PLAYER.good_will-5
            """
        |> rule_______________________ "girlInYellowSecondEncounter"
            """
            ON: GIRL_IN_YELLOW
            DO: GIRL_IN_YELLOW.who_was_girl_in_yellow_quest+1.location=WESTGATE
            """
        |> rule_______________________ "catchConductorMessingWithPanel"
            """
            ON: GRIZZLED_REPAIRMAN.location=FORTY_SECOND_STREET
            """
        |> rule_______________________ "confrontConductor"
            """
            ON: "confront_repairman"
            DO: GRIZZLED_REPAIRMAN.location=offscreen
                ELECTRIC_PANEL.-hidden
            """
        |> rule_______________________ "coffee_ruined"
            """
            ON: "help_a_guy_out"
            DO: SLEEPING_MAN.coffee_ruined
                CHANGE.amount-25
            """
        |> rule_______________________ "maintenanceManAtOneHundredFourthStreet"
            """
            ON: MAINTENANCE_MAN.location=ONE_HUNDRED_FORTH_STREET
            """
        |> rule_______________________ "tryToJumpTurnstileWithRepairManWatching"
            """
            ON: BLUE_LINE
            IF: PLAYER.at_turnstile.location=FORTY_SECOND_STREET
                GRIZZLED_REPAIRMAN.location=FORTY_SECOND_STREET
            """
        |> rule_______________________ "questionJumpingTurnstiles"
            """
            ON: BLUE_LINE
            IF: PLAYER.at_turnstile.location=FORTY_SECOND_STREET
            """
        |> rule_______________________ "jumpTurnstileFortySecondStreet"
            """
            ON: "just_do_it"
            """
        |> rule_______________________ "savedSeatOnTrain"
            """
            ON: *.station.!out_of_service
            IF: PLAYER.good_will<0.location=CONVENTION_CENTER.!seen_saved_seat
            DO: PLAYER.location=$.seen_saved_seat
            """
        |> rule_______________________ "attempt_to_sit_in_saved_seat"
            """
            ON: "attempt_to_sit_in_saved_seat"
            """
        |> rule_______________________ "persist_sitting_in_saved_seat"
            """
            ON: "persist_sitting_in_saved_seat"
            DO: PLAYER.good_will-3
            """
        |> rule_______________________ "wetPantsOnTrain"
            """
            ON: *.station.!out_of_service
            IF: PLAYER.call_boss=1.line=RED_LINE
                CHANGE.amount=25
            DO: PLAYER.location=$
            """
        |> rule_______________________ "check_wet_jeans"
            """
            ON: "check_wet_jeans"
            DO: CHANGE.amount+25
            """



-- TODO
-- Update goals (find security footage)
-- Move GIRL_IN_YELLOW if you don't talk to her at end of chapter
-- Fix GIRL_IN_YELLOW notebook done status (crossing it out for some reason)
-- add more security cameras in every station and show them all after noticing the first one
-- follow up quests (mother and missing posters) at some point on train rides (like
-- she yells at you if you didn't hang the posters, or she says she foud the dog and
-- thanks)
