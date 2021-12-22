module Paack.Remote exposing (GraphqlHttpRecyclingStage, nestedMergeResponse)

import Graphql.Http as GraphqlHttp
import Paack.List as List
import Remote.Data as RemoteData exposing (RemoteData)
import Remote.Recyclable as Recyclable exposing (Recyclable)
import Remote.Response exposing (Response)
import UUID exposing (UUID)


type alias GraphqlHttpRecyclingStage customError =
    Recyclable.RecyclingStage (GraphqlHttp.RawError () GraphqlHttp.HttpError) customError


nestedMergeResponse :
    UUID
    -> Response transportError detailsError details
    -> RemoteData transportError listError (List { object | id : UUID, extra : { extra | details : Recyclable transportError detailsError details } })
    -> RemoteData transportError listError (List { object | id : UUID, extra : { extra | details : Recyclable transportError detailsError details } })
nestedMergeResponse id response data =
    let
        applyObject ({ extra } as object) =
            { object | extra = applyExtra extra }

        applyExtra extra =
            { extra | details = Recyclable.mergeResponse response extra.details }
    in
    RemoteData.map
        (List.updateById id applyObject)
        data
