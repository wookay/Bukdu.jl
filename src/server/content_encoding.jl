# module Bukdu.Server

import Libz: inflate, deflate

function req_data_by_content_encoding(req::Request)::Vector{UInt8}
    if haskey(req.headers, "Content-Encoding")
        content_encodings = split(req.headers["Content-Encoding"], ", ")
        "gzip" in content_encodings && return inflate(req.data)
    end
    return req.data
end

function res_data_by_accept_encoding!(res::Response, headers::Headers, res_data::Vector{UInt8})::Void
    if haskey(headers, "Accept-Encoding")
        accept_encodings = split(headers["Accept-Encoding"], ", ")
        if "gzip" in accept_encodings
            res.headers["Content-Encoding"] = "gzip"
            res.data = deflate(res_data)
            return nothing
        end
    end
    res.data = res_data
    return nothing
end
