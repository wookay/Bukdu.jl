# module Bukdu.Plug

module CSRF # Bukdu.Plug

using ..Plug: AbstractPlug

struct Protection <: AbstractPlug
end

end # module Bukdu.Plug.CSRF


function plug(::Type{CSRF.Protection}, conn::Conn)
    # TODO
    @error CSRF.Protection string(@__FILE__(), " #", @__LINE__())
    conn.request.response.status = 403 # 403 Forbidden
    conn.halted = true
end

# module Bukdu.Plug
