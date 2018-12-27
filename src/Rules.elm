module Rules exposing (rules)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import Rules.General
import Rules.Intro
import Rules.LostBriefcase


rules : Rules
rules =
    Rules.Intro.rules
        ++ Rules.LostBriefcase.rules
        ++ Rules.General.rules
        |> Dict.fromList
