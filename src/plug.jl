# module Bukdu

function plug(func::Function, arg::Any)
    func(arg)
end


module Plug

import ..plug

include("plug/router.jl")
include("plug/static.jl")
include("plug/logger.jl")
include("plug/oauth2.jl")

function plug(modul::Module, args...; kw...)
    plug(Val{Base.module_name(modul)}, args...; kw...)
end

end # module Bukdu.Plug
