# module Bukdu

function plug(modul::Module, args...; kw...)
    plug(Val{Base.module_name(modul)}, args...; kw...)
end


module Plug

import ..plug

include("plug/logger.jl")
include("plug/static.jl")
include("plug/upload.jl")
include("plug/session.jl")
include("plug/router.jl")
include("plug/csrf_protection.jl")
include("plug/oauth2.jl")

end # module Bukdu.Plug
