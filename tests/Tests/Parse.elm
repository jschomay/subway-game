module Tests.Parse exposing (all)

import Dict
import Expect
import Narrative exposing (..)
import Result
import Test exposing (..)


all =
    describe "parsing narrative"
        [ static
        , cycle
        , property
        , mixed
        ]


config =
    { cycleIndex = 0
    , propKeywords = Dict.empty
    }


configWithKeyword k f =
    { config
        | propKeywords = Dict.fromList [ ( k, f ) ]
    }


configWithName =
    configWithKeyword "name" (\s -> Ok <| "Mr. " ++ String.toUpper s)


configWithNameError =
    configWithKeyword "name" (always <| Err "test error")


static =
    describe "static"
        [ test "empty string" <|
            \() ->
                Expect.equal (Ok "") <|
                    getNarrative { config | cycleIndex = 0 } ""
        , test "static string" <|
            \() ->
                Expect.equal (Ok "just a string") <|
                    getNarrative { config | cycleIndex = 0 } "just a string"
        , test "erors with orphan closer" <|
            \() ->
                shouldError "a}b should error" <| getNarrative { config | cycleIndex = 0 } "a}b"
        , test "erors with orphan opener" <|
            \() ->
                shouldError "a{b should error" <| getNarrative { config | cycleIndex = 0 } "a{b"
        ]


cycle =
    describe "cycles"
        [ test "cycle at 0" <|
            \() ->
                Expect.equal (Ok "a") <|
                    getNarrative { config | cycleIndex = 0 } "{a|b|c}"
        , test "cycle at 2" <|
            \() ->
                Expect.equal (Ok "c") <|
                    getNarrative { config | cycleIndex = 2 } "{a|b|c}"
        , test "cycle out of bounds" <|
            \() ->
                Expect.equal (Ok "c") <|
                    getNarrative { config | cycleIndex = 9 } "{a|b|c}"
        , test "cycle with empties 1" <|
            \() ->
                Expect.equal (Ok "") <|
                    getNarrative { config | cycleIndex = 1 } "{||(ok|no}"
        , test "cycle with empties 2" <|
            \() ->
                Expect.equal (Ok "ok") <|
                    getNarrative { config | cycleIndex = 2 } "{||ok|no}"
        , test "empty cycle" <|
            \() ->
                -- NOTE maybe this should be an error?
                Expect.equal (Ok "ab") <|
                    getNarrative { config | cycleIndex = 2 } "a{}b"
        , test "two cycles" <|
            \() ->
                Expect.equal (Ok "bb") <|
                    getNarrative { config | cycleIndex = 1 } "{a|b|c}{a|b|c}"
        , test "cycle in middle" <|
            \() ->
                Expect.equal (Ok "hello good bye") <|
                    getNarrative { config | cycleIndex = 2 } "hello {world|good} bye"
        , test "cycles on ends" <|
            \() ->
                Expect.equal (Ok "two three five") <|
                    getNarrative { config | cycleIndex = 2 } "{one|two} three {four|five}"
        , describe "cycles that looks similar to a prop (but isn't)" <|
            let
                text =
                    -- note, a keyword ` X|Henry` of would actually match
                    "Meet {Mr. X|Henry}.{  He says you can call him Henry.|}"
            in
            [ test "cycle 0" <|
                \() ->
                    Expect.equal (Ok "Meet Mr. X.  He says you can call him Henry.") <|
                        getNarrative config text
            , test "cycle 1" <|
                \() ->
                    Expect.equal (Ok "Meet Henry.") <|
                        getNarrative { config | cycleIndex = 1 } text
            ]
        , test "erors with orphan opener in cycle" <|
            \() ->
                shouldError "{abc{xyz} should error" <|
                    getNarrative { config | cycleIndex = 0 } "{abc{xyz}"
        , test "erors with orphan closer outside cycle" <|
            \() ->
                shouldError "{abc}xyz} should error" <|
                    getNarrative { config | cycleIndex = 0 } "{abc}xyz}"
        , todo "errors with less than 2 items in cycle"

        -- "{}" and "{a}" and "{a|{b}} and "{{{a}}}"
        ]


property =
    describe "property"
        [ test "happy path" <|
            \() ->
                Expect.equal (Ok "Meet Mr. X.") <|
                    getNarrative configWithName "Meet {x.name}."
        , test "looks like prop but really cycle" <|
            \() ->
                Expect.equal (Ok "x.name") <|
                    getNarrative configWithName "{x.name|hi}"
        , test "if the keyword function returns an Err it doesn't match (will match as a cycle instead)" <|
            \() ->
                Expect.equal (Ok "x.name") <|
                    getNarrative configWithNameError "{x.name}"
        ]


mixed =
    describe "mixed"
        [ test "nested cycles (works, but no real use case)" <|
            \() ->
                Expect.equal (Ok "onetwo") <|
                    getNarrative { config | cycleIndex = 0 } "{one{two|three}|four}"
        , test "nested cycles 2 (works, but no real use case)" <|
            \() ->
                Expect.equal (Ok "four") <|
                    getNarrative { config | cycleIndex = 1 } "{one{two|three}|four}"
        , describe "basic prop and cycle mix" <|
            [ test "cycle 0, prop 1" <|
                \() ->
                    Expect.equal (Ok "a") <|
                        getNarrative configWithName "{a|{x.name}}"
            , test "cycle 1, prop 1" <|
                \() ->
                    Expect.equal (Ok "Mr. X") <|
                        getNarrative { configWithName | cycleIndex = 1 } "{a|{x.name}}"
            , test "cycle 0, prop 0" <|
                \() ->
                    Expect.equal (Ok "Mr. X") <|
                        getNarrative configWithName "{{x.name}|a}"
            , test "cycle 1, prop 0" <|
                \() ->
                    Expect.equal (Ok "a") <|
                        getNarrative { configWithName | cycleIndex = 1 } "{{x.name}|a}"
            ]
        , describe "complete cycle and props example" <|
            let
                text =
                    "{Meet {x.name}|{x.nickname} says hi}.{  He says you can call him {x.nickname}.|}"

                nestedConfig =
                    { config
                        | propKeywords =
                            Dict.fromList
                                [ ( "name", always <| Ok "Mr. X" )
                                , ( "nickname", always <| Ok "Henry" )
                                ]
                    }
            in
            [ test "cycle 0" <|
                \() ->
                    Expect.equal (Ok "Meet Mr. X.  He says you can call him Henry.") <|
                        getNarrative nestedConfig text
            , test "cycle 1" <|
                \() ->
                    Expect.equal (Ok "Henry says hi.") <|
                        getNarrative { nestedConfig | cycleIndex = 1 } text
            ]
        , skip <|
            -- needs empty cycle errors
            test "cycle 1"
            <|
                \() ->
                    Expect.equal (Ok "Henry says hi.") <|
                        getNarrative { configWithName | cycleIndex = 1 } "{a|{x.asfadsf}}"
        ]


shouldError message res =
    Expect.true message <|
        case res of
            Err _ ->
                True

            _ ->
                False
