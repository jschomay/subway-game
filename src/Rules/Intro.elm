module Rules.Intro exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "notGoingToWork"
            """
            ON: *.station
            IF: PLAYER.destination=BROADWAY_STREET.chapter=0
            """
        -- (NOTE this rule is general)
        |> rule_______________________ "checkEmails"
            """
            ON: CELL_PHONE
            DO: CELL_PHONE.-new
            """
        |> rule_______________________ "forcePlayerToReadEmails"
            """
            ON: *.line
            IF: CELL_PHONE.new
                PLAYER.chapter=0
            """
        |> rule_______________________ "coffeeCartMonday"
            """
            ON: COFFEE_CART
            IF: PLAYER.day=1
            DO: COFFEE.location=PLAYER
            """
        |> rule_______________________ "coffeeCartTuesday"
            """
            ON: COFFEE_CART
            IF: PLAYER.day=2
            DO: COFFEE.location=PLAYER
            """
        |> rule_______________________ "coffeeCartWednesday"
            """
            ON: COFFEE_CART
            IF: PLAYER.day=3
            DO: COFFEE.location=PLAYER
            """
        |> rule_______________________ "coffeeCartThursday"
            """
            ON: COFFEE_CART
            IF: PLAYER.day=4
            DO: COFFEE.location=PLAYER
            """
        |> rule_______________________ "coffeeCartFriday"
            """
            ON: COFFEE_CART
            IF: PLAYER.day=5.chapter=0
                SODA_MACHINE.get_caffeinated_quest<1
            DO: SODA_MACHINE.get_caffeinated_quest=1
            """
        |> rule_______________________ "sodaMachineBroken"
            """
            ON: SODA_MACHINE.broken
            """
        |> rule_______________________ "sodaMachineFixed"
            """
            ON: SODA_MACHINE.!broken
            IF: PLAYER.chapter=0
            """
        |> rule_______________________ "get_caffeinated_quest_1"
            """
            ON: SODA_MACHINE.!broken.get_caffeinated_quest=1
            IF: PLAYER.chapter=0
            DO: $.get_caffeinated_quest+1
            """
        |> rule_______________________ "get_caffeinated_quest_2"
            """
            ON: SODA_MACHINE.!broken.get_caffeinated_quest=2
            IF: PLAYER.chapter=0
            DO: $.get_caffeinated_quest+1
                PLAYER.persistent+1
            """
        |> rule_______________________ "get_caffeinated_quest_3"
            """
            ON: SODA_MACHINE.!broken.get_caffeinated_quest=3
            IF: PLAYER.chapter=0
            """
        |> rule_______________________ "firstMeetSkaterDude"
            """
            ON: SKATER_DUDE
            IF: PLAYER.chapter=0
            DO: $.location=offscreen
            """
        |> rule_______________________ "firstInteractionWithCommuter1"
            """
            ON: COMMUTER_1
            IF: PLAYER.chapter=0
            DO: COMMUTER_1.friendliness=1
            """
        |> rule_______________________ "endMonday"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.day=1
            DO: PLAYER.location=EAST_MULBERRY.day+1
                CELL_PHONE.new
                COFFEE.location=offscreen
                COMMUTER_1.location=offscreen
                LOUD_PAYPHONE_LADY.location=offscreen
                TRASH_DIGGER.location=EAST_MULBERRY
            """
        |> rule_______________________ "endTuesday"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.day=2
            DO: PLAYER.location=EAST_MULBERRY.day+1
                CELL_PHONE.new
                COFFEE.location=offscreen
                TRASH_DIGGER.location=offscreen
                SKATER_DUDE.location=EAST_MULBERRY
            """
        |> rule_______________________ "endWednesday"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.day=3
            DO: PLAYER.location=EAST_MULBERRY.day+1
                CELL_PHONE.new
                COFFEE.location=offscreen
                SKATER_DUDE.location=offscreen
                TRASH_DIGGER.location=EAST_MULBERRY
                BENCH_BUM.location=EAST_MULBERRY
            """
        |> rule_______________________ "endThursday"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.day=4
            DO: PLAYER.location=EAST_MULBERRY.day+1.present_proposal=1
                CELL_PHONE.new
                COFFEE.location=offscreen
                TRASH_DIGGER.location=offscreen
                BENCH_BUM.location=offscreen
                SODA_MACHINE.-broken
                NOTEBOOK.location=PLAYER
            """
        |> rule_______________________ "fallAsleep"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.day=5.chapter=0
            DO: PLAYER.location=TWIN_BROOKS.chapter+1.present_proposal+1
                COFFEE.location=offscreen
            """
