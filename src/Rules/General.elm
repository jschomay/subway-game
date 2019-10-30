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
           , rule "goToLobby"
                { trigger = "LOBBY"
                , conditions = []
                , changes = [ "PLAYER.-at_turnstile" ]
                , narrative = ""
                }
           , rule "goToLineTurnstile"
                { trigger = "*.line"
                , conditions = [ "PLAYER.!at_turnstile" ]
                , changes = [ "PLAYER.line=$", "PLAYER.at_turnstile" ]
                , narrative = ""
                }
           , rule "goToLinePlatform"
                { trigger = "*.line"
                , conditions =
                    [ "PLAYER.at_turnstile"
                    , "*.valid_on=$.location=PLAYER"
                    ]
                , changes = [ "PLAYER.-at_turnstile" ]
                , narrative = ""
                }
           , rule "jumpTurnstileFail"
                { trigger = "*.line"
                , conditions = []
                , changes = [ "PLAYER.-at_turnstile" ]
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


ridingTheTrain : String
ridingTheTrain =
    "The train hurtles through the dark tunnel towards the next stop."


jumpTurnstileFail =
    "{I've never jumped a turnstile in my life, and I'm not about to start now.|I don't want to get caught.|Better to stick to the lines I have passes for.}"


getMap : String
getMap =
    """
{I might need the full subway map.  They have a printed one I can take.

(Press "M" to view the map)|}
"""
