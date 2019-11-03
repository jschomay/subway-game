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
                , narrative = "{That's not my station. |}I have to go to {the office|work}{ at Metro Center Station|}."
                }
           , rule "checkMorningEmails"
                { trigger = "CELL_PHONE"
                , conditions = []
                , changes = [ "CELL_PHONE.-unread" ]
                , narrative = t "CELL_PHONE"
                }
           , rule "forcePlayerToReadEmails"
                { trigger = "*.line"
                , conditions =
                    [ "CELL_PHONE.unread"
                    , "PLAYER.chapter=1"
                    ]
                , changes = []
                , narrative = "{I have a few minutes before my train arrives.  I could check my emails while I wait.|It's kind of my routine to reread my emails before heading in.}"
                }
           , rule "goToWorkAndResetToNextDay"
                { trigger = "METRO_CENTER"
                , conditions = [ "PLAYER.day<5.chapter=1" ]
                , changes =
                    [ "PLAYER.location=WEST_MULBERRY.day+1"
                    , "CELL_PHONE.unread"
                    ]
                , narrative = "Another day at the office..."
                }
           , rule "coffeeCartMonday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=1" ]
                , changes = []
                , narrative = t "coffeeCartMonday"
                }
           , rule "coffeeCartTuesday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=2" ]
                , changes = []
                , narrative = t "coffeeCartTuesday"
                }
           , rule "coffeeCartWednesday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=3" ]
                , changes = []
                , narrative = t "coffeeCartWednesday"
                }
           , rule "coffeeCartThursday"
                { trigger = "COFFEE_CART"
                , conditions = [ "PLAYER.day=4" ]
                , changes = []
                , narrative = t "coffeeCartThursday"
                }
           , rule "fallAsleep"
                { trigger = "METRO_CENTER"
                , conditions = [ "PLAYER.day=5.chapter=1" ]
                , changes = [ "PLAYER.location=TWIN_BROOKS.chapter+1.destination=xxx" ]
                , narrative = "So tired... fall alseep!"
                }
           ]
