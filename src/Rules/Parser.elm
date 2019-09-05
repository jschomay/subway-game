module Rules.Parser exposing (parseEntity)

import Narrative.WorldModel exposing (..)
import Parser exposing (..)
import Set


parseEntity : String -> Result (List DeadEnd) ( ID, NarrativeComponent {} )
parseEntity text =
    run parser text


parser =
    let
        toEntity id tags =
            ( id
            , { tags = tags
              , stats = emptyStats
              , links = emptyLinks
              }
            )
    in
    succeed toEntity
        |= idParser
        |= oneOf
            [ end |> map (always Set.empty)
            , propsParser
                |. end
            ]


idParser =
    let
        valid c =
            Char.isAlphaNum c || List.member c [ '_', '-', ':', '#', '+' ]
    in
    succeed ()
        |. chompWhile valid
        |> getChompedString
        |> andThen notEmpty


propsParser : Parser Tags
propsParser =
    -- TODO this should be a record of tags, stats, strings
    let
        tags =
            -- this will need to be accumulated when looping
            List.singleton >> Set.fromList
    in
    -- loop...
    succeed tags
        |. symbol "."
        |= oneOf
            [ tagParser

            -- statParser
            -- linkParser
            ]


tagParser : Parser String
tagParser =
    propertyNameParser


propertyNameParser : Parser String
propertyNameParser =
    let
        valid c =
            Char.isAlphaNum c || List.member c [ '_', '-', ':', '#' ]
    in
    succeed ()
        |. chompWhile valid
        |> getChompedString
        |> andThen notEmpty


notEmpty s =
    if String.isEmpty s then
        problem "cannot be empty"

    else
        succeed s
