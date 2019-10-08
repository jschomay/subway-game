module Rules exposing (assert, parseChanges, parseMatcher, query, rules)

import Dict exposing (Dict)
import LocalTypes exposing (..)
import Manifest exposing (Entity, ID, WorldModel)
import Narrative.WorldModel exposing (ChangeWorld(..), EntityMatcher(..))
import Rules.General
import Rules.Intro
import Rules.LostBriefcase
import Rules.Parser


rules : Rules
rules =
    Rules.Intro.rules
        ++ Rules.LostBriefcase.rules
        ++ Rules.General.rules
        |> Dict.fromList


{-| Parses an entity matcher. If there are errors, it will log to the console and default to an "empty" matcher.

Warning, you can't optmize a production build with Debug.log.

-}
parseMatcher : String -> EntityMatcher
parseMatcher s =
    case Rules.Parser.parseMatcher s of
        Ok matcher ->
            matcher

        Err e ->
            Debug.log ("ERROR parsing matcher:" ++ s ++ "\n" ++ Rules.Parser.deadEndsToString e)
                (Match "PARSING_ERROR" [])


{-| Parses changes. If there are errors, it will log to the console and default to an "empty" changes.

Warning, you can't optmize a production build with Debug.log.

-}
parseChanges : String -> ChangeWorld
parseChanges s =
    case Rules.Parser.parseChanges s of
        Ok changes ->
            changes

        Err e ->
            Debug.log ("ERROR parsing changes:" ++ s ++ "\n" ++ Rules.Parser.deadEndsToString e)
                (Update "PARSING_ERROR" [])


{-| "Unsafe" query
-}
query : String -> WorldModel -> List ( ID, Entity )
query queryString store =
    queryString
        |> parseMatcher
        |> (\matcher -> Narrative.WorldModel.query matcher store)


{-| "Unsafe" assert
-}
assert : String -> WorldModel -> Bool
assert queryString store =
    query queryString store |> List.isEmpty |> not
