module Data.Environment exposing (Environment(..), toString)


type Environment
    = Development
    | LiveDemo


toString : Environment -> String
toString env =
    case env of
        Development ->
            "development"

        LiveDemo ->
            "demo"
