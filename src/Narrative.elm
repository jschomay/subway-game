module Narrative exposing
    ( Narrative(..)
    , inOrder
    , update
    )

import List.Zipper as Zipper exposing (Zipper)


type Narrative
    = InOrder (Zipper String)


inOrder : List String -> Narrative
inOrder l =
    InOrder <| Zipper.withDefault "..." <| Zipper.fromList l


update : Narrative -> ( String, Narrative )
update narrative =
    case narrative of
        InOrder zipper ->
            ( Zipper.current zipper, InOrder (Zipper.next zipper |> Maybe.withDefault zipper) )
