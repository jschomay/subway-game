module Tests.Parse exposing (all)

import Expect
import Narrative exposing (..)
import Test exposing (..)


all =
    describe "parsing narrative" <|
        let
            opts =
                { cycleIndex = 0 }
        in
        [ test "empty string" <|
            \() ->
                Expect.equal (Ok "") <|
                    getNarrative { opts | cycleIndex = 0 } ""
        , test "static string" <|
            \() ->
                Expect.equal (Ok "just a string") <|
                    getNarrative { opts | cycleIndex = 0 } "just a string"
        , test "orphan closer" <|
            \() ->
                -- NOTE maybe this should error
                Expect.equal (Ok "a}b") <|
                    getNarrative { opts | cycleIndex = 0 } "a}b"
        , test "orphan opener" <|
            \() ->
                Expect.true "a{b should error" <|
                    case getNarrative { opts | cycleIndex = 0 } "a{b" of
                        Err _ ->
                            True

                        _ ->
                            False

        -- cycles
        , test "cycle at 0" <|
            \() ->
                Expect.equal (Ok "a") <|
                    getNarrative { opts | cycleIndex = 0 } "{a|b|c}"
        , test "cycle at 2" <|
            \() ->
                Expect.equal (Ok "c") <|
                    getNarrative { opts | cycleIndex = 2 } "{a|b|c}"
        , test "cycle out of bounds" <|
            \() ->
                Expect.equal (Ok "c") <|
                    getNarrative { opts | cycleIndex = 9 } "{a|b|c}"
        , test "cycle with empties 1" <|
            \() ->
                Expect.equal (Ok "") <|
                    getNarrative { opts | cycleIndex = 1 } "{||(ok|no}"
        , test "cycle with empties 2" <|
            \() ->
                Expect.equal (Ok "ok") <|
                    getNarrative { opts | cycleIndex = 2 } "{||ok|no}"
        , test "empty cycle" <|
            \() ->
                -- NOTE maybe this should be an error?
                Expect.equal (Ok "ab") <|
                    getNarrative { opts | cycleIndex = 2 } "a{}b"
        , test "two cycles" <|
            \() ->
                Expect.equal (Ok "bb") <|
                    getNarrative { opts | cycleIndex = 1 } "{a|b|c}{a|b|c}"
        , test "cycle in middle" <|
            \() ->
                Expect.equal (Ok "hello good bye") <|
                    getNarrative { opts | cycleIndex = 2 } "hello {world|good} bye"
        , test "cycles on ends" <|
            \() ->
                Expect.equal (Ok "two three five") <|
                    getNarrative { opts | cycleIndex = 2 } "{one|two} three {four|five}"
        , skip <|
            test "orphan opener in cycle" <|
                \() ->
                    Expect.true "{a|b{c} should error" <|
                        case getNarrative { opts | cycleIndex = 0 } "{abc{xyz}" of
                            Err _ ->
                                True

                            _ ->
                                False
        , test "nested cycles" <|
            \() ->
                Expect.equal (Ok "onetwo") <|
                    getNarrative { opts | cycleIndex = 0 } "{one{two|three}four}"

        -- property lookup
        , todo "property"
        ]
