module Narrative exposing (Narrative, cyclingText, getNarrative, parse, parseText)

import Array
import Dict exposing (Dict)
import Parser exposing (..)


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


staticText : Parser String
staticText =
    succeed ()
        |. chompUntilEndOr "{"
        -- TODO chompWhile not { or } or end (to avoid "this}allprints"
        -- or consider nested parsing
        |> getChompedString
        |> andThen notEmpty


notEmpty : String -> Parser String
notEmpty s =
    if String.isEmpty s then
        problem "string is empty"

    else
        succeed s


cyclingText : Int -> Parser String
cyclingText i =
    let
        findCurrent : List String -> String
        findCurrent l =
            Array.fromList l
                |> Array.get (min (List.length l - 1) i)
                |> Maybe.withDefault "ERROR finding correct cycling text"

        open =
            symbol "{"

        break =
            symbol "|"

        close =
            symbol "}"

        text : Parser ( String, Bool )
        text =
            succeed (\t continue -> ( t, continue ))
                |= (getChompedString <| chompWhile (\c -> not <| List.member c [ '|', '}' ]))
                |= oneOf
                    [ break |> map (always True)
                    , close |> map (always False)
                    ]

        helper acc =
            text
                |> map
                    (\( t, continue ) ->
                        case continue of
                            True ->
                                Loop (t :: acc)

                            False ->
                                Done <| List.reverse <| t :: acc
                    )
    in
    succeed findCurrent
        |. open
        |= loop [] helper


propertyText : Parser String
propertyText =
    let
        getProp id propFn =
            propFn id ++ "(prop TODO)"
    in
    succeed getProp
        |. symbol "{"
        |= (getChompedString (chompUntil ".") |> andThen notEmpty)
        -- TODO use a oneof via a map of keyword/mappingFn
        |= (keyword ".name" |> map (always String.toUpper))
        |. symbol "}"
        |> andThen notEmpty


parseText : Int -> Parser String
parseText i =
    let
        topLevel =
            oneOf
                [ backtrackable <| cyclingText i

                -- , backtrackable propertyText
                , staticText
                ]

        join : String -> String -> Step String String
        join next base =
            Loop <| next ++ base

        l : String -> Parser (Step String String)
        l base =
            oneOf
                [ map (join base) topLevel
                , map (always <| Done base) end
                ]
    in
    loop "" l


getNarrative { cycleIndex } n =
    run (parseText cycleIndex) n
