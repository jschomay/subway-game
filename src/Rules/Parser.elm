module Rules.Parser exposing (parseEntity)

import Narrative.WorldModel exposing (..)
import Parser exposing (..)
import Set


parseEntity : String -> Result (List DeadEnd) ( ID, NarrativeComponent {} )
parseEntity text =
    run entityParser text


entityParser =
    let
        toEntity id narrativeComponent =
            ( id, narrativeComponent )
    in
    succeed toEntity
        |= idParser
        |= propsParser


idParser =
    let
        valid c =
            Char.isAlphaNum c || List.member c [ ' ', '_', '-', ':', '#', '+' ]
    in
    succeed ()
        |. chompWhile valid
        |> getChompedString
        |> andThen notEmpty


propsParser : Parser (NarrativeComponent {})
propsParser =
    let
        emptyNarrativeComponent =
            { tags = emptyTags
            , stats = emptyStats
            , links = emptyLinks
            }

        helper acc =
            oneOf
                [ succeed identity
                    |. symbol "."
                    |= oneOf
                        [ tagParser |> map (\t -> Loop <| addTag t acc)

                        -- statParser
                        -- linkParser
                        ]
                , succeed (Done acc)
                ]
    in
    loop emptyNarrativeComponent helper


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
