module Rules.Helpers exposing (location, plot, rule, rulesForScene, station)

import City exposing (Station(..), stationInfo)
import Constants exposing (..)
import Dict exposing (Dict)
import LocalTypes exposing (..)
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)


rule : RuleID -> LocalTypes.Rule -> ( RuleID, LocalTypes.Rule )
rule id rule_ =
    ( id, rule_ )


rulesForScene : Int -> List ( String, LocalTypes.Rule ) -> List ( String, LocalTypes.Rule )
rulesForScene scene rules_ =
    rules_
        |> List.map
            (\( id, { conditions } as r ) ->
                ( id, { r | conditions = [ plot "mainPlot" scene ] ++ conditions } )
            )


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
