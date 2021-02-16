module TSGenerator exposing (generateTS)

import CParser exposing (Argument, CType, Declaration(..))


ctypeToTS : CType -> String
ctypeToTS ctype =
    case ctype.name of
        "char" ->
            "string"

        "double" ->
            "number"

        "float" ->
            "number"

        "int" ->
            "number"

        _ ->
            ctype.name


argumentsToTS : List Argument -> String
argumentsToTS arguments =
    List.map (\arg -> arg.name ++ ": " ++ ctypeToTS arg.ctype) arguments
        |> String.join ", "


declarationToTS : Declaration -> String
declarationToTS decl =
    case decl of
        Struct name ->
            "export class " ++ name ++ " {}"

        Function fun ->
            "export function " ++ fun.name ++ "(" ++ argumentsToTS fun.arguments ++ "): " ++ ctypeToTS fun.returnType ++ ";"


generateTS : List Declaration -> String
generateTS declarations =
    List.map declarationToTS declarations
        |> String.join "\n"
