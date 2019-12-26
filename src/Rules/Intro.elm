module Rules.Intro exposing (rules)

import LocalTypes
import NarrativeEngine.Core.Rules exposing (..)
import NarrativeEngine.Core.WorldModel exposing (..)
import NarrativeEngine.Utils.NarrativeParser exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, StringRule )
rules =
    []
        ++ [ rule "notGoingToWork"
                { trigger = "*.station"
                , conditions = [ "PLAYER.destination=BROADWAY_STREET.chapter=0" ]
                , changes = []
                }

           -- (NOTE this rule is general)
           , rule "checkEmails"
                { trigger = "CELL_PHONE"
                , conditions = []
                , changes = [ "CELL_PHONE.-unread" ]
                }
           , rule "forcePlayerToReadEmails"
                { trigger = "*.line"
                , conditions =
                    [ "CELL_PHONE.unread"
                    , "PLAYER.chapter=0"
                    ]
                , changes = []
                }
           , rule "coffeeCartMonday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=1" ]
                , changes = [ "COFFEE.location=PLAYER" ]
                }
           , rule "coffeeCartTuesday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=2" ]
                , changes = [ "COFFEE.location=PLAYER" ]
                }
           , rule "coffeeCartWednesday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=3" ]
                , changes = [ "COFFEE.location=PLAYER" ]
                }
           , rule "coffeeCartThursday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=4" ]
                , changes = [ "COFFEE.location=PLAYER" ]
                }
           , rule "coffeeCartFriday"
                { trigger = "COFFEE_CART"
                , conditions =
                    [ "PLAYER.day=5.chapter=0"
                    , "SODA_MACHINE.get_caffeinated_plot<1"
                    ]
                , changes = [ "SODA_MACHINE.get_caffeinated_plot=1" ]
                }
           , rule "sodaMachineBroken"
                { trigger = "SODA_MACHINE.broken"
                , conditions = []
                , changes = []
                }
           , rule "sodaMachineFixed"
                { trigger = "SODA_MACHINE.!broken"
                , conditions = [ "PLAYER.chapter=0" ]
                , changes = []
                }
           , rule "get_caffeinated_plot_1"
                { trigger = "SODA_MACHINE.!broken.get_caffeinated_plot=1"
                , conditions = [ "PLAYER.chapter=0" ]
                , changes = [ "$.get_caffeinated_plot+1" ]
                }
           , rule "get_caffeinated_plot_2"
                { trigger = "SODA_MACHINE.!broken.get_caffeinated_plot=2"
                , conditions = [ "PLAYER.chapter=0" ]
                , changes =
                    [ "$.get_caffeinated_plot+1"
                    , "PLAYER.persistent+1"
                    ]
                }
           , rule "get_caffeinated_plot_3"
                { trigger = "SODA_MACHINE.!broken.get_caffeinated_plot=3"
                , conditions = [ "PLAYER.chapter=0" ]
                , changes = []
                }
           , rule "firstMeetSkaterDude"
                { trigger = "SKATER_DUDE"
                , conditions = [ "PLAYER.chapter=0" ]
                , changes = [ "$.location=offscreen" ]
                }
           , rule "firstInteractionWithCommuter1"
                { trigger = "COMMUTER_1"
                , conditions = [ "PLAYER.chapter=0" ]
                , changes = [ "COMMUTER_1.friendliness=1" ]
                }
           , rule "endMonday"
                { trigger = "BROADWAY_STREET"
                , conditions = [ "PLAYER.day=1" ]
                , changes =
                    [ "PLAYER.location=WEST_MULBERRY.day+1"
                    , "CELL_PHONE.unread"
                    , "COFFEE.location=offscreen"
                    , "COMMUTER_1.location=offscreen"
                    , "LOUD_PAYPHONE_LADY.location=offscreen"
                    , "TRASH_DIGGER.location=WEST_MULBERRY"
                    ]
                }
           , rule "endTuesday"
                { trigger = "BROADWAY_STREET"
                , conditions = [ "PLAYER.day=2" ]
                , changes =
                    [ "PLAYER.location=WEST_MULBERRY.day+1"
                    , "CELL_PHONE.unread"
                    , "COFFEE.location=offscreen"
                    , "TRASH_DIGGER.location=offscreen"
                    , "SKATER_DUDE.location=WEST_MULBERRY"
                    ]
                }
           , rule "endWednesday"
                { trigger = "BROADWAY_STREET"
                , conditions = [ "PLAYER.day=3" ]
                , changes =
                    [ "PLAYER.location=WEST_MULBERRY.day+1"
                    , "CELL_PHONE.unread"
                    , "COFFEE.location=offscreen"
                    , "SKATER_DUDE.location=offscreen"
                    , "TRASH_DIGGER.location=WEST_MULBERRY"
                    , "BENCH_BUM.location=WEST_MULBERRY"
                    ]
                }
           , rule "endThursday"
                { trigger = "BROADWAY_STREET"
                , conditions = [ "PLAYER.day=4" ]
                , changes =
                    [ "PLAYER.location=WEST_MULBERRY.day+1.present_proposal=1"
                    , "CELL_PHONE.unread"
                    , "COFFEE.location=offscreen"
                    , "TRASH_DIGGER.location=offscreen"
                    , "BENCH_BUM.location=offscreen"
                    , "SODA_MACHINE.-broken"
                    , "NOTEBOOK.location=PLAYER"
                    ]
                }
           , rule "fallAsleep"
                { trigger = "BROADWAY_STREET"
                , conditions = [ "PLAYER.day=5.chapter=0" ]
                , changes =
                    [ "PLAYER.location=TWIN_BROOKS.chapter+1.present_proposal+1"
                    , "COFFEE.location=offscreen"
                    ]
                }
           ]
