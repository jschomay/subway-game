module Manifest exposing (DisplayComponent, Entity, ID, WorldModel, entities, entity, initialWorldModel)

import Constants
import Dict exposing (Dict)
import Narrative.WorldModel exposing (..)
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
        |> Result.mapError (\e -> ( entityString, e ))


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
    [ entity "MAP.item.map.silent"
        "Subway map"
        "A map of all of the subway lines you know about."

    -- home
    , entity "BRIEFCASE.item.location=PLAYER"
        "Briefcase"
        "The tool of your trade, and more than that, a badge of honor.  Yours is a tasteful brown leather, perfectly organized (usually), and always by your side."
    , entity "RED_LINE_PASS.item.location=PLAYER.valid_on=RED_LINE"
        "Red Line metro pass"
        "This will get you to any station along the Red Line.  Expires in 8 months."
    , entity "CELL_PHONE.item.location=PLAYER"
        "Cell phone"
        "It's not one of those $800 ones, but it does everything you need."
    , entity "COFFEE_CUP.item.fixed.location=HOME"
        "Empty coffee cup"
        "You've gone through a few of these while trying to finish the presentation."
    , entity "PRESENTATION.item.location=HOME"
        "Scattered papers"
        "Your desk is littered with the printed out copies of your presentation, covered in scribbles and sticky notes."
    , entity "LAPTOP.item.fixed.location=HOME"
        "Laptop"
        "Your laptop battery is almost dead, but you don't need it, you've got the hard copy of your presentation with your notes on it."
    , entity "DESK_PHONE.item.fixed.location=HOME"
        "Desk phone"
        "You still have an old school landline in your home office, though you rarely use it."
    , entity "CENTRAL_GUARD_OFFICE.location"
        "Central Guard Office"
        "You know you're in trouble if you are here."

    --  TwinBrooks
    , entity "SAFTEY_WARNING_POSTER.item.location=TWIN_BROOKS"
        "Safety Message Poster"
        "A poster that warns you to watch out for pickpockets and report any suspicious activity. "
    , entity "MAP_POSTER.item.map.location=TWIN_BROOKS"
        "Map on the wall"
        "This shows the full map of the subway system."

    --  FederalTriangle
    , entity "POLICE_OFFICE.item.location=FEDERAL_TRIANGLE"
        "Police Office"
        "A small police office."
    , entity "TICKET_MACHINE.item.location=FEDERAL_TRIANGLE"
        "Ticket Machine"
        "You can buy tickets and passes here."

    --  ChurchStreet
    , entity "PAPER_SCRAP.item.location=CHURCH_STREET"
        "Scrap of paper"
        "It's just trash."

    -- WestMulberry
    , entity "MAINTENANCE_DOOR.item.location=WEST_MULBERRY"
        "Maintenance door"
        "The sign on it says \"Maintenance access only\"."

    -- maintenanceMan
    , entity "KEY_CARD.item.location=MAINTENANCE_MAN"
        "Maintenance Key Card"
        "This will get you in to maintenance areas."

    -- characters
    , entity "MAINTENANCE_MAN.character.location=TWIN_BROOKS"
        "Maintenance man"
        "He's probably busy, you don't really have any reason to bother him."
    , entity "LARGE_CROWD.character.location=METRO_CENTER"
        "A large crowd"
        "They ignore you for the most part, occupied with the situation at hand."
    , entity "SECURITY_OFFICERS.character.location=METRO_CENTER"
        "Security officers"
        "Two of them, looking official, but not really all that helpful over all."
    , entity "COMMUTER_1.character.location=EAST_MULBERRY"
        "Commuter"
        "Another commuter, waiting for the train."
    , entity "COMMUTER_2.character.location=WEST_MULBERRY"
        "Commuter"
        "Another commuter, waiting for the train."
    , entity "PLAYER.main_plot=1.location=TWIN_BROOKS"
        "Steve"
        "A guy just trying to get ahead by following the rules."
    , entity "HOME.location"
        "Home"
        "Your tiny apartment."
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
