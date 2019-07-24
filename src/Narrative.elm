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
    InOrder <| Zipper.withDefault "" <| Zipper.fromList l


update : Narrative -> ( Maybe String, Narrative )
update narrative =
    case narrative of
        InOrder zipper ->
            let
                story =
                    if Zipper.current zipper |> String.isEmpty then
                        Nothing

                    else
                        Just <| Zipper.current zipper
            in
            ( story, InOrder (Zipper.next zipper |> Maybe.withDefault zipper) )
