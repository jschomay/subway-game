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
                }
           , rule "goToLobby"
                { trigger = "LOBBY"
                , conditions = []
                , changes = [ "PLAYER.-at_turnstile" ]
                }
           , rule "goToLineTurnstile"
                { trigger = "*.line"
                , conditions = [ "PLAYER.!at_turnstile" ]
                , changes = [ "PLAYER.line=$", "PLAYER.at_turnstile" ]
                }
           , rule "goToLinePlatform"
                { trigger = "*.line"
                , conditions =
                    [ "PLAYER.at_turnstile"
                    , "*.valid_on=$.location=PLAYER"
                    ]
                , changes = [ "PLAYER.-at_turnstile" ]
                }
           , rule "jumpTurnstileFail"
                { trigger = "*.line"
                , conditions = []
                , changes = [ "PLAYER.-at_turnstile" ]
                }
           , rule "checkMap"
                { trigger = "*.map"
                , conditions = []
                , changes = []
                }
           ]
