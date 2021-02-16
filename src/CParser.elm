module CParser exposing (Argument, Declaration(..), Len(..), Sign(..), parseFile)

import Parser exposing ((|.), (|=), Parser, Step(..), Trailing(..))
import Set


type Sign
    = Signed
    | Unsigned


type Len
    = Short
    | Long


type alias Argument =
    { sign : Maybe Sign
    , len : Maybe Len
    , ctype : String
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


sign : Parser (Maybe Sign)
sign =
    Parser.oneOf
        [ Parser.map (\_ -> Just Signed) (Parser.keyword "signed")
        , Parser.map (\_ -> Just Unsigned) (Parser.keyword "unsigned")
        , Parser.succeed Nothing
        ]


len : Parser (Maybe Len)
len =
    Parser.oneOf
        [ Parser.map (\_ -> Just Long) (Parser.keyword "long")
        , Parser.map (\_ -> Just Short) (Parser.keyword "short")
        , Parser.succeed Nothing
        ]


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
        |= sign
        |. Parser.spaces
        |= len
        |. Parser.spaces
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
