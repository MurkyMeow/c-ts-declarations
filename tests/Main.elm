module Main exposing (suite)

import CParser exposing (Declaration(..), Len(..), Sign(..), parseFile)
import Expect
import TSGenerator exposing (generateTS)
import Test exposing (Test, describe, skip, test)


commontype : CParser.CType
commontype =
    { sign = Nothing
    , len = Nothing
    , name = "int"
    , isPointer = False
    }


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
                Ok [ Function { returnType = commontype, name = "foo", arguments = [] } ]
                    |> Expect.equal (parseFile "int foo();")
        , test "single function with a single argument" <|
            \_ ->
                Ok [ Function { returnType = commontype, name = "foo", arguments = [ { name = "bar", ctype = { commontype | name = "char" } } ] } ]
                    |> Expect.equal (parseFile "int foo(char bar);")
        , test "single function with multiple arguments" <|
            \_ ->
                let
                    arguments =
                        [ { name = "bar", ctype = { commontype | name = "char" } }
                        , { name = "baz", ctype = { commontype | name = "bool" } }
                        ]
                in
                Ok [ Function { returnType = commontype, name = "foo", arguments = arguments } ]
                    |> Expect.equal (parseFile "int foo(char bar, bool baz);")
        , test "a struct and a function" <|
            \_ ->
                Ok
                    [ Struct "mystruct"
                    , Function { returnType = { commontype | name = "string" }, name = "myfunc", arguments = [] }
                    ]
                    |> Expect.equal (parseFile "struct mystruct;\nstring myfunc();")
        , test "arguments with type modifiers" <|
            \_ ->
                let
                    arguments =
                        [ { name = "a", ctype = { commontype | sign = Just Unsigned } }
                        , { name = "b", ctype = { commontype | sign = Just Signed } }
                        , { name = "c", ctype = { commontype | len = Just Long } }
                        , { name = "d", ctype = { commontype | len = Just Short } }
                        ]
                in
                Ok [ Function { returnType = commontype, name = "foo", arguments = arguments } ]
                    |> Expect.equal (parseFile "int foo(unsigned int a, signed int b, long int c, short int d);")
        , skip <|
            test "arguments with type modifiers (complex cases)" <|
                \_ ->
                    let
                        arguments =
                            [ { name = "a", ctype = { commontype | name = "long", len = Just Long } }
                            , { name = "b", ctype = { commontype | name = "long", sign = Just Unsigned, len = Just Long } }
                            , { name = "c", ctype = { commontype | name = "long" } }
                            ]
                    in
                    Ok [ Function { returnType = commontype, name = "foo", arguments = arguments } ]
                        |> Expect.equal (parseFile "int foo(long long a, unsigned long long b, long c);")
        , test "pointer arguments" <|
            \_ ->
                let
                    arguments =
                        [ { name = "a", ctype = { commontype | isPointer = True } }
                        , { name = "b", ctype = { commontype | isPointer = True } }
                        , { name = "c", ctype = { commontype | sign = Just Unsigned, isPointer = True } }
                        ]
                in
                Ok [ Function { returnType = commontype, name = "foo", arguments = arguments } ]
                    |> Expect.equal (parseFile "int foo(int * a, int * b, unsigned int* c);")
        , test "complex return type" <|
            \_ ->
                Ok [ Function { returnType = { sign = Just Unsigned, len = Just Long, name = "int", isPointer = True }, name = "foo", arguments = [] } ]
                    |> Expect.equal (parseFile "unsigned long int* foo();")
        , test "ts generator" <|
            \_ ->
                let
                    input =
                        "struct mystruct;\ndouble myfunc(int foo, char bar);"

                    expected =
                        "export class mystruct {}\nexport function myfunc(foo: number, bar: string): number;"
                in
                Expect.equal (Ok expected) (parseFile input |> Result.map generateTS)
        ]
