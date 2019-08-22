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


notReserved char =
    not <| List.member char [ '{', '}', '|' ]


staticText : Parser String
staticText =
    succeed ()
        |. chompWhile notReserved
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

        helper acc =
            oneOf
                [ -- up to here is either "{" or text followed by "|" or "}"
                  -- so if a break or close is found, this is an empty cycle part
                  break |> map (always (Loop <| "" :: acc))
                , close |> map (always (Done <| List.reverse ("" :: acc)))

                --  if it wasn't empty, then it must be some text followed by a break
                --  or close
                , succeed (\a f -> f a)
                    |= lazy (\_ -> parseText i)
                    |= oneOf
                        [ break |> map (always (\t -> Loop (t :: acc)))
                        , close |> map (always (\t -> Done <| List.reverse (t :: acc)))
                        ]
                ]
    in
    loop [] helper
        |> map findCurrent


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


open =
    symbol "{"


break =
    symbol "|"


close =
    symbol "}"


parseText : Int -> Parser String
parseText i =
    let
        topLevel =
            oneOf
                [ succeed identity
                    |. open
                    |= oneOf
                        [ backtrackable <| cyclingText i

                        -- , backtrackable propertyText
                        ]
                , staticText
                ]

        join : String -> String -> Step String String
        join next base =
            Loop <| next ++ base

        l : String -> Parser (Step String String)
        l base =
            oneOf
                [ map (join base) topLevel

                -- no `end` here because parseText will be used recursively in
                -- bracketed text
                , succeed (Done base)
                ]
    in
    succeed identity
        |= loop "" l


getNarrative { cycleIndex } textString =
    let
        parser =
            -- make sure the entire line is used
            parseText cycleIndex
                |. end
    in
    run parser textString
