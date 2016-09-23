# module Bukdu

module Octo

include("octo/changeset.jl")
include("octo/natural.jl")

end # module Bukdu.Octo

function validates(model, params)
    throw(MethodError("Please define the `function validates(model::$(typeof(model)), params)`"))
end
