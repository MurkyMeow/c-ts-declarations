module Main exposing (suite)

import CParser exposing (Declaration(..), Len(..), Sign(..), parseFile)
import Expect
import TSGenerator exposing (generateTS)
import Test exposing (Test, describe, skip, test)


suite : Test
suite =
    describe "CParser"
        [ test "single struct" <|
            \_ ->
                Ok [ Struct "time_t" ]
                    |> Expect.equal (parseFile "struct time_t;")
        , test "invalid keyword" <|
            \_ ->
                Expect.err (parseFile "class time_t;")
        , test "single function without arguments" <|
            \_ ->
                Ok [ Function { returnType = "int", name = "foo", arguments = [] } ]
                    |> Expect.equal (parseFile "int foo();")
        , test "single function with a single argument" <|
            \_ ->
                Ok [ Function { returnType = "int", name = "foo", arguments = [ { name = "bar", ctype = "char", sign = Nothing, len = Nothing } ] } ]
                    |> Expect.equal (parseFile "int foo(char bar);")
        , test "single function with multiple arguments" <|
            \_ ->
                let
                    arguments =
                        [ { name = "bar", ctype = "char", sign = Nothing, len = Nothing }
                        , { name = "baz", ctype = "bool", sign = Nothing, len = Nothing }
                        ]
                in
                Ok [ Function { returnType = "int", name = "foo", arguments = arguments } ]
                    |> Expect.equal (parseFile "int foo(char bar, bool baz);")
        , test "a struct and a function" <|
            \_ ->
                Ok
                    [ Struct "mystruct"
                    , Function { returnType = "string", name = "myfunc", arguments = [] }
                    ]
                    |> Expect.equal (parseFile "struct mystruct;\nstring myfunc();")
        , test "arguments with type modifiers" <|
            \_ ->
                let
                    arguments =
                        [ { name = "a", ctype = "int", sign = Just Unsigned, len = Nothing }
                        , { name = "b", ctype = "int", sign = Just Signed, len = Nothing }
                        , { name = "c", ctype = "int", sign = Nothing, len = Just Long }
                        , { name = "d", ctype = "int", sign = Nothing, len = Just Short }
                        ]
                in
                Ok [ Function { returnType = "int", name = "foo", arguments = arguments } ]
                    |> Expect.equal (parseFile "int foo(unsigned int a, signed int b, long int c, short int d);")
        , skip <|
            test "arguments with type modifiers (complex cases)" <|
                \_ ->
                    let
                        arguments =
                            [ { name = "a", ctype = "long", sign = Nothing, len = Just Long }
                            , { name = "b", ctype = "long", sign = Just Unsigned, len = Just Long }
                            , { name = "c", ctype = "long", sign = Nothing, len = Nothing }
                            ]
                    in
                    Ok [ Function { returnType = "int", name = "foo", arguments = arguments } ]
                        |> Expect.equal (parseFile "int foo(long long a, unsigned long long b, long c);")
        , test "ts generator" <|
            \_ ->
                let
                    input =
                        "struct mystruct;\nstring myfunc(int foo, char bar);"

                    expected =
                        "export class mystruct {}\nexport function myfunc(foo: number, bar: string): string;"
                in
                case parseFile input of
                    Ok declarations ->
                        Expect.equal expected (generateTS declarations)

                    Err _ ->
                        Expect.fail ""
        ]
