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
    [ entity "PLAYER.chapter=0.day=1.location=WEST_MULBERRY.destination=BROADWAY_STREET"
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
    , entity "MAINTENANCE_MAN.character.location=TWIN_BROOKS"
        "Maintenance man"

    --  BROADWAY_STREET
    , entity "MUSICIAN.character.location=BROADWAY_STREET"
        "Man playing violin"

    -- Stations
    , entity "ONE_HUNDRED_FOURTH_STREET.station" "104th Street"
    , entity "FOURTY_SECOND_STREET.station" "42nd Street"
    , entity "SEVENTY_THIRD_STREET.station" "73rd Street"
    , entity "BROADWAY_STREET.station" "Broadway Street"
    , entity "BURLINGTON.station" "Burlington"
    , entity "CAPITOL_HEIGHTS.station" "Capitol Heights"
    , entity "CHURCH_STREET.station" "Church Street"
    , entity "CONVENTION_CENTER.station" "Convention Center"
    , entity "EAST_MULBERRY.station" "East Mulberry"
    , entity "FAIRVIEW.station" "Fairview"
    , entity "HIGHLAND.station" "Highland"
    , entity "IRIS_LAKE.station" "Iris Lake"
    , entity "MACARTHURS_PARK.station" "MacArthur's Park"
    , entity "MUSEUM.station" "Museum"
    , entity "NORWOOD.station" "Norwood"
    , entity "PARK_AVE.station" "Park Street"
    , entity "RIVERSIDE.station" "Riverside"
    , entity "SAMUAL_STREET.station" "Samual Street"
    , entity "SPRING_HILL.station" "Spring Hill"
    , entity "ST_MARKS.station" "St. Mark's"
    , entity "TWIN_BROOKS.station" "Twin Brooks"
    , entity "UNIVERSITY.station" "University"
    , entity "WALTER_HILL.station" "Walter Hill"
    , entity "WESTGATE.station" "Westgate"
    , entity "WEST_MULBERRY.station" "West Mulberry"

    -- Lines
    , entity "RED_LINE.line" "Red line"
    , entity "YELLOW_LINE.line" "Yellow line"
    , entity "GREEN_LINE.line" "Green line"
    , entity "ORANGE_LINE.line" "Orange line"
    , entity "BLUE_LINE.line" "Blue line"
    , entity "PURPLE_LINE.line" "Purple line"
    ]



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
