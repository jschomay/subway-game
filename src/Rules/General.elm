module Rules.General exposing (rules)

import City exposing (Station(..))
import Constants exposing (..)
import LocalTypes
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Rules.Helpers exposing (..)


rules : List ( String, LocalTypes.Rule )
rules =
    []
        ++ [ rule "endOfDemo"
                { trigger = MatchAny [ HasTag "station" ]
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
        ++ -- cellPHone
           [ rule "tryCellPhone"
                { trigger = Match "cellPHone" []
                , conditions = []
                , changes = []
                , narrative = Narrative.tryCellPhone
                }
           ]
