module CLI # Bukdu

using ..Bukdu.Routing
using ..Bukdu.Naming

"""
    CLI.routes(io::IO = stdout)

Showing the routing table.
"""
function routes(io::IO = stdout)
    A = Routing.store[:routing_tables]
    isempty(A) && return
    ncols = length(first(A)) # (verb, url, C, action, pipe)
    nrows = length(A)
    paddings = map(1:ncols) do col
        maximum([(length ∘ string)(row[col]) for row in A]) .+ 2
    end
    function f(idx, el, lastcolumn)
        if idx == lastcolumn
            el
        else
            rpad(el, paddings[idx])
        end
    end
    for row in A
        lastcolumn = isempty(row[ncols]) ? ncols-1 : ncols
        print.(Ref(io), [f(idx, el, lastcolumn) for (idx, el) in enumerate(row[1:lastcolumn])])
        println(io)
    end
end

end # module Bukdu.CLI
