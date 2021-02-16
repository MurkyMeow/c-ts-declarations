port module Worker exposing (main)

import CParser exposing (parseFile)
import Platform
import TSGenerator exposing (generateTS)


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg


type alias Flags =
    ()


type alias Model =
    ()


type Msg
    = Recv String


init : Flags -> ( Model, Cmd msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Recv str ->
            case parseFile str |> Result.map generateTS of
                Ok result ->
                    ( model, sendMessage result )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : a -> Sub Msg
subscriptions _ =
    messageReceiver Recv


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
