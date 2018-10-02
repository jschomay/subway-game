module Views.Train exposing (view)

import City exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import LocalTypes exposing (..)
import Markdown


view : Line -> Station -> Station -> Maybe Station -> TrainStatus -> Bool -> Bool -> Bool -> Maybe String -> Html Msg
view line end currentStation nextStation status isStopped isIntro isFriday storyLine =
    let
        nextStop =
            case ( status, nextStation ) of
                ( Moving, Just next ) ->
                    "Next stop: " ++ (stationInfo next |> .name)

                ( Moving, Nothing ) ->
                    "Out of service"

                ( Stopped, Just next ) ->
                    "Arriving at: " ++ (stationInfo currentStation |> .name)

                ( Stopped, Nothing ) ->
                    "End of the line: " ++ (stationInfo currentStation |> .name)

                ( OutOfService, Just next ) ->
                    "Out of service: " ++ (stationInfo currentStation |> .name)

                ( OutOfService, Nothing ) ->
                    "Out of service"

        info =
            (lineInfo line |> .name) ++ " towards " ++ (stationInfo end |> .name)

        buttonClasses =
            classList
                [ ( "exit_button", True )
                , ( "exit_button--active", isStopped )
                ]

        stationClasses =
            classList
                [ ( "train__backgroundStation", True )
                , ( "train__backgroundStation--enter", isStopped )
                , ( "train__backgroundStation--exit", not isStopped )
                ]

        tunnelClasses =
            classList
                [ ( "train__backgroundTunnel", not isStopped ) ]

        action =
            if isStopped then
                [ onClick ExitTrain ]

            else
                []

        backgroundTunnel =
            div [ tunnelClasses ] []

        backgroundStation =
            div [ stationClasses ]
                [ h2 [ class "train__staiton-name" ] [ text (stationInfo currentStation |> .name) ]
                ]

        foreground =
            div [ class "train__foreground" ]
                [ div [ class "train__top" ] <|
                    [ div [ class "train__ticker" ]
                        [ h4 [ class "train__info" ] [ text info ]
                        , h3 [ class "train__next_stop" ] [ text nextStop ]
                        ]
                    ]
                        ++ (if isIntro then
                                []

                            else
                                [ button (buttonClasses :: action) [ text "Exit train" ]
                                ]
                           )
                , div [ class "train__doors" ] <|
                    [ div [ class "train__door train__door--left" ] []
                    , div [ class "train__door train__door--right" ] []
                    ]
                ]

        story storyLine_ =
            div [ class "train__story" ] [ storyView storyLine_ <| isIntro && not isFriday ]
    in
    div [ class "train" ] <|
        List.filterMap identity
            [ Just backgroundTunnel
            , Just backgroundStation
            , Just foreground
            , Maybe.map story storyLine
            ]


storyView : String -> Bool -> Html Msg
storyView storyLine showContinue =
    Html.Keyed.node "div"
        [ class "StoryLine" ]
        [ ( storyLine
          , div [ class "StoryLine__content" ] <|
                [ Markdown.toHtml [] storyLine ]
                    ++ (if showContinue then
                            [ span [ class "StoryLine__continue", onClick Continue ] [ text "Continue..." ] ]

                        else
                            []
                       )
          )
        ]
