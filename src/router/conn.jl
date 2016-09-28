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


function conn_error_response(code::Int, verb, path::String, ex, stackframes::Vector{StackFrame})
    with_color(sym, text) = "<strong>$text</strong>"

    Conn(code, Dict("Content-Type"=>"text/html"), string(
        "<h3>",
        uppercase(string(Base.function_name(verb))),
        ' ',
        path,
        "</h3>",
        "<h3>$code $ex</h3>",
        "<pre>",
        Logger.inner_stackframes(stackframes, with_color),
        "</pre>"))
end

function conn_no_content()
    Conn(204, Dict{String,String}(), nothing)
end

function conn_server_error(verb, path::String, ex, stackframes::Vector{StackFrame})
    conn_error_response(404, verb, path, ex, stackframes)
end

function conn_bad_request(verb, path::String, ex, stackframes::Vector{StackFrame})
    conn_error_response(400, verb, path, ex, stackframes)
end
