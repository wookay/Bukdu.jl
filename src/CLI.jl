module CLI # Bukdu

using ..Bukdu: Routing, Naming

"""
    CLI.routes()

Showing the routing table.
"""
function routes()
    A = Routing.store[:routing_tables]
    isempty(A) && return
    ncols = 5 # verb url C action pipe
    nrows = Int(length(A)/ncols)
    rt = reshape(A, ncols, nrows)
    paddings = maximum((length ∘ string).(rt), dims=2) .+ 2
    function f(idx, el, lastcolumn)
        if idx == lastcolumn
            el
        else
            rpad(el, paddings[idx])
        end
    end
    for rowidx in 1:nrows
        row = rt[:, rowidx]
        lastcolumn = isempty(row[ncols]) ? ncols-1 : ncols
        print.([f(idx, el, lastcolumn) for (idx, el) in enumerate(row[1:lastcolumn])])
        println()
    end
end

end # module Bukdu.CLI
