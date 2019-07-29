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


update : Narrative -> ( List String, Narrative )
update narrative =
    case narrative of
        InOrder zipper ->
            let
                story =
                    case Zipper.current zipper of
                        "" ->
                            []

                        text ->
                            String.split "---" text
            in
            ( story, InOrder (Zipper.next zipper |> Maybe.withDefault zipper) )
