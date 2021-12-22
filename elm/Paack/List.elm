module Paack.List exposing (flip, maybePrepend, findById, insert, updateById)

import UUID exposing (UUID)



unique : List comparable -> List comparable
unique =
    Set.fromList >> Set.toList

findById : UUID -> List { a | id : UUID } -> Maybe { a | id : UUID }
findById uuid list =
    list
        |> List.filter (.id >> (==) uuid)
        |> List.head


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
