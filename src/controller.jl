# module Bukdu

function Base.getproperty(c::C, prop::Symbol) where {C <: ApplicationController}
    if prop in (:params, :query_params, :path_params, :body_params)
        getfield(c.conn, prop)
    else
        getfield(c, prop)
    end
end


"""
    redirect_to(conn::Conn, path::String)
"""
function redirect_to(conn::Conn, path::String)
    body = """<html><body>Redirecting to <a href="$path">$path</a>.</body></html>"""
    conn.request.response.status = 302 # 302 Found
    push!(conn.request.response.headers, Pair("Location", path))
    render(HTML, body)
end

# module Bukdu
