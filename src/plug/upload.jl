# module Bukdu.Plug

immutable Upload
    filename::String
    content_type::String
    data::Vector{UInt8}

    Upload() = new("", "application/octet-stream", Vector{UInt8}())
    Upload(filename::String, content_type::String, data::Vector{UInt8}) = new(filename, content_type, data)
end

import Base: ==
==(lhs::Upload, rhs::Upload) =
    ==(lhs.filename, rhs.filename) &&
    ==(lhs.content_type, rhs.content_type) &&
    ==(lhs.data, rhs.data)

default(T::Type, ::Type{Upload}) = Upload()

function Base.show(stream::IO, mime::MIME"text/html", upload::Plug.Upload)
    len = length(upload.data)
    (bytes, mb) = Base.prettyprint_getunits(len, length(Base._mem_units), Int64(1000))
    suffix = (1 == mb) ? "s" : ""
    write(stream, string(round(bytes, 1), ' ', Base._mem_units[mb], suffix, " - "))
    if len > 6
        write(stream, string(eltype(upload.data), "[",
            join(map(repr, upload.data[1:3]), ", "), ", ... ",
            join(map(repr, upload.data[end-2:end]), ", "), "]"))
    else
        write(stream, repr(upload.data))
    end
end

function Base.show(stream::IO, mime::MIME"text/html", tup::Tuple{Symbol,Plug.Upload})
    for x in tup
        if isa(x, Plug.Upload)
            show(stream, mime, x)
        else
            write(stream, String(x))
        end
    end
end
