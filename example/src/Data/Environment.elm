module Data.Environment exposing (Environment(..), toString)


type Environment
    = Development
    | Production


toString : Environment -> String
toString env =
    case env of
        Development ->
            "development"

        Production ->
            "producion"
