module Rules exposing (rules, unsafeAssert, unsafeParseChanges, unsafeParseMatcher, unsafeQuery)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import Manifest exposing (Entity, ID, WorldModel)
import NarrativeEngine.Core.WorldModel exposing (ChangeWorld(..), EntityMatcher(..), query)
import NarrativeEngine.Syntax.Helpers exposing (..)
import NarrativeEngine.Syntax.RuleParser exposing (..)
import Rules.Chapter1
import Rules.Chapter2
import Rules.General
import Rules.Helpers exposing (RulesSpec)
import Rules.Intro
import Rules.Quests


rules : Result ParseErrors Rules
rules =
    -- The rules do not use custom fields, so the extender function is `always identity`
    parseRules (always identity) allRuleSpecs


allRuleSpecs : RulesSpec
allRuleSpecs =
    List.foldl Dict.union
        Rules.General.rules
        [ Rules.Quests.rules
        , Rules.Intro.rules
        , Rules.Chapter1.rules
        , Rules.Chapter2.rules
        ]


{-| Parses an entity matcher. If there are errors, it will log to the console and default to an "empty" matcher.

Warning, you can't optmize a production build with Debug.log.

-}
unsafeParseMatcher : String -> EntityMatcher
unsafeParseMatcher s =
    case parseMatcher s of
        Ok matcher ->
            matcher

        Err e ->
            Debug.log ("ERROR parsing matcher:" ++ s ++ "\n" ++ e)
                (Match "PARSING_ERROR" [])


{-| Parses changes. If there are errors, it will log to the console and default to an "empty" changes.

Warning, you can't optmize a production build with Debug.log.

-}
unsafeParseChanges : String -> ChangeWorld
unsafeParseChanges s =
    case parseChanges s of
        Ok changes ->
            changes

        Err e ->
            Debug.log ("ERROR parsing changes:" ++ s ++ "\n" ++ e)
                (Update "PARSING_ERROR" [])


{-| "Unsafe" query
-}
unsafeQuery : String -> WorldModel -> List ( ID, Entity )
unsafeQuery queryString store =
    queryString
        |> unsafeParseMatcher
        |> (\matcher -> query matcher store)


{-| "Unsafe" assert
-}
unsafeAssert : String -> WorldModel -> Bool
unsafeAssert queryString store =
    unsafeQuery queryString store |> List.isEmpty |> not
