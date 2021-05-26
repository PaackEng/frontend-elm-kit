module Paack.Mixpanel exposing
    ( Client
    , Event
    , Id
    , Mixpanel
    , Property
    , dispatch
    , dispatchInterval
    , enqueue
    , identify
    , init
    , performDispatch
    , performIdentify
    , reset
    )

import Http exposing (Expect)
import Json.Encode as Encode exposing (Value)
import Time
import UUID exposing (Seeds, UUID)


type alias Identification =
    { email : String }


type Id
    = Anon UUID
    | Identified UUID Identification


type alias Event =
    { name : String
    , properties : List Property
    , id : Id
    }


type alias Property =
    ( String, Value )


type Client
    = Client { token : String }


type Mixpanel
    = Mixpanel State


type alias State =
    { queue : List Event
    , client : Maybe Client
    , seeds : Seeds
    , id : Id
    }


init :
    (UUID -> List effect)
    ->
        { token : Maybe String
        , seeds : Seeds
        , id : Maybe UUID
        }
    -> ( Mixpanel, List effect )
init toEffect config =
    let
        ( id, seeds ) =
            case config.id of
                Just uuid ->
                    ( uuid, config.seeds )

                Nothing ->
                    UUID.step config.seeds

        client =
            Maybe.map (\token -> Client { token = token }) config.token
    in
    ( Mixpanel
        { queue = []
        , client = client
        , seeds = seeds
        , id = Anon id
        }
    , toEffect id
    )


reset :
    (UUID -> List effect)
    -> Mixpanel
    -> ( Mixpanel, List effect )
reset toEffect (Mixpanel state) =
    let
        ( id, seeds ) =
            UUID.step state.seeds
    in
    ( Mixpanel
        { queue = []
        , client = state.client
        , seeds = seeds
        , id = Anon id
        }
    , toEffect id
    )


enqueue : (Id -> Event) -> Mixpanel -> Mixpanel
enqueue event (Mixpanel ({ queue } as state)) =
    Mixpanel { state | queue = event state.id :: queue }


dispatch :
    (List Event -> Client -> List effect)
    -> Mixpanel
    -> ( Mixpanel, List effect )
dispatch toEffects (Mixpanel state) =
    if List.length state.queue /= 0 then
        ( Mixpanel { state | queue = [] }
        , case state.client of
            Just client ->
                toEffects state.queue client

            Nothing ->
                []
        )

    else
        ( Mixpanel state, [] )


performDispatch : Expect msg -> List Event -> Client -> Cmd msg
performDispatch expect events client =
    if events /= [] then
        Http.post
            { url = "https://api.mixpanel.com/track#past-events-batch"
            , body =
                events
                    |> Encode.list (encodeEvent client)
                    |> Encode.encode 0
                    |> (++) "data="
                    |> Http.stringBody contentType
            , expect = expect
            }

    else
        Cmd.none


clientToProperty : Client -> ( String, Value )
clientToProperty (Client { token }) =
    ( "token", Encode.string token )


encodeEvent : Client -> Event -> Value
encodeEvent client { id, name, properties } =
    let
        clientProps =
            clientToProperty client

        identityProps =
            ( "distinct_id"
            , case id of
                Anon uuid ->
                    UUID.toValue uuid

                Identified _ { email } ->
                    Encode.string email
            )

        props =
            clientProps :: identityProps :: properties
    in
    Encode.object
        [ ( "event", Encode.string name )
        , ( "properties", Encode.object props )
        ]


identify :
    (Id -> Client -> List effect)
    -> String
    -> Mixpanel
    -> ( Mixpanel, List effect )
identify toEffects email (Mixpanel state) =
    let
        userData =
            { email = email }

        id =
            Identified (getAnonId state.id) userData
    in
    ( Mixpanel { state | id = id }
    , case state.client of
        Just client ->
            toEffects id client

        Nothing ->
            []
    )


performIdentify : Expect msg -> Id -> Client -> Cmd msg
performIdentify expect id client =
    case id of
        Anon _ ->
            Cmd.none

        Identified anonId identification ->
            Http.post
                { url = "https://api.mixpanel.com/track#create-identity"
                , body =
                    identification
                        |> encodeIdentification client anonId
                        |> Encode.encode 0
                        |> (++) "data="
                        |> Http.stringBody contentType
                , expect = expect
                }


encodeIdentification : Client -> UUID -> Identification -> Value
encodeIdentification client anonId { email } =
    let
        props =
            Encode.object
                [ clientToProperty client
                , ( "$identified_id", Encode.string email )
                , ( "$anon_id", UUID.toValue anonId )
                ]
    in
    Encode.object
        [ ( "event", Encode.string "$identify" )
        , ( "properties", props )
        ]


getAnonId : Id -> UUID
getAnonId id =
    case id of
        Anon anonId ->
            anonId

        Identified anonId _ ->
            anonId


contentType : String
contentType =
    "application/x-www-form-urlencoded"


dispatchInterval : msg -> Sub msg
dispatchInterval =
    always >> Time.every 2000
