# module Bukdu.Plug

struct Head <: AbstractPlug
end

function plug(::Type{Head})
    bukdu_env[:prequisite_plugs]["Head"] = function (conn::Conn)
        if conn.request.method == "HEAD"
            conn.method = "GET"
        end
    end
end

# module Bukdu.Plug
