module Rules.Helpers exposing (location, plotLine, rule, rulesForScene)

import Constants exposing (..)
import Dict exposing (Dict)
import LocalTypes exposing (..)
import Narrative exposing (..)
import Narrative.Rules exposing (..)
import Narrative.WorldModel exposing (..)
import Subway exposing (Station)


rule : RuleID -> LocalTypes.Rule -> ( RuleID, LocalTypes.Rule )
rule id rule_ =
    ( id, rule_ )


rulesForScene : Int -> List ( String, LocalTypes.Rule ) -> List ( String, LocalTypes.Rule )
rulesForScene scene rules_ =
    rules_
        |> List.map
            (\( id, { conditions } as r ) ->
                ( id, { r | conditions = [ plotLine "mainPlot" EQ scene ] ++ conditions } )
            )


location : String -> Station -> EntityMatcher
location character station =
    Match character [ HasLink "location" <| Match station [] ]


plotLine : String -> Order -> Int -> EntityMatcher
plotLine key compare level =
    Match "player" [ HasStat key compare level ]
