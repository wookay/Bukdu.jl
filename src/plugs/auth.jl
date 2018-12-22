# module Bukdu.Plug

struct Auth <: AbstractPlug
end

function plug(::Type{Auth}, conn::Conn)
    # TODO
    @error Auth string(@__FILE__(), " #", @__LINE__())
    conn.request.response.status = 401 # 401 Unauthorized
    conn.halted = true
end

# module Bukdu.Plug
