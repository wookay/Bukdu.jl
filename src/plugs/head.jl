# module Bukdu.Plug

struct Head <: AbstractPlug
end

function plug(::Type{Head})
    push!(bukdu_env[:prequisite_plugs], function (conn::Conn)
        if conn.request.method == "HEAD"
            conn.method = "GET"
        end
    end)
end

# module Bukdu.Plug
