module Rules exposing (parseErrors, rules, unsafeAssert, unsafeParseChanges, unsafeParseMatcher, unsafeQuery)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import Manifest exposing (Entity, ID, WorldModel)
import NarrativeEngine.Core.WorldModel exposing (ChangeWorld(..), EntityMatcher(..), query)
import NarrativeEngine.Utils.Helpers exposing (..)
import NarrativeEngine.Utils.RuleParser exposing (..)
import Rules.Chapter1
import Rules.General
import Rules.Intro


rules =
    Tuple.first rules_


parseErrors =
    Tuple.second rules_


parseRule { trigger, conditions, changes } =
    let
        toRule trigger_ conditions_ changes_ =
            { trigger = trigger_
            , conditions = conditions_
            , changes = changes_
            }
    in
    Result.map3 toRule
        (parseMatcher trigger)
        (parseMultiple parseMatcher conditions)
        (parseMultiple parseChanges changes)



-- TODO move this into ENE and change to a Result


rules_ : ( Rules, List ( String, String ) )
rules_ =
    let
        printRule { trigger, conditions, changes } =
            trigger
                ++ " | "
                ++ String.join ", " conditions
                ++ " | "
                ++ String.join ", " changes

        separateErrors ( id, rule_ ) acc =
            case parseRule rule_ of
                Ok parsedRule ->
                    Tuple.mapFirst (Dict.insert id parsedRule) acc

                Err err ->
                    Tuple.mapSecond ((::) ( "Rule: " ++ id ++ " " ++ printRule rule_ ++ " ", err )) acc
    in
    Rules.Intro.rules
        ++ Rules.General.rules
        ++ Rules.Chapter1.rules
        |> List.foldl separateErrors ( Dict.empty, [] )


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
