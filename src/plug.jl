# module Bukdu

function plug
end


module Plug

import ..plug

include("plug/router.jl")
include("plug/static.jl")

end # module Bukdu.Plug
