module Narrative exposing (Narrative, parse)

import Dict exposing (Dict)


type alias Narrative =
    List String


parse : Dict String Int -> String -> Narrative -> List String
parse matchCounts ruleName narrative =
    let
        currentNarrative =
            Dict.get ruleName matchCounts
                |> Maybe.map narrationForCount
                |> Maybe.withDefault (Just errorString)

        narrationForCount count =
            -- cycle from beginning, and sticking on the last
            List.drop
                (min (List.length narrative) count - 1)
                narrative
                |> List.head

        errorString =
            "ERROR! unable to find narrative for \"" ++ ruleName ++ "\""
    in
    case currentNarrative of
        Nothing ->
            []

        Just text ->
            String.split "---" text
