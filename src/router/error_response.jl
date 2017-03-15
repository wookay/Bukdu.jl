# module Bukdu

struct ErrorLayout <: ApplicationLayout
end

function layout(::ErrorLayout, body, status, stacks)::String
    """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Bukdu 🌌 | $status</title>
    <style>
        body {background-color: #FFF8AC;}
    </style>
</head>
<body>
$body

<pre>
$stacks
</pre>
</body>
</html>"""
end

function conn_error_response(code::Int, verb::Symbol, path::String, ex, stackframes::Vector{StackFrame})::Conn
    with_color(sym, text) = "<strong>$text</strong>"
    stacks = Logger.inner_stackframes(stackframes, with_color)
    status = uppercase(string(first(keys(filter((k,v)->v==code, statuses)))))
    conn = render(Markdown/ErrorLayout, """
### 🌌  $(uppercase(string(verb))) $path

## $status | $code
### $ex
""", status, stacks)
    put_status(conn, code)
    conn
end

function conn_error_response(status::Symbol, verb::Symbol, path::String, ex, stackframes::Vector{StackFrame})
    code = statuses[status]
    conn_error_response(code, verb, path, ex, stackframes)
end

function conn_bad_request(verb::Symbol, path::String, ex, stackframes::Vector{StackFrame})::Conn
    conn_error_response(:bad_request, verb, path, ex, stackframes) # 400
end

function conn_application_error{AE<:ApplicationError}(verb::Symbol, path::String, ex::AE, stackframes::Vector{StackFrame})::Conn
    conn_error_response(ex.conn.status, verb, path, ex, stackframes)
end

function conn_not_found(verb::Symbol, path::String, ex, stackframes::Vector{StackFrame})::Conn
    conn_error_response(:not_found, verb, path, ex, stackframes) # 404
end

function conn_internal_server_error(verb::Symbol, path::String, ex, stackframes::Vector{StackFrame})::Conn
    conn_error_response(:internal_server_error, verb, path, ex, stackframes) # 500
end
