module CParser exposing (Argument, Declaration(..), parseFile)

import Parser exposing ((|.), (|=), Parser, Step(..), Trailing(..))
import Set


type alias Argument =
    { ctype : String
    , name : String
    }


type alias FunctionParams =
    { returnType : String
    , name : String
    , arguments : List Argument
    }


type Declaration
    = Struct String
    | Function FunctionParams


cvariable : Parser String
cvariable =
    Parser.variable
        { start = Char.isAlpha
        , inner = \c -> Char.isAlphaNum c || c == '_'
        , reserved = Set.empty
        }


struct : Parser Declaration
struct =
    Parser.succeed Struct
        |. Parser.keyword "struct"
        |. Parser.spaces
        |= cvariable
        |. Parser.symbol ";"


argument : Parser Argument
argument =
    Parser.succeed Argument
        |= cvariable
        |. Parser.spaces
        |= cvariable


arguments : Parser (List Argument)
arguments =
    Parser.sequence
        { start = "("
        , separator = ", "
        , end = ");"
        , spaces = Parser.spaces
        , item = argument
        , trailing = Optional
        }


function : Parser Declaration
function =
    Parser.succeed Function
        |= (Parser.succeed FunctionParams
                |= cvariable
                |. Parser.spaces
                |= cvariable
                |. Parser.spaces
                |= arguments
           )


declaration : Parser Declaration
declaration =
    Parser.oneOf
        [ struct
        , function
        ]


file : Parser (List Declaration)
file =
    Parser.loop [] <|
        \revDeclarations ->
            Parser.oneOf
                [ Parser.succeed (\decl -> Loop (decl :: revDeclarations))
                    |. Parser.spaces
                    |= declaration
                    |. Parser.spaces
                , Parser.succeed ()
                    |> Parser.map (\_ -> Done (List.reverse revDeclarations))
                ]


parseFile : String -> Result (List Parser.DeadEnd) (List Declaration)
parseFile str =
    Parser.run file str
