module Manifest exposing (DisplayComponent, Entity, ID, WorldModel, characters, entity, initialWorldModel, items, locations)

import City exposing (Station(..), stationInfo)
import Constants
import Dict exposing (Dict)
import Narrative.WorldModel exposing (..)


type alias DisplayComponent a =
    { a | name : String, description : String }


type alias Entity =
    NarrativeComponent (DisplayComponent {})


type alias WorldModel =
    Dict String Entity


type alias ID =
    String


entity : ID -> String -> String -> ( String, Entity )
entity id name description =
    ( id
    , { name = name
      , description = description
      , tags = emptyTags
      , stats = emptyStats
      , links = emptyLinks
      }
    )


initialWorldModel : WorldModel
initialWorldModel =
    Dict.fromList <|
        items
            ++ characters
            ++ locations
            ++ general


station : Station -> String
station station_ =
    -- TODO remove this after removing graph
    station_ |> stationInfo |> .id |> String.fromInt


{-| Simple helper to group items/characters by where they are located.
-}
location : String -> List ( ID, Entity ) -> List ( ID, Entity )
location id =
    List.map (link "location" id)


items : List ( ID, Entity )
items =
    List.map (tag "item") <|
        [ entity "map" "Subway map" "A map of all of the subway lines you know about."
            |> tag "silent"
        ]
            -- inventory
            ++ location "home"
                [ entity "briefcase"
                    "Briefcase"
                    "The tool of your trade, and more than that, a badge of honor.  Yours is a tasteful brown leather, perfectly organized (usually), and always by your side."
                , entity "redLinePass"
                    "Red Line metro pass"
                    "This will get you to any station along the Red Line.  Expires in 8 months."
                    |> link "location" "home"
                    |> link "validOn" "redLine"
                , entity "cellPhone"
                    "Cell phone"
                    "It's not one of those $800 ones, but it does everything you need."
                , entity "coffee cup"
                    "Empty coffee cup"
                    "You've gone through a few of these while trying to finish the presentation."
                    |> tag "fixed"
                , entity "presentation"
                    "Scattered papers"
                    "Your desk is littered with the printed out copies of your presentation, covered in scribbles and sticky notes."
                , entity "laptop"
                    "Laptop"
                    "Your laptop battery is almost dead, but you don't need it, you've got the hard copy of your presentation with your notes on it."
                    |> tag "fixed"
                , entity "deskPhone"
                    "Desk phone"
                    "You still have an old school landline in your home office, though you rarely use it."
                    |> tag "fixed"
                ]
            ++ location (station TwinBrooks)
                [ entity "safteyWarningPoster"
                    "Safety Message Poster"
                    "A poster that warns you to watch out for pickpockets and report any suspicious activity. "
                , entity "mapPoster"
                    "Map on the wall"
                    "This shows the full map of the subway system."
                ]
            ++ location (station FederalTriangle)
                [ entity "policeOffice"
                    "Police Office"
                    "A small police office."
                , entity "ticketMachine"
                    "Ticket Machine"
                    "You can buy tickets and passes here."
                ]
            ++ location (station ChurchStreet)
                [ entity "paperScrap"
                    "Scrap of paper"
                    "It's just trash."
                ]
            ++ location (station WestMulberry)
                [ entity "maintenanceDoor"
                    "Maintenance door"
                    "The sign on it says \"Maintenance access only\"."
                ]
            ++ location "maintenanceMan"
                [ entity "keyCard"
                    "Maintenance Key Card"
                    "This will get you in to maintenance areas."
                ]


characters : List ( ID, Entity )
characters =
    List.map (tag "character")
        [ entity "maintenanceMan"
            "Maintenance man"
            "He's probably busy, you don't really have any reason to bother him."
            |> link "location" (station TwinBrooks)
        , entity "largeCrowd"
            "A large crowd"
            "They ignore you for the most part, occupied with the situation at hand."
            |> link "location" (station MetroCenter)
        , entity "securityOfficers"
            "Security officers"
            "Two of them, looking official, but not really all that helpful over all."
            |> link "location" (station MetroCenter)
        , entity "commuter1"
            "Commuter"
            "Another commuter, waiting for the train."
            |> link "location" (station EastMulberry)
        , entity "commuter2"
            "Commuter"
            "Another commuter, waiting for the train."
            |> link "location" (station WestMulberry)
        ]


general : List ( ID, Entity )
general =
    [ entity "player"
        "Steve"
        "A guy just trying to get ahead by following the rules."
        |> stat "mainPlot" 1
        |> link "location" (station TwinBrooks)
        |> (\e -> List.foldl (\{ id, starting } -> stat id starting) e Constants.characterStats)
    ]
        ++ List.map
            (City.lineInfo
                >> (\info ->
                        entity info.id info.name info.name
                            |> tag "line"
                   )
            )
            City.allLines


locations : List ( ID, Entity )
locations =
    let
        stations =
            List.map
                (City.stationInfo
                    >> (\info ->
                            entity (String.fromInt info.id) info.name info.name
                                |> tag "location"
                                |> tag "station"
                                |> (\e ->
                                        if String.fromInt info.id == station MetroCenter then
                                            tag "stevesWork" e

                                        else
                                            e
                                   )
                       )
                )
                (List.concatMap (City.lineInfo >> .stations) City.allLines)
    in
    -- no need to make this unique here, as the world model is a map by id
    (entity "home" "Desk" "Your home office desk is trashed from preparing the presentation all week."
        |> tag "location"
    )
        :: stations
