module Rules exposing (parseErrors, rules, unsafeAssert, unsafeParseChanges, unsafeParseMatcher, unsafeQuery)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import Manifest exposing (Entity, ID, WorldModel)
import Narrative.WorldModel exposing (ChangeWorld(..), EntityMatcher(..))
import Rules.General
import Rules.Intro
import Rules.Parser exposing (..)


rules =
    Tuple.first rules_


parseErrors =
    Tuple.second rules_


parseRule { trigger, conditions, changes, narrative } =
    let
        toRule trigger_ conditions_ changes_ narrative_ =
            { trigger = trigger_
            , conditions = conditions_
            , changes = changes_
            , narrative = narrative_
            }
    in
    Result.map4 toRule
        (parseMatcher trigger)
        (parseMultiple parseMatcher conditions)
        (parseMultiple parseChanges changes)
        (Ok narrative)


rules_ : ( Rules, List ( String, ParseError ) )
rules_ =
    let
        separateErrors ( id, rule_ ) acc =
            case parseRule rule_ of
                Ok parsedRule ->
                    Tuple.mapFirst (Dict.insert id parsedRule) acc

                Err err ->
                    Tuple.mapSecond ((::) ( id, err )) acc
    in
    -- Rules.Intro.rules ++
    Rules.General.rules
        |> List.foldl separateErrors ( Dict.empty, [] )


{-| Parses an entity matcher. If there are errors, it will log to the console and default to an "empty" matcher.

Warning, you can't optmize a production build with Debug.log.

-}
unsafeParseMatcher : String -> EntityMatcher
unsafeParseMatcher s =
    case Rules.Parser.parseMatcher s of
        Ok matcher ->
            matcher

        Err e ->
            Debug.log ("ERROR parsing matcher:" ++ s ++ "\n" ++ Rules.Parser.deadEndsToString e)
                (Match "PARSING_ERROR" [])


{-| Parses changes. If there are errors, it will log to the console and default to an "empty" changes.

Warning, you can't optmize a production build with Debug.log.

-}
unsafeParseChanges : String -> ChangeWorld
unsafeParseChanges s =
    case Rules.Parser.parseChanges s of
        Ok changes ->
            changes

        Err e ->
            Debug.log ("ERROR parsing changes:" ++ s ++ "\n" ++ Rules.Parser.deadEndsToString e)
                (Update "PARSING_ERROR" [])


{-| "Unsafe" query
-}
unsafeQuery : String -> WorldModel -> List ( ID, Entity )
unsafeQuery queryString store =
    queryString
        |> unsafeParseMatcher
        |> (\matcher -> Narrative.WorldModel.query matcher store)


{-| "Unsafe" assert
-}
unsafeAssert : String -> WorldModel -> Bool
unsafeAssert queryString store =
    unsafeQuery queryString store |> List.isEmpty |> not
