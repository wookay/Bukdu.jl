# parent module Bukdu

function plug
end


module Plug

import ..Bukdu: ApplicationRouter, plug

include("plug/static.jl")

end # module Plug
