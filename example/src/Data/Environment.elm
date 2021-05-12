module Data.Environment exposing (Environment(..), toString)


type Environment
    = Development


toString : Environment -> String
toString env =
    case env of
        Development ->
            "development"
