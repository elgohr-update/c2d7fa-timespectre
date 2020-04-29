module Timespectre.Data exposing
    ( Duration
    , Session
    , State
    , addSession
    , endSession
    , formatDuration
    , idGenerator
    , isActive
    , setNotes
    , tagLabel
    , until
    )

import Dict exposing (Dict)
import Random
import Time


type alias State =
    { sessions : List Session
    , tags : Dict String String
    }


type alias Duration =
    { ms : Int }


type alias Session =
    { id : String
    , start : Time.Posix
    , end : Maybe Time.Posix -- An active session has no end time yet
    , notes : String
    , tags : List String
    }


isActive : Session -> Bool
isActive session =
    case session.end of
        Just _ ->
            False

        Nothing ->
            True


addSession : String -> Time.Posix -> List Session -> List Session
addSession id start sessions =
    { id = id, start = start, end = Nothing, notes = "", tags = [] } :: sessions


endSession : Session -> Time.Posix -> List Session -> List Session
endSession session end =
    List.map
        (\s ->
            if s.id == session.id then
                { s | end = Just end }

            else
                s
        )


setNotes : Session -> String -> List Session -> List Session
setNotes session notes =
    List.map
        (\s ->
            if s.id == session.id then
                { s | notes = notes }

            else
                s
        )


idGenerator : Random.Generator String
idGenerator =
    Random.list 6 (Random.int (Char.toCode 'a') (Char.toCode 'z'))
        |> Random.map (List.map Char.fromCode)
        |> Random.map String.fromList


until : Time.Posix -> Time.Posix -> Duration
until t1 t2 =
    { ms = Time.posixToMillis t2 - Time.posixToMillis t1 }


durationMixed : Duration -> { hours : Int, minutes : Int, seconds : Int, ms : Int }
durationMixed { ms } =
    { hours = ms // (1000 * 60 * 60)
    , minutes = modBy 60 (ms // (1000 * 60))
    , seconds = modBy 60 (ms // 1000)
    , ms = modBy 1000 ms
    }


formatDuration : Duration -> String
formatDuration duration =
    let
        { hours, minutes, seconds, ms } =
            durationMixed duration
    in
    case ( hours, minutes, seconds ) of
        ( 0, 0, 0 ) ->
            String.fromInt ms ++ "ms"

        ( 0, 0, _ ) ->
            String.fromInt seconds ++ "s"

        ( 0, _, _ ) ->
            String.fromInt minutes ++ "m" ++ String.fromInt seconds ++ "s"

        ( _, _, _ ) ->
            String.fromInt hours ++ "h" ++ String.fromInt minutes ++ "m"


tagLabel : Dict String String -> String -> String
tagLabel tags tagId =
    Dict.get tagId tags |> Maybe.withDefault ("<" ++ tagId ++ ">")



-- tagLabels : Dict String String -> Session -> List String
-- tagLabels tags session =
--     List.map (tagLabel tags) session.tags
