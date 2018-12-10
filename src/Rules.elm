module Rules exposing (Rule, Rules, rule, rules, station)

import City exposing (Station(..), stationInfo)
import Dict exposing (Dict)
import Narrative exposing (..)
import Narrative.Rules as Rules exposing (..)
import Narrative.WorldModel exposing (..)


type alias Rule =
    Rules.Rule
        { changes : List ChangeWorld
        , narrative : Narrative
        }


type alias Rules =
    Dict String Rule


rule : RuleID -> Rule -> ( RuleID, Rule )
rule id rule_ =
    ( id, rule_ )


station : Station -> String
station station_ =
    -- TODO remove this after removing graph
    station_ |> stationInfo |> .id |> String.fromInt


location : String -> Station -> Condition
location character station_ =
    EntityMatching character [ HasLink "location" <| station station_ ]


plot : String -> Int -> Condition
plot plotLine level =
    EntityMatching "player" [ HasStat plotLine EQ level ]



{- scene map
   intro - 1
   lostBriefcase - 2
   wildGooseChase - 3
   endOfDemo - 4
-}


rules : Dict String Rule
rules =
    Dict.fromList <|
        []
            -- TODO group by trigger
            -- TODO group by scene?
            ++ [ rule "intro, deadline, miss stop"
                    { trigger = TriggerMatching "intro"
                    , conditions = [ plot "mainPlot" 1 ]
                    , changes = []
                    , narrative = Narrative.intro
                    }
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { trigger = TriggerMatching "mapPoster"
                    , conditions =
                        [ plot "mainPlot" 1
                        , location "player" TwinBrooks
                        ]
                    , changes = []
                    , narrative = Narrative.missedStop
                    }
               ]
            ++ -- train
               [ rule "missedStopAgain"
                    { trigger = TriggerMatching "train"
                    , conditions =
                        [ plot "mainPlot" 1
                        , EntityMatching "player" [ Not <| HasLink "location" <| station MetroCenter ]
                        ]
                    , changes = []
                    , narrative = Narrative.missedStopAgain
                    }
               , rule "delayAhead"
                    { trigger = TriggerMatching "train"
                    , conditions =
                        [ plot "mainPlot" 1
                        , location "player" MetroCenter
                        ]
                    , changes = [ SetLink "securityOfficers" "location" <| station MetroCenter ]
                    , narrative = Narrative.delayAhead
                    }
               , rule "endOfDemo"
                    { trigger = TriggerMatching "train"
                    , conditions = [ plot "mainPlot" 3 ]
                    , changes = [ IncStat "player" "mainPlot" 1 ]
                    , narrative = Narrative.endOfDemo
                    }
               , rule "riding the train"
                    { trigger = TriggerMatching "train"
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.ridingTheTrain
                    }
               ]
            ++ [ rule ""
                    { trigger = TriggerMatching "securityGuard"
                    , conditions = [ plot "mainPlot" 1 ]
                    , changes = []
                    , narrative = Narrative.inquireHowToGetBack
                    }
               ]
            ++ -- cellPHone
               [ rule "tryCellPhone"
                    { trigger = TriggerMatching "cellPHone"
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.tryCellPhone
                    }
               ]
            ++ -- largeCrowd
               [ rule "exitClosedBriefcaseStolen"
                    { trigger = TriggerMatching "largeCrowd"
                    , conditions =
                        [ plot "mainPlot" 1
                        , EntityMatching "briefcase" [ HasLink "location" "player" ]
                        ]
                    , changes =
                        [ IncStat "player" "mainPlot" 1
                        , SetLink "briefcase" "location" "thief"
                        ]
                    , narrative = Narrative.exitClosedBriefcaseStolen
                    }
               ]
            ++ -- securityOfficers
               [ rule "askAboutDelay"
                    { trigger = TriggerMatching "securityOfficers"
                    , conditions = [ plot "mainPlot" 1 ]
                    , changes = []
                    , narrative = Narrative.askAboutDelay
                    }
               , rule "reportStolenBriefcase"
                    { trigger = TriggerMatching "securityOfficers"
                    , conditions = [ plot "mainPlot" 2 ]
                    , changes = []
                    , narrative = Narrative.reportStolenBriefcase
                    }
               ]
            ++ -- policeOffice
               [ rule "redirectedToLostAndFound"
                    { trigger = TriggerMatching "policeOffice"
                    , conditions = [ plot "mainPlot" 2 ]
                    , changes = [ IncStat "player" "mainPlot" 1 ]
                    , narrative = Narrative.redirectedToLostAndFound
                    }
               ]
