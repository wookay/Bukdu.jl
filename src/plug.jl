# module Bukdu

function plug(func::Function, arg::Any)
    func(arg)
end

function plug(modul::Module, args...; kw...)
    plug(Val{Base.module_name(modul)}, args...; kw...)
end

module Plug

import ..plug

include("plug/router.jl")
include("plug/static.jl")
include("plug/logger.jl")
include("plug/oauth2.jl")

end # module Bukdu.Plug
