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


scenes =
    { intro = 1
    , lostBriefcase = 2
    , wildGooseChase = 3
    , endOfDemo = 4
    }


selectScene =
    []
        ++ [ rule "selectBeginning"
                { trigger = TriggerMatching "beginning"
                , conditions = []
                , changes = []
                , narrative = Narrative.intro
                }
           ]
        ++ [ rule "selectLostBriefcase"
                { trigger = TriggerMatching "lostBriefcase"
                , conditions = []
                , changes =
                    [ SetStat "player" "mainPlot" scenes.lostBriefcase
                    , SetLink "player" "location" <| station MetroCenter
                    , SetLink "briefcase" "location" "thief"
                    ]
                , narrative = Narrative.jumpToLostBriefcase
                }
           ]


rules : Dict String Rule
rules =
    Dict.fromList <|
        selectScene
            -- TODO group by trigger
            -- TODO group by scene?
            ++ [ rule "intro, deadline, miss stop"
                    { trigger = TriggerMatching "missStop"
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.intro
                    }
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { trigger = TriggerMatching "mapPoster"
                    , conditions =
                        [ plot "mainPlot" scenes.intro
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
                        [ plot "mainPlot" scenes.intro
                        , EntityMatching "player" [ Not <| HasLink "location" <| station MetroCenter ]
                        ]
                    , changes = []
                    , narrative = Narrative.missedStopAgain
                    }
               , rule "delayAhead"
                    { trigger = TriggerMatching "train"
                    , conditions =
                        [ plot "mainPlot" scenes.intro
                        , location "player" MetroCenter
                        ]
                    , changes = []
                    , narrative = Narrative.delayAhead
                    }
               , rule "endOfDemo"
                    { trigger = TriggerMatching "train"
                    , conditions = [ plot "mainPlot" scenes.wildGooseChase ]
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
                    , conditions = [ plot "mainPlot" scenes.intro ]
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
                        [ plot "mainPlot" scenes.intro
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
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.askAboutDelay
                    }
               , rule "reportStolenBriefcase"
                    { trigger = TriggerMatching "securityOfficers"
                    , conditions = [ plot "mainPlot" scenes.lostBriefcase ]
                    , changes = []
                    , narrative = Narrative.reportStolenBriefcase
                    }
               ]
            ++ -- policeOffice
               [ rule "redirectedToLostAndFound"
                    { trigger = TriggerMatching "policeOffice"
                    , conditions = [ plot "mainPlot" scenes.lostBriefcase ]
                    , changes = [ IncStat "player" "mainPlot" 1 ]
                    , narrative = Narrative.redirectedToLostAndFound
                    }
               ]
