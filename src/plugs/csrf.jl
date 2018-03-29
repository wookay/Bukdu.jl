# module Bukdu.Plug

struct CSRF <: AbstractPlug
end

function plug(::Type{CSRF}, conn::Conn)
    # TODO
    @error CSRF @__FILE__
    conn.request.response.status = 403 # 403 Forbidden
    conn.halted = true
end

# module Bukdu.Plug
