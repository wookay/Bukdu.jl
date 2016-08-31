# module Bukdu

function plug(func::Function, arg::Any)
    func(arg)
end


module Plug

import ..plug

include("plug/router.jl")
include("plug/static.jl")
include("plug/logger.jl")

end # module Bukdu.Plug
