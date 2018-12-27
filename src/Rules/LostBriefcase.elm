module Rules.LostBriefcase exposing (rules)

import City exposing (Station(..))
import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, LocalTypes.Rule )
rules =
    rulesForScene scenes.lostBriefcase <|
        []
            ++ -- securityOfficers
               [ rule "reportStolenBriefcase"
                    { trigger = Match "securityOfficers" []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.reportStolenBriefcase
                    }
               ]
            ++ -- policeOffice
               [ rule "redirectedToLostAndFound"
                    { trigger = Match "policeOffice" []
                    , conditions = []
                    , changes =
                        [ IncStat "player" "mainPlot" 1
                        , IncStat "player" "mapLevel" 1
                        ]
                    , narrative = Narrative.redirectedToLostAndFound
                    }
               ]
