module Narrative exposing (Narrative, parse)

import Array
import Dict exposing (Dict)
import Parser exposing (..)
import Result


{-| A list of fully parsed strings. Each string will be displayed with a continue
button until all have been shown.
-}
type alias Narrative =
    List String


{-| Provides a context for the parser to process narrative correctly. Includes the following keys:

`cycleIndex` - an integer starting at 0 indicating which index of cycle text should be used. Applies to call cycle texts and sticks on the last one. Ex: "{one|two} and {|three}" with a cycleIndex of 1 would produce "two and three"

`propKeywords` - a dictionary of valid keywords to match against, and the corresponding functions that will take an entity ID and return a property as a Result. For example "{stranger.description}" could be matched with a keyword of "description" and a corresponding function that takes "stranger" and returns a description. If it returns and Err, the match will fail.

-}
type alias Config =
    { cycleIndex : Int
    , propKeywords : Dict String (String -> Result String String)
    }


{-| Parses the text, then splits for continues.
-}
parse : Config -> String -> Narrative
parse config text =
    let
        parser =
            -- make sure the entire line is used
            parseText config
                |. end
    in
    case run parser text of
        Ok parsed ->
            String.split "---" parsed

        Err e ->
            let
                x =
                    Debug.log ("Unable to parse: " ++ text) e
            in
            [ "ERROR could not parse: " ++ text ++ "\n(see console for specific error)" ]


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


{-| Parses text that looks like "{a|b|c}".

Chooses the option separated by "|" corresponding to the `cycleIndex` in the config (zero-indexed). It sticks on the final option.

Note that empty options are valid, like "{|a||}" which has 3 empty segments.

-- TODO option for loop and maybe random

-}
cyclingText : Config -> Parser String
cyclingText config =
    let
        findCurrent : List String -> String
        findCurrent l =
            Array.fromList l
                |> Array.get (min (List.length l - 1) config.cycleIndex)
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
                    |= lazy (\_ -> parseText config)
                    |= oneOf
                        [ break |> map (always (\t -> Loop (t :: acc)))
                        , close |> map (always (\t -> Done <| List.reverse (t :: acc)))
                        ]
                ]
    in
    loop [] helper
        |> map findCurrent


{-| Parses text that looks like "{myEntity.name}".
Takes a dict keyed by the acceptable keywords (Like "name") with values that take the id and return an appropriate string or error.

Note that this means that entity ids cannot use any of the following four characters: `.{}|`

-}
propertyText : Config -> Parser String
propertyText config =
    let
        getProp : String -> (String -> Result String String) -> Result String String
        getProp id propFn =
            propFn id

        keywords =
            Dict.toList config.propKeywords
                |> List.map
                    (\( propName, fn ) ->
                        succeed fn
                            |. keyword propName
                    )
    in
    succeed getProp
        |= (getChompedString (chompWhile <| \c -> not <| List.member c [ '{', '.', '|', '}' ])
                |> andThen notEmpty
           )
        |. symbol "."
        |= oneOf keywords
        |. close
        |> andThen fromResult


fromResult res =
    case res of
        Ok s ->
            succeed s

        Err e ->
            problem e


open =
    symbol "{"


break =
    symbol "|"


close =
    symbol "}"


parseText : Config -> Parser String
parseText config =
    let
        topLevel =
            oneOf
                [ succeed identity
                    |. open
                    |= oneOf
                        -- this order is important (because props are a more specific
                        -- version of cycles)
                        [ backtrackable <| propertyText config
                        , backtrackable <| cyclingText config
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
