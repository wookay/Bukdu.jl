# module Bukdu.Plug

struct Auth <: AbstractPlug
end

function plug(::Type{Auth}, conn::Conn)
    # TODO
    @error Auth @__FILE__
    conn.request.response.status = 401 # 401 Unauthorized
    conn.halted = true
end

# module Bukdu.Plug
