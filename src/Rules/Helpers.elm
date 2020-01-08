module Rules.Helpers exposing (RulesSpec, rule_______________________)

import Dict exposing (Dict)


type alias RulesSpec =
    Dict String ( String, {} )


rule_______________________ : String -> String -> RulesSpec -> RulesSpec
rule_______________________ k v dict =
    Dict.insert k ( v, {} ) dict
