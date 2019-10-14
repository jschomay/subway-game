module Rules.General exposing (rules)

import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, TextRule )
rules =
    []
        ++ [ rule "ridingTheTrain"
                { trigger = "*.station"
                , conditions = []
                , changes = [ "PLAYER.location=$" ]
                , narrative = ridingTheTrain
                }
           , rule "goToLinePlatform"
                { trigger = "*.line"
                , conditions = [ "*.valid_on=$.location=PLAYER" ]
                , changes = [ "PLAYER.line=$" ]
                , narrative = ""
                }
           , rule "jumpTurnstileFail"
                { trigger = "*.line"
                , conditions = []
                , changes = []
                , narrative = jumpTurnstileFail
                }
           , rule "getMap"
                { trigger = "MAP_POSTER"
                , conditions = [ "MAP.!location=PLAYER" ]
                , changes = [ "MAP.location=PLAYER" ]
                , narrative = getMap
                }
           , rule "checkMap"
                { trigger = "*.map"
                , conditions = []
                , changes = []
                , narrative = ""
                }
           ]


jumpToLostBriefcase : String
jumpToLostBriefcase =
    """
    After missing your stop, you go back, only to find the exits sealed.  During the confusion, someone steals your briefcase!  You notice the thief disappear down the tunnel for the Red line trains towards West Mulberry...
    """


ridingTheTrain : String
ridingTheTrain =
    "{ The train hurtles through the dark tunnel towards the next stop.| You stare at the floor, avoiding the gaze of the other passengers, waiting for your next stop.}"


jumpTurnstileFail =
    "{You've never jumped a turnstile in your life, and you're not about to start now.|Better to stick to the lines you have passes for.|You're too afraid you'll get caught.}"


getMap : String
getMap =
    """
You pick up a subway map.

(It is now in your inventory and you can view it at any time by clicking on it or pressing 'M')
"""
