module Rules.Intro exposing (rules)

import City exposing (Station(..))
import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, LocalTypes.Rule )
rules =
    rulesForScene scenes.intro <|
        []
            ++ [ rule "intro, deadline, miss stop"
                    { trigger = Match "player" []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.intro
                    }
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { trigger = Match "mapPoster" []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.missedStop
                    }
               ]
            ++ -- stations
               [ rule "delayAhead"
                    { trigger = Match (station MetroCenter) []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.delayAhead
                    }
               , rule "missedStopAgain"
                    { trigger = MatchAny [ HasTag "station", Not (HasTag "stevesWork") ]
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.missedStopAgain
                    }
               ]
            ++ [ rule "inquireHowToGetBack"
                    { trigger = Match "securityGuard" []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.inquireHowToGetBack
                    }
               ]
            ++ -- largeCrowd
               [ rule "exitClosedBriefcaseStolen"
                    { trigger = Match "largeCrowd" []
                    , conditions = []
                    , changes =
                        [ IncStat "player" "mainPlot" 1
                        , SetLink "briefcase" "location" "thief"
                        ]
                    , narrative = Narrative.exitClosedBriefcaseStolen
                    }
               ]
            ++ -- securityOfficers
               [ rule "askAboutDelay"
                    { trigger = Match "securityOfficers" []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.askAboutDelay
                    }
               ]
