module SubwaySimple exposing (Map, connections)

{-| A simpler subway that has a list of lines where each line lists the stations it services.
-}


type alias Line line station =
    ( line, List station )


type alias Map line station =
    List (Line line station)


{-| Returns all lines servicing the supplied station. Does not specify an order
(can't return a `Set` because `line` isn't comparable).
-}
connections :
    Map line station
    -> station
    -> List line
connections map currentStation =
    List.foldl
        (\( line, stations ) acc ->
            if List.member currentStation stations then
                line :: acc

            else
                acc
        )
        []
        map
