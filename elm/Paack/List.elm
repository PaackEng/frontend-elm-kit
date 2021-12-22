module Paack.List exposing (..)

import UUID exposing (UUID)


unique : List comparable -> List comparable
unique =
    Set.fromList >> Set.toList


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        head :: tail ->
            if predicate head then
                Just head

            else
                find predicate tail


findById : UUID -> List { a | id : UUID } -> Maybe { a | id : UUID }
findById uuid =
    find (.id >> (==) uuid)


insert : { a | id : UUID } -> List { a | id : UUID } -> List { a | id : UUID }
insert item list =
    list
        |> List.filter (.id >> (/=) item.id)
        |> (::) item


updateById : UUID -> ({ a | id : UUID } -> { a | id : UUID }) -> List { a | id : UUID } -> List { a | id : UUID }
updateById uuid applier list =
    List.map
        (\item ->
            if item.id == uuid then
                applier item

            else
                item
        )
        list


prependMaybe : Maybe a -> List a -> List a
prependMaybe maybeSomething items =
    case maybeSomething of
        Just something ->
            something :: items

        Nothing ->
            items


mapHead : (a -> Maybe b) -> List a -> Maybe b
mapHead filterMap list =
    case list of
        [] ->
            Nothing

        head :: tail ->
            case filterMap head of
                Just match ->
                    Just match

                Nothing ->
                    mapHead filterMap tail
