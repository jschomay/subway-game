module Rules.Intro exposing (rules)

import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import NarrativeContent exposing (t)
import Rules.Helpers exposing (..)


rules : List ( String, TextRule )
rules =
    []
        ++ [ rule "notGoingToWork"
                { trigger = "*.station"
                , conditions = [ "PLAYER.destination=METRO_CENTER.chapter=1" ]
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
                    , "PLAYER.chapter=1"
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
                    [ "PLAYER.day=5.chapter=1"
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
                , conditions = [ "PLAYER.chapter=1" ]
                , changes = []
                }
           , rule "get_caffeinated_plot_1"
                { trigger = "SODA_MACHINE.!broken.get_caffeinated_plot=1"
                , conditions = [ "PLAYER.chapter=1" ]
                , changes = [ "$.get_caffeinated_plot+1" ]
                }
           , rule "get_caffeinated_plot_2"
                { trigger = "SODA_MACHINE.!broken.get_caffeinated_plot=2"
                , conditions = [ "PLAYER.chapter=1" ]
                , changes =
                    [ "$.get_caffeinated_plot+1"
                    , "PLAYER.persistent+1"
                    ]
                }
           , rule "get_caffeinated_plot_3"
                { trigger = "SODA_MACHINE.!broken.get_caffeinated_plot=3"
                , conditions = [ "PLAYER.chapter=1" ]
                , changes = []
                }
           , rule "firstMeetSkaterDude"
                { trigger = "SKATER_DUDE"
                , conditions = [ "PLAYER.chapter=1" ]
                , changes = [ "$.location=offscreen" ]
                }
           , rule "endMonday"
                { trigger = "METRO_CENTER"
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
                { trigger = "METRO_CENTER"
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
                { trigger = "METRO_CENTER"
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
                { trigger = "METRO_CENTER"
                , conditions = [ "PLAYER.day=4" ]
                , changes =
                    [ "PLAYER.location=WEST_MULBERRY.day+1"
                    , "CELL_PHONE.unread"
                    , "COFFEE.location=offscreen"
                    , "TRASH_DIGGER.location=offscreen"
                    , "BENCH_BUM.location=offscreen"
                    , "SODA_MACHINE.-broken"
                    ]
                }
           , rule "fallAsleep"
                { trigger = "METRO_CENTER"
                , conditions = [ "PLAYER.day=5.chapter=1" ]
                , changes =
                    [ "PLAYER.location=TWIN_BROOKS.chapter+1.destination=xxx"
                    , "COFFEE.location=offscreen"
                    ]
                }
           , rule "getMap"
                { trigger = "MAP_POSTER"
                , conditions = [ "MAP.!location=PLAYER" ]
                , changes = [ "MAP.location=PLAYER" ]
                }
           ]
