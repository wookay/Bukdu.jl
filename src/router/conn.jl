# module Bukdu

type Conn
    status::Int
    resp_header::Dict{String,String}
    resp_body::Any
    params::Dict{String,String}
    query_params::Dict{String,String}
    private::Dict{Symbol,String}
    assigns::Dict{Symbol,String}
end

const CONN_NOT_FOUND = Conn(404, Dict{String,String}(), "not found", Dict{String,String}(), Dict{String,String}(), Dict{Symbol,String}(), Dict{Symbol,String}())
