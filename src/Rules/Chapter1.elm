module Rules.Chapter1 exposing (rules)

import Dict
import Rules.Helpers exposing (..)


rules : RulesSpec
rules =
    Dict.empty
        |> rule_______________________ "getMap"
            """
            ON: MAP_POSTER
            IF: MAP.!location=PLAYER
            DO: MAP.location=PLAYER
            """
        |> rule_______________________ "delaysAtBroadwayStreetStation"
            """
            ON: BROADWAY_STREET
            IF: PLAYER.destination=BROADWAY_STREET.chapter=1
            DO: PLAYER.location=BROADWAY_STREET.destination=xxx
                BROADWAY_STREET.out_of_service
                COMMUTER_1.location=BROADWAY_STREET
            """
        |> rule_______________________ "notGoingToWorkAgain"
            """
            ON: *.station
            IF: PLAYER.destination=BROADWAY_STREET.chapter=1
            """
        |> rule_______________________ "leavingBroadwayStationPrematurely"
            """
            ON: *.line
            IF: PLAYER.location=BROADWAY_STREET
                BROADWAY_STREET.leaving_broadway_street_station_plot<1
            """
        |> rule_______________________ "askOfficersAboutDelay"
            """
            ON: SECURITY_OFFICERS
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot<2
            DO: BROADWAY_STREET.leaving_broadway_street_station_plot=1
                PLAYER.present_proposal+1
            """
        |> rule_______________________ "askCommuter1AboutDelay"
            """
            ON: COMMUTER_1
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot<2
                PLAYER.chapter=1
            """
        |> rule_______________________ "noticeGirlInYellow"
            """
            ON: GIRL_IN_YELLOW
            IF: PLAYER.chapter=1
            DO: GIRL_IN_YELLOW.who_was_girl_in_yellow_quest=1
                GIRL_IN_YELLOW.location=offscreen
            """
        |> rule_______________________ "briefcaseStolen"
            """
            ON: *.line
            IF: PLAYER.chapter=1
                BROADWAY_STREET.leaving_broadway_street_station_plot=1
            DO: BRIEFCASE.location=THIEF
                BROADWAY_STREET.leaving_broadway_street_station_plot=2
                GIRL_IN_YELLOW.location=offscreen
                PLAYER.find_briefcase=1.present_proposal+1
            """
        |> rule_______________________ "tellOfficersAboutStolenBriefcase"
            """
            ON: SECURITY_OFFICERS
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=2
            DO: BROADWAY_STREET.leaving_broadway_street_station_plot=3
            """
        |> rule_______________________ "tellCommuter1AboutStolenBriefcase"
            """
            ON: COMMUTER_1
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot>1
            """
        |> rule_______________________ "followGuardsAdvice"
            """
            ON: SPRING_HILL
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=3
                PLAYER.chapter=1
            DO: PLAYER.location=SPRING_HILL
                BROADWAY_STREET.leaving_broadway_street_station_plot=4
            """
        |> rule_______________________ "ignoreGuardsAdvice"
            """
            ON: *.station
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=3
                PLAYER.chapter=1
            DO: PLAYER.location=$
                BROADWAY_STREET.leaving_broadway_street_station_plot=4
            """
        |> rule_______________________ "panic"
            """
            ON: *.station
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot=2
                PLAYER.chapter=1
            DO: PLAYER.location=$
                BROADWAY_STREET.leaving_broadway_street_station_plot=4
            """
        |> rule_______________________ "findingSecurityDepotClosed"
            """
            ON: SECURITY_DEPOT_SPRING_HILL_STATION
            IF: BROADWAY_STREET.leaving_broadway_street_station_plot<5
                PLAYER.chapter=1
            DO: BROADWAY_STREET.leaving_broadway_street_station_plot=5
            """
