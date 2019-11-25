module Manifest exposing (DisplayComponent, Entity, ID, WorldModel, entities, entity, initialWorldModel)

import Constants
import Dict exposing (Dict)
import Narrative.WorldModel exposing (..)
import NarrativeContent exposing (t)
import Rules.Parser exposing (..)
import Subway exposing (Station)


type alias DisplayComponent a =
    { a | name : String }


type alias Entity =
    NarrativeComponent (DisplayComponent {})


type alias WorldModel =
    Dict ID Entity


type alias ID =
    String


{-| note that this is different than the one in Rules.Parser! This one is for an
`Entity`, not a `NarrativeComponent {}`, and this one shows the original string in
the error
-}
type alias ParsedEntity =
    Result ( String, ParseError ) ( ID, Entity )


initialWorldModel : ( WorldModel, List ( String, ParseError ) )
initialWorldModel =
    let
        separateErrors parsedEntity acc =
            case parsedEntity of
                Ok ( id, components ) ->
                    Tuple.mapFirst (Dict.insert id components) acc

                Err err ->
                    Tuple.mapSecond ((::) err) acc
    in
    entities
        |> List.foldl separateErrors ( Dict.empty, [] )


entity : String -> String -> ParsedEntity
entity entityString name =
    parseEntity entityString
        |> Result.map (addDisplayable name)
        |> Result.mapError (\e -> ( "Entity def: " ++ entityString, e ))


addDisplayable : String -> ( ID, NarrativeComponent {} ) -> ( ID, Entity )
addDisplayable name ( id, { tags, stats, links } ) =
    ( id
    , { tags = tags
      , stats = stats
      , links = links
      , name = name
      }
    )


entities : List ParsedEntity
entities =
    [ entity "PLAYER.chapter=1.day=1.location=WEST_MULBERRY.destination=BROADWAY_STREET"
        "Steve"

    -- inventory
    , entity "BRIEFCASE.item.location=PLAYER"
        "Briefcase"
    , entity "RED_LINE_PASS.item.location=PLAYER.valid_on=RED_LINE"
        "Red Line metro pass"
    , entity "CELL_PHONE.item.location=PLAYER.unread"
        "Cell phone"
    , entity "MAP.item.map.silent"
        "Subway map"

    -- other locations
    , entity "CENTRAL_GUARD_OFFICE.location"
        "Central Guard Office"
    , entity "LOBBY.location"
        "Station Lobby"

    -- WEST_MULBERRY
    , entity "COFFEE_CART.character.location=WEST_MULBERRY"
        "Coffee cart"
    , entity "COFFEE.item.location=offscreen"
        "Coffee"
    , entity "COMMUTER_1.character.location=WEST_MULBERRY"
        "Plainly dressed commuter"
    , entity "LOUD_PAYPHONE_LADY.character.location=WEST_MULBERRY"
        "Loud woman on pay phone"
    , entity "TRASH_DIGGER.character.location=offscreen"
        "Man digging in the trash"
    , entity "SKATER_DUDE.character.location=offscreen"
        "Skater dude"
    , entity "GRAFFITI.item.location=WEST_MULBERRY"
        "Graffiti on the wall"
    , entity "BENCH_BUM.character.location=offscreen"
        "Guy sleeping on a bench"
    , entity "SODA_MACHINE.item.broken.location=WEST_MULBERRY"
        "Soda vending machine"

    --  TWIN_BROOKS
    , entity "SAFETY_WARNING_POSTER.item.location=TWIN_BROOKS"
        "Safety message poster"
    , entity "MAP_POSTER.item.map.location=TWIN_BROOKS"
        "Map on the wall"

    --  BROADWAY_STREET
    , entity "MUSICIAN.character.location=BROADWAY_STREET"
        "Man playing violin"
    ]
        ++ lines
        ++ stations



-- lines and stations are easier to build from the data at the moment


lines : List ParsedEntity
lines =
    Subway.fullMap
        |> List.map Tuple.first
        |> List.map
            (Subway.lineInfo
                >> (\info ->
                        entity (info.id ++ ".line") info.name
                   )
            )


stations : List ParsedEntity
stations =
    let
        makeId id =
            id
                ++ ".station"
                ++ (if id == "BROADWAY_STREET" then
                        ".steves_work"

                    else
                        ""
                   )
    in
    Subway.stations
        |> Dict.toList
        |> List.map
            (\( id, { name } ) ->
                entity (makeId id) name
            )
