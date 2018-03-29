module CLI # Bukdu

import ..Bukdu: Routing, Naming

"""
    CLI.routes()
"""
function routes()
    A = Routing.context[:routing_tables]
    isempty(A) && return
    ncols = 5
    nrows = Int(length(A)/ncols)
    rt = reshape(A, ncols, nrows)
    paddings = maximum((length ∘ string).(rt), dims=2) .+ 2
    function f(idx, el)
        if idx == ncols # pipe
            el
        else
            rpad(el, paddings[idx])
        end
    end
    for rowidx in 1:nrows
        row = rt[:, rowidx]
        print.([f(idx, el) for (idx, el) in enumerate(row)])
        println()
    end
end

end # module Bukdu.CLI
