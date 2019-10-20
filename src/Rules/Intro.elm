module Rules.Intro exposing (rules)

import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
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
           , rule "goToWorkAndResetToNextDay"
                { trigger = "METRO_CENTER"
                , conditions = [ "PLAYER.day<5.chapter=1" ]
                , changes = [ "PLAYER.location=WEST_MULBERRY.day+1" ]
                , narrative = "Another day at the office..."
                }
           , rule "fallAsleep"
                { trigger = "METRO_CENTER"
                , conditions = [ "PLAYER.day=5.chapter=1" ]
                , changes = [ "PLAYER.location=TWIN_BROOKS.chapter+1.destination=xxx" ]
                , narrative = "So tired... fall alseep!"
                }
           ]
