module Rules.Chapter1 exposing (rules)

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
        ++ [ rule "getMap"
                { trigger = "MAP_POSTER"
                , conditions = [ "MAP.!location=PLAYER" ]
                , changes = [ "MAP.location=PLAYER" ]
                }
           , rule "delaysAtBroadwayStreetStation"
                { trigger = "BROADWAY_STREET"
                , conditions = [ "PLAYER.destination=BROADWAY_STREET.chapter=1" ]
                , changes =
                    [ "PLAYER.location=BROADWAY_STREET.destination=xxx"
                    , "BROADWAY_STREET.out_of_service"
                    , "COMMUTER_1.location=BROADWAY_STREET"
                    ]
                }
           , rule "notGoingToWorkAgain"
                { trigger = "*.station"
                , conditions = [ "PLAYER.destination=BROADWAY_STREET.chapter=1" ]
                , changes = []
                }
           , rule "leavingBroadwayStationPrematurely"
                { trigger = "*.line"
                , conditions =
                    [ "PLAYER.location=BROADWAY_STREET"
                    , "BROADWAY_STREET.leaving_broadway_street_station_plot<1"
                    ]
                , changes = []
                }
           , rule "askOfficersAboutDelay"
                { trigger = "SECURITY_OFFICERS"
                , conditions = [ "BROADWAY_STREET.leaving_broadway_street_station_plot<2" ]
                , changes = [ "BROADWAY_STREET.leaving_broadway_street_station_plot=1" ]
                }
           , rule "askCommuter1AboutDelay"
                { trigger = "COMMUTER_1"
                , conditions = [ "BROADWAY_STREET.leaving_broadway_street_station_plot<2", "PLAYER.chapter=1" ]
                , changes = []
                }
           , rule "noticeGirlInYellow"
                { trigger = "GIRL_IN_YELLOW"
                , conditions = [ "PLAYER.chapter=1" ]
                , changes = [ "PLAYER.who_was_girl_in_yellow", "GIRL_IN_YELLOW.location=offscreen" ]
                }
           , rule "briefcaseStolen"
                { trigger = "*.line"
                , conditions =
                    [ "PLAYER.chapter=1"
                    , "BROADWAY_STREET.leaving_broadway_street_station_plot=1"
                    ]
                , changes =
                    [ "BRIEFCASE.location=THIEF"
                    , "BROADWAY_STREET.leaving_broadway_street_station_plot=2"
                    , "GIRL_IN_YELLOW.location=offscreen"
                    ]
                }
           , rule "tellOfficersAboutStolenBriefcase"
                { trigger = "SECURITY_OFFICERS"
                , conditions = [ "BROADWAY_STREET.leaving_broadway_street_station_plot=2" ]
                , changes = [ "BROADWAY_STREET.leaving_broadway_street_station_plot=3" ]
                }
           , rule "tellCommuter1AboutStolenBriefcase"
                { trigger = "COMMUTER_1"
                , conditions = [ "BROADWAY_STREET.leaving_broadway_street_station_plot>1" ]
                , changes = []
                }
           , rule "followGuardsAdvice"
                { trigger = "SPRING_HILL"
                , conditions =
                    [ "BROADWAY_STREET.leaving_broadway_street_station_plot=3"
                    , "PLAYER.chapter=1"
                    ]
                , changes =
                    [ "PLAYER.location=SPRING_HILL"
                    , "BROADWAY_STREET.leaving_broadway_street_station_plot=4"
                    ]
                }
           , rule "ignoreGuardsAdvice"
                { trigger = "*.station"
                , conditions =
                    [ "BROADWAY_STREET.leaving_broadway_street_station_plot=3"
                    , "PLAYER.chapter=1"
                    ]
                , changes =
                    [ "PLAYER.location=$"
                    , "BROADWAY_STREET.leaving_broadway_street_station_plot=4"
                    ]
                }
           , rule "panic"
                { trigger = "*.station"
                , conditions =
                    [ "BROADWAY_STREET.leaving_broadway_street_station_plot=2"
                    , "PLAYER.chapter=1"
                    ]
                , changes =
                    [ "PLAYER.location=$", "BROADWAY_STREET.leaving_broadway_street_station_plot=4" ]
                }
           , rule "findingSecurityDepotClosed"
                { trigger = "SECURITY_DEPOT"
                , conditions =
                    [ "BROADWAY_STREET.leaving_broadway_street_station_plot<5"
                    , "PLAYER.chapter=1"
                    ]
                , changes = [ "BROADWAY_STREET.leaving_broadway_street_station_plot=5" ]
                }
           ]



-- TODO deal with out_of_service stations on line map (can't go back to
-- BROADWAY_STREET)
