# module Bukdu

import Base: getindex, get, edit, show

include("controller/conn.jl")

const HTTP_VERBS = [:get, :post, :delete, :patch, :put]

for verb in HTTP_VERBS
    @eval ($verb){AC<:ApplicationController}(path::String, ::Type{AC}, action::Function; kw...) =
        Routing.match($verb, path, AC, action, Dict(kw))
end

function check_controller_has_field_conn{AC<:ApplicationController}(::AC) # throw MissingConnError
    if :conn in fieldnames(AC) && fieldtype(AC, :conn) == Conn
    else
        conn = Conn()
        put_status(conn, :internal_server_error)
        throw(MissingConnError(conn, "type $AC has no field conn::Conn"))
    end
end

function getindex{AC<:ApplicationController}(controller::AC, sym::Symbol) # throw MissingConnError, KeyError
    if :name == sym
        AC.name.name
    else
        fields = fieldnames(AC)
        check_controller_has_field_conn(controller) # throw MissingConnError
        if sym in fieldnames(Conn)
            getfield(controller.conn, sym)
        else
            throw(KeyError(sym))
        end
    end
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
