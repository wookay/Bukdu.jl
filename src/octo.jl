# module Bukdu

module Octo

include("octo/assoc.jl")
include("octo/changeset.jl")
include("octo/natural.jl")

end # module Bukdu.Octo


import .Octo: Assoc, FormFile

function validates(model, params)
    throw(MethodError("Please define the `function validates(model::$(typeof(model)), params)`"))
end
