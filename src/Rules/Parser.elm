module Rules.Parser exposing (ParseError, ParsedEntity, deadEndsToString, parseEntity)

import Narrative.WorldModel exposing (..)
import Parser exposing (..)
import Set


type alias ParseError =
    List DeadEnd


type alias ParsedEntity =
    Result ParseError ( ID, NarrativeComponent {} )


parseEntity : String -> ParsedEntity
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
        |. end


idParser : Parser ID
idParser =
    let
        valid c =
            Char.isAlphaNum c || List.member c [ '_', '-', ':', '#', '+' ]
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

        toComponent key fn =
            fn key

        helper acc =
            oneOf
                [ succeed toComponent
                    |. spaces
                    |. symbol "."
                    |= propertyNameParser
                    |= oneOf
                        [ succeed identity
                            |. symbol "="
                            |= oneOf
                                [ numberParser |> map (\v -> \k -> Loop <| setStat k v acc)
                                , idParser |> map (\v -> \k -> Loop <| setLink k v acc)
                                ]
                        , succeed (\t -> Loop <| addTag t acc)
                        ]
                , succeed (Done acc)
                ]
    in
    loop emptyNarrativeComponent helper


{-| Can't use `int` because a "." can follow the number ("X.a.b=1.c"), and `int`
doesn't allow a digit followed by a ".". This also handles negatives.
-}
numberParser : Parser Int
numberParser =
    let
        int_ =
            chompWhile Char.isDigit
                |> getChompedString
                |> andThen
                    (String.toInt
                        >> Maybe.map succeed
                        >> Maybe.withDefault (problem "not an int")
                    )
    in
    oneOf
        [ succeed negate
            |. symbol "-"
            |= int_
        , int_
        ]


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



{- Borrowed from https://github.com/elm/parser/pull/16 -}


deadEndsToString : List DeadEnd -> String
deadEndsToString deadEnds =
    let
        deadEndToString deadend =
            problemToString deadend.problem ++ " at row " ++ String.fromInt deadend.row ++ ", col " ++ String.fromInt deadend.col

        problemToString p =
            case p of
                Expecting s ->
                    "expecting '" ++ s ++ "'"

                ExpectingInt ->
                    "expecting int"

                ExpectingHex ->
                    "expecting hex"

                ExpectingOctal ->
                    "expecting octal"

                ExpectingBinary ->
                    "expecting binary"

                ExpectingFloat ->
                    "expecting float"

                ExpectingNumber ->
                    "expecting number"

                ExpectingVariable ->
                    "expecting variable"

                ExpectingSymbol s ->
                    "expecting symbol '" ++ s ++ "'"

                ExpectingKeyword s ->
                    "expecting keyword '" ++ s ++ "'"

                ExpectingEnd ->
                    "expecting end"

                UnexpectedChar ->
                    "unexpected char"

                Problem s ->
                    "problem " ++ s

                BadRepeat ->
                    "bad repeat"
    in
    String.concat (List.intersperse "; " (List.map deadEndToString deadEnds))
