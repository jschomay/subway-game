module Tests.NarrativeParse exposing (all)

import Dict
import Expect
import Narrative exposing (parse)
import Result
import Test exposing (..)


all =
    describe "parsing narrative"
        [ static
        , cycle
        , property
        , mixed
        , withContinues
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
                Expect.equal [ "" ] <|
                    parse { config | cycleIndex = 0 } ""
        , test "static string" <|
            \() ->
                Expect.equal [ "just a string" ] <|
                    parse { config | cycleIndex = 0 } "just a string"
        , test "erors with orphan closer" <|
            \() ->
                shouldError "a}b should error" <| parse { config | cycleIndex = 0 } "a}b"
        , test "erors with orphan opener" <|
            \() ->
                shouldError "a{b should error" <| parse { config | cycleIndex = 0 } "a{b"
        ]


cycle =
    describe "cycles"
        [ test "cycle at 0" <|
            \() ->
                Expect.equal [ "a" ] <|
                    parse { config | cycleIndex = 0 } "{a|b|c}"
        , test "cycle at 2" <|
            \() ->
                Expect.equal [ "c" ] <|
                    parse { config | cycleIndex = 2 } "{a|b|c}"
        , test "cycle out of bounds" <|
            \() ->
                Expect.equal [ "c" ] <|
                    parse { config | cycleIndex = 9 } "{a|b|c}"
        , test "cycle with empties 1" <|
            \() ->
                Expect.equal [ "" ] <|
                    parse { config | cycleIndex = 1 } "{||ok|no}"
        , test "cycle with empties 2" <|
            \() ->
                Expect.equal [ "ok" ] <|
                    parse { config | cycleIndex = 2 } "{||ok|no}"
        , test "empty cycle" <|
            \() ->
                -- NOTE maybe this should be an error?
                Expect.equal [ "ab" ] <|
                    parse { config | cycleIndex = 2 } "a{}b"
        , test "two cycles" <|
            \() ->
                Expect.equal [ "bb" ] <|
                    parse { config | cycleIndex = 1 } "{a|b|c}{a|b|c}"
        , test "cycle in middle" <|
            \() ->
                Expect.equal [ "hello good bye" ] <|
                    parse { config | cycleIndex = 2 } "hello {world|good} bye"
        , test "cycles on ends" <|
            \() ->
                Expect.equal [ "two three five" ] <|
                    parse { config | cycleIndex = 2 } "{one|two} three {four|five}"
        , describe "cycles that looks similar to a prop (but isn't)" <|
            let
                text =
                    -- note, a keyword ` X|Henry` of would actually match
                    "Meet {Mr. X|Henry}.{  He says you can call him Henry.|}"
            in
            [ test "cycle 0" <|
                \() ->
                    Expect.equal [ "Meet Mr. X.  He says you can call him Henry." ] <|
                        parse config text
            , test "cycle 1" <|
                \() ->
                    Expect.equal [ "Meet Henry." ] <|
                        parse { config | cycleIndex = 1 } text
            ]
        , test "erors with orphan opener in cycle" <|
            \() ->
                shouldError "{abc{xyz} should error" <|
                    parse { config | cycleIndex = 0 } "{abc{xyz}"
        , test "erors with orphan closer outside cycle" <|
            \() ->
                shouldError "{abc}xyz} should error" <|
                    parse { config | cycleIndex = 0 } "{abc}xyz}"
        ]


property =
    describe "property"
        [ test "happy path" <|
            \() ->
                Expect.equal [ "Meet Mr. X." ] <|
                    parse configWithName "Meet {x.name}."
        , test "looks like prop but really cycle" <|
            \() ->
                Expect.equal [ "x.name" ] <|
                    parse configWithName "{x.name|hi}"
        , test "if the keyword function returns an Err it doesn't match (will match as a cycle instead)" <|
            \() ->
                Expect.equal [ "x.name" ] <|
                    parse configWithNameError "{x.name}"
        ]


mixed =
    describe "mixed"
        [ test "nested cycles (works, but no real use case)" <|
            \() ->
                Expect.equal [ "onetwo" ] <|
                    parse { config | cycleIndex = 0 } "{one{two|three}|four}"
        , test "nested cycles 2 (works, but no real use case)" <|
            \() ->
                Expect.equal [ "four" ] <|
                    parse { config | cycleIndex = 1 } "{one{two|three}|four}"
        , describe "basic prop and cycle mix" <|
            [ test "cycle 0, prop 1" <|
                \() ->
                    Expect.equal [ "a" ] <|
                        parse configWithName "{a|{x.name}}"
            , test "cycle 1, prop 1" <|
                \() ->
                    Expect.equal [ "Mr. X" ] <|
                        parse { configWithName | cycleIndex = 1 } "{a|{x.name}}"
            , test "cycle 0, prop 0" <|
                \() ->
                    Expect.equal [ "Mr. X" ] <|
                        parse configWithName "{{x.name}|a}"
            , test "cycle 1, prop 0" <|
                \() ->
                    Expect.equal [ "a" ] <|
                        parse { configWithName | cycleIndex = 1 } "{{x.name}|a}"
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
                    Expect.equal [ "Meet Mr. X.  He says you can call him Henry." ] <|
                        parse nestedConfig text
            , test "cycle 1" <|
                \() ->
                    Expect.equal [ "Henry says hi." ] <|
                        parse { nestedConfig | cycleIndex = 1 } text
            ]
        ]


withContinues =
    describe "continues"
        [ test "basic" <|
            \() ->
                Expect.equal [ "one", "two", "three" ] <|
                    parse { config | cycleIndex = 0 } "one---two---three"
        , test "in cycle 1" <|
            \() ->
                Expect.equal [ "one", "two" ] <|
                    parse { config | cycleIndex = 0 } "{one---two|three}"
        , test "in cycle 2" <|
            \() ->
                Expect.equal [ "three" ] <|
                    parse { config | cycleIndex = 1 } "{one---two|three}"
        ]


shouldError message res =
    Expect.true message <| List.all identity <| List.map (String.startsWith "ERROR") res
