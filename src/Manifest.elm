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
    [ entity "map.item.silent"
        "Subway map"
        "A map of all of the subway lines you know about."

    -- home
    , entity "briefcase.item.location=home"
        "Briefcase"
        "The tool of your trade, and more than that, a badge of honor.  Yours is a tasteful brown leather, perfectly organized (usually), and always by your side."
    , entity "redLinePass.item.location=home.validOn=redLine"
        "Red Line metro pass"
        "This will get you to any station along the Red Line.  Expires in 8 months."
    , entity "cellPhone.item.location=home"
        "Cell phone"
        "It's not one of those $800 ones, but it does everything you need."
    , entity "coffeeCup.item.fixed.location=home"
        "Empty coffee cup"
        "You've gone through a few of these while trying to finish the presentation."
    , entity "presentation.item.location=home"
        "Scattered papers"
        "Your desk is littered with the printed out copies of your presentation, covered in scribbles and sticky notes."
    , entity "laptop.item.fixed.location=home"
        "Laptop"
        "Your laptop battery is almost dead, but you don't need it, you've got the hard copy of your presentation with your notes on it."
    , entity "deskPhone.item.fixed.location=home"
        "Desk phone"
        "You still have an old school landline in your home office, though you rarely use it."

    --  TwinBrooks
    , entity "safteyWarningPoster.item.location=TwinBrooks"
        "Safety Message Poster"
        "A poster that warns you to watch out for pickpockets and report any suspicious activity. "
    , entity "mapPoster.item.location=TwinBrooks"
        "Map on the wall"
        "This shows the full map of the subway system."

    --  FederalTriangle
    , entity "policeOffice.item.location=FederalTriangle"
        "Police Office"
        "A small police office."
    , entity "ticketMachine.item.location=FederalTriangle"
        "Ticket Machine"
        "You can buy tickets and passes here."

    --  ChurchStreet
    , entity "paperScrap.item.location=ChurchStreet"
        "Scrap of paper"
        "It's just trash."

    -- WestMulberry
    , entity "maintenanceDoor.item.location=WestMulberry"
        "Maintenance door"
        "The sign on it says \"Maintenance access only\"."

    -- maintenanceMan
    , entity "keyCard.item.location=maintenanceMan"
        "Maintenance Key Card"
        "This will get you in to maintenance areas."

    -- characters
    , entity "maintenanceMan.character.location=TwinBrooks"
        "Maintenance man"
        "He's probably busy, you don't really have any reason to bother him."
    , entity "largeCrowd.character.location=MetroCenter"
        "A large crowd"
        "They ignore you for the most part, occupied with the situation at hand."
    , entity "securityOfficers.character.location=MetroCenter"
        "Security officers"
        "Two of them, looking official, but not really all that helpful over all."
    , entity "commuter1.character.location=EastMulberry"
        "Commuter"
        "Another commuter, waiting for the train."
    , entity "commuter2.character.location=WestMulberry"
        "Commuter"
        "Another commuter, waiting for the train."
    , entity "player.mainPlot=1.location=TwinBrooks"
        "Steve"
        "A guy just trying to get ahead by following the rules."
    , entity "home.location"
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
                ++ (if id == "MetroCenter" then
                        ".stevesWork"

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
