module Rules exposing (Rule, Rules, rule, rules, station)

import City exposing (Station(..), stationInfo)
import Constants exposing (..)
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


location : String -> Station -> EntityMatcher
location character station_ =
    Match character [ HasLink "location" <| station station_ ]


plot : String -> Int -> EntityMatcher
plot plotLine level =
    Match "player" [ HasStat plotLine EQ level ]


jumpToScene s =
    Match "selectScene" [ HasStat "jumpToScene" EQ s ]


selectScene =
    []
        ++ [ rule "jumpToIntro"
                { trigger = jumpToScene scenes.intro
                , conditions = []
                , changes = []
                , narrative = Narrative.intro
                }
           ]
        ++ [ rule "jumpToLostBriefcase"
                { trigger = jumpToScene scenes.lostBriefcase
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
            -- TODO group by scene (not trigger)
            ++ [ rule "intro, deadline, miss stop"
                    -- TODO this rule doesn't take effect with the current "scene selection" screen
                    -- after removing that, this needs to be triggered in `init`
                    { trigger = Match "missStop" []
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.intro
                    }
               ]
            -- map
            ++ [ rule "figure out how to get back to metro center"
                    { trigger = Match "mapPoster" []
                    , conditions =
                        [ plot "mainPlot" scenes.intro
                        , location "player" TwinBrooks
                        ]
                    , changes = []
                    , narrative = Narrative.missedStop
                    }
               ]
            ++ -- stations
               [ rule "delayAhead"
                    { trigger = Match (station MetroCenter) []
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.delayAhead
                    }
               , rule "missedStopAgain"
                    { trigger = MatchAny [ HasTag "station", Not (HasTag "stevesWork") ]
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.missedStopAgain
                    }
               , rule "endOfDemo"
                    { trigger = MatchAny [ HasTag "station"]
                    , conditions = [ plot "mainPlot" scenes.wildGooseChase ]
                    , changes =
                        [ IncStat "player" "mainPlot" 1
                        , IncStat "player" "mapLevel" 1
                        ]
                    , narrative = Narrative.endOfDemo
                    }
               , rule "ridingTheTrain"
                    { trigger = MatchAny [ HasTag "station" ]
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.ridingTheTrain
                    }
               ]
            ++ [ rule "inquireHowToGetBack"
                    { trigger = Match "securityGuard" []
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.inquireHowToGetBack
                    }
               ]
            ++ -- cellPHone
               [ rule "tryCellPhone"
                    { trigger = Match "cellPHone" []
                    , conditions = []
                    , changes = []
                    , narrative = Narrative.tryCellPhone
                    }
               ]
            ++ -- largeCrowd
               [ rule "exitClosedBriefcaseStolen"
                    { trigger = Match "largeCrowd" []
                    , conditions =
                        [ plot "mainPlot" scenes.intro
                        , Match "briefcase" [ HasLink "location" "player" ]
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
                    { trigger = Match "securityOfficers" []
                    , conditions = [ plot "mainPlot" scenes.intro ]
                    , changes = []
                    , narrative = Narrative.askAboutDelay
                    }
               , rule "reportStolenBriefcase"
                    { trigger = Match "securityOfficers" []
                    , conditions = [ plot "mainPlot" scenes.lostBriefcase ]
                    , changes = []
                    , narrative = Narrative.reportStolenBriefcase
                    }
               ]
            ++ -- policeOffice
               [ rule "redirectedToLostAndFound"
                    { trigger = Match "policeOffice" []
                    , conditions = [ plot "mainPlot" scenes.lostBriefcase ]
                    , changes =
                        [ IncStat "player" "mainPlot" 1
                        , IncStat "player" "mapLevel" 1
                        ]
                    , narrative = Narrative.redirectedToLostAndFound
                    }
               ]
