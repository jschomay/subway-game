module Manifest exposing (DisplayComponent, Entity, ID, WorldModel, entities, entity, initialWorldModel)

import Constants
import Dict exposing (Dict)
import Narrative.WorldModel exposing (..)
import NarrativeContent exposing (t)
import Rules.Parser exposing (..)
import Subway exposing (Station)


type alias DisplayComponent a =
    { a | name : String, description : String }


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


entity : String -> String -> String -> ParsedEntity
entity entityString name desc =
    parseEntity entityString
        |> Result.map (addDisplayable name desc)
        |> Result.mapError (\e -> ( "Entity def: " ++ entityString, e ))


addDisplayable : String -> String -> ( ID, NarrativeComponent {} ) -> ( ID, Entity )
addDisplayable name desc ( id, { tags, stats, links } ) =
    ( id
    , { tags = tags
      , stats = stats
      , links = links
      , name = name
      , description = desc
      }
    )


entities : List ParsedEntity
entities =
    [ entity "PLAYER.chapter=1.day=1.location=WEST_MULBERRY.destination=METRO_CENTER"
        "Steve"
        "Here I am."

    -- inventory
    , entity "BRIEFCASE.item.location=PLAYER"
        "Briefcase"
        "My portable office, all my work is in it."
    , entity "RED_LINE_PASS.item.location=PLAYER.valid_on=RED_LINE"
        "Red Line metro pass"
        "This gets me anywhere on the Red Line, but I really only use it to get to work and back home."
    , entity "CELL_PHONE.item.location=PLAYER.unread"
        "Cell phone"
        "I'm never more than a call or email way."
    , entity "MAP.item.map.silent"
        "Subway map"
        "The full subway map."

    -- other locations
    , entity "CENTRAL_GUARD_OFFICE.location"
        "Central Guard Office"
        ""
    , entity "LOBBY.location"
        "Station Lobby"
        ""

    -- WEST_MULBERRY
    , entity "COFFEE_CART.character.location=WEST_MULBERRY"
        "Coffee cart"
        "I've been getting Carl's Coffee for years."
    , entity "COFFEE.item.location=offscreen"
        "Coffee"
        "My morning Joe."

    --  TWIN_BROOKS
    , entity "SAFTEY_WARNING_POSTER.item.location=TWIN_BROOKS"
        "Safety Message Poster"
        "It says to watch out for pickpockets and report any suspicious activity."
    , entity "MAP_POSTER.item.map.location=TWIN_BROOKS"
        "Map on the wall"
        "This shows the full map of the subway system."
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
                        entity (info.id ++ ".line") info.name info.name
                   )
            )


stations : List ParsedEntity
stations =
    let
        makeId id =
            id
                ++ ".loation.station"
                ++ (if id == "METRO_CENTER" then
                        ".steves_work"

                    else
                        ""
                   )
    in
    Subway.stations
        |> Dict.toList
        |> List.map
            (\( id, { name } ) ->
                entity (makeId id) name name
            )
