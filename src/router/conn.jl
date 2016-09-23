# module Bukdu

type Conn
    status::Int
    resp_header::Dict{String,String}
    resp_body::Any
    params::Assoc
    query_params::Assoc
    private::Dict{Symbol,String}
    assigns::Dict{Symbol,String}

    function Conn(status::Int, resp_header::Dict{String,String}, resp_body::Any)
        new(status, resp_header, resp_body, Assoc(), Assoc(), Dict{Symbol,String}(), Dict{Symbol,String}())
    end

    function Conn(status::Int, resp_header::Dict{String,String}, resp_body::Any, params::Assoc, query_params::Assoc, private::Dict{Symbol,String}, assigns::Dict{Symbol,String})
        new(status, resp_header, resp_body, params, query_params, private, assigns)
    end
end

const CONN_NOT_FOUND = Conn(404, Dict("Content-Type"=>"text/html"), "not found")
