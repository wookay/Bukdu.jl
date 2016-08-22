type Conn
    status::Int
	resp_header::Dict{String,String}
    resp_body::String
    params::Dict{String,String}

    Conn(status::Int, resp_body::String) = new(status, Dict{String,String}(), resp_body, Dict{String,String}())
    Conn(status::Int, resp_body::String, params::Dict{String,String}) = new(status, Dict{String,String}(), resp_body, params)
    Conn(status::Int, resp_header::Dict{String,String}, resp_body::String, params::Dict{String,String}) = new(status, resp_header, resp_body, params)
end

const CONN_NOT_FOUND = Conn(404, "not found", Dict{String,String}())
