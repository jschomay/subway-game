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
            """
        |> rule_______________________ "collectedEnoughChangeToCallBoss"
            """
            ON: PAYPHONE_SEVENTY_THIRD_STREET
            IF: CHANGE.amount>49
                PLAYER.call_boss=1
            DO: CHANGE.amount-50
                PLAYER.call_boss=2
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



-- TODO
-- put all change finding entities in place when call_boss gets set to 1
-- follow up quests (mother and missing posters) at some point on train rides (like she yells at you if you didn't hang the posters, or she says she foud the dog and thanks)
