# module Bukdu.Plug

import ..Conn

immutable CSRFProtection
end

function plug(::Type{Plug.CSRFProtection}; kw...)
end

function protect_from_forgery(conn::Conn)
    plug(Plug.CSRFProtection)
end

function generate_token()::Base.Random.UUID
    Base.Random.uuid1()
end

function get_csrf_token(conn::Conn)
    if !haskey(conn.assigns, :csrf_token)
        conn.assigns[:csrf_token] = generate_token()
    end
    conn.assigns[:csrf_token]
end

function delete_csrf_token(conn::Conn)
    delete!(conn.assigns, :csrf_token)
end
