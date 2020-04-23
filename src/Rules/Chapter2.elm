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
        |> rule_______________________ "getDogPostersFromDistressedWoman"
            """
            ON: DISTRESSED_WOMAN
            DO: MISSING_DOG_POSTER_1.location=PLAYER
                MISSING_DOG_POSTER_2.location=PLAYER
                MISSING_DOG_POSTER_3.location=PLAYER
                MISSING_DOG_POSTER_4.location=PLAYER
                MISSING_DOG_POSTER_5.location=PLAYER
                DISTRESSED_WOMAN.location=offscreen
            """
        |> rule_______________________ "tryingToCallBossWithCellphone"
            """
            ON: CELL_PHONE
            IF: PLAYER.call_boss=1
            """
        |> rule_______________________ "lookAtHangingDogPosters"
            """
            ON: *.missing_dog_poster
            """
        |> rule_______________________ "putUpMissingDogPoster"
            """
            ON: *.missing_dog_poster.location=PLAYER
            DO: $.location=(link PLAYER.location)
                DISTRESSED_WOMAN.help_hang+1
            """
        |> rule_______________________ "tryToHangDogPosterOnWrongLine"
            """
            ON: *.missing_dog_poster.location=PLAYER
            IF: PLAYER.!line=RED_LINE
            """
        |> rule_______________________ "tryToHangRedundantDogPosters"
            """
            ON: *.missing_dog_poster.location=PLAYER
            IF: *.missing_dog_poster.location=(link PLAYER.location)
                DISTRESSED_WOMAN.help_hang<99
            """
