# module Bukdu

function plug(func::Function, arg::Any)
    func(arg)
end


module Plug

import ..plug

include("plug/router.jl")
include("plug/static.jl")
include("plug/logger.jl")

function plug(modul::Module; kw...)
    plug(Val{Base.module_name(modul)}; kw...)
end

end # module Bukdu.Plug
