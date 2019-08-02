module Narrative exposing (Narrative, parse)


type alias Narrative =
    List String


parse : Narrative -> List String
parse narrative =
    let
        currentNarrative =
            -- TODO choose based on matched rule count
            List.head narrative
    in
    case currentNarrative of
        Nothing ->
            []

        Just text ->
            String.split "---" text
