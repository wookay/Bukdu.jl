# module Bukdu

import Base: getindex, get, edit, show

include("controller/conn.jl")

const HTTP_VERBS = [:get, :post, :delete, :patch, :put]

for verb in HTTP_VERBS
    @eval ($verb){AC<:ApplicationController}(path::String, ::Type{AC}, action::Function; kw...) =
        Routing.match($verb, path, AC, action, Dict(kw))
end

function getindex{AC<:ApplicationController}(C::AC, sym::Symbol) # throw ErrorException, KeyError
    task = current_task()
    if haskey(Routing.task_storage, task)
        conn = Routing.task_storage[task]
        return (:conn == sym) ? conn : getfield(conn, sym)
    else
        throw(ErrorException("no $task"))
    end
    throw(KeyError(sym))
end

# actions: index, (edit), new, (show),  create, update, delete
function index
end

function new
end

function create
end

function update
end

function delete
end


module Controller

import ..ApplicationError, ..Conn
import ..get_req_header

immutable NotAcceptableError <: ApplicationError
    conn::Conn
    message::String
end

function accepts(conn::Conn, accepted::Vector{String}) # throw NotAcceptableError
    if haskey(conn.query_params, :_format)
        if format in accepted
            put_format(conn, format)
        else
            put_status(conn, :not_acceptable) # 406
            throw(NotAcceptableError(conn, "unknown format $format, expected one of $accepted"))
        end
    else
        if haskey(conn.req_headers, "Accept")
            put_format(conn, get_req_header(conn, "Accept"))
        else
            put_format(conn, first(accepted))
        end
    end
end

function put_format(conn::Conn, format::String)
    conn.private[:format] = format
end

end # module Bukdu.Controller
