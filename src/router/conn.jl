type Conn
    status::Int
	resp_header::Dict{String,String}
    resp_body::Any
    params::Dict{String,String}
    query_params::Dict{String,String}

    Conn(status::Int, resp_body::Any, params::Dict{String,String}, query_params::Dict{String,String}) = new(status, Dict{String,String}(), resp_body, params, query_params)
    Conn(status::Int, resp_header::Dict{String,String}, resp_body::Any, params::Dict{String,String}, query_params::Dict{String,String}) = new(status, resp_header, resp_body, params, query_params)
end

const CONN_NOT_FOUND = Conn(404, Dict{String,String}(), "not found", Dict{String,String}(), Dict{String,String}())
