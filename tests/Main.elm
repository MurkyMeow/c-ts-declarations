module Main exposing (suite)

import CParser exposing (Declaration(..), file)
import Expect
import Parser exposing (run)
import TSGenerator exposing (generateTS)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CParser"
        [ test "single struct" <|
            \_ ->
                Ok [ Struct "time_t" ]
                    |> Expect.equal (run file "struct time_t;")
        , test "invalid keyword" <|
            \_ ->
                Expect.err (run file "class time_t;")
        , test "single function without arguments" <|
            \_ ->
                Ok [ Function { returnType = "int", name = "foo", arguments = [] } ]
                    |> Expect.equal (run file "int foo();")
        , test "single function with a single argument" <|
            \_ ->
                Ok [ Function { returnType = "int", name = "foo", arguments = [ { name = "bar", ctype = "char" } ] } ]
                    |> Expect.equal (run file "int foo(char bar);")
        , test "single function with multiple arguments" <|
            \_ ->
                Ok [ Function { returnType = "int", name = "foo", arguments = [ { name = "bar", ctype = "char" }, { name = "baz", ctype = "bool" } ] } ]
                    |> Expect.equal (run file "int foo(char bar, bool baz);")
        , test "a struct and a function" <|
            \_ ->
                Ok
                    [ Struct "mystruct"
                    , Function { returnType = "string", name = "myfunc", arguments = [] }
                    ]
                    |> Expect.equal (run file "struct mystruct;\nstring myfunc();")
        , test "ts generator" <|
            \_ ->
                let
                    input =
                        "struct mystruct;\nstring myfunc(int foo, string bar);"

                    expected =
                        "export class mystruct {}\nexport function myfunc(foo: int, bar: string): string;"
                in
                case run file input of
                    Ok declarations ->
                        Expect.equal expected (generateTS declarations)

                    Err _ ->
                        Expect.fail ""
        ]
