# module Bukdu.Octo.LoadAdapterBase

# InsertQuery
function statement(adapter::AdapterBase, ins::InsertQuery)::String
    names = enclosed(adapter, keys(ins.fields))
    vals = enclosed(adapter, normalize.(values(ins.fields)))
    string(uppercase("insert"), ' ', uppercase("into"), ' ', ins.table_name, ' ', names, ' ', uppercase("values"), ' ', vals)
end

# UpdateQuery
function statement(adapter::AdapterBase, up::UpdateQuery)::String
    table_as = table_as_clause(adapter, up.from)
    update = string(uppercase("update"), ' ', table_as, ' ', uppercase("set"))
    vals = join(map(up.fields) do field
        (name, value) = field
        string(name, "=", normalize(value))
    end, ", ")
    where = where_clause(adapter, up.from, up.where)
    clauses = Vector{String}()
    for clause in [update, vals, where]
        !isempty(clause) && push!(clauses, clause)
    end
    join(clauses, ' ')
end

# DeleteQuery
function statement(adapter::AdapterBase, del::DeleteQuery)::String
    delete = string(uppercase("delete"))
    table = string(uppercase("from"), ' ', join(del.table_name))
    if isempty(del.fields)
        where = ""
    else
        where = string(uppercase("where"), ' ', join(map(del.fields) do field
            (name, value) = field
            string(name, "=", normalize(value))
        end, ", "))
    end
    clauses = Vector{String}()
    for clause in [delete, table, where]
        !isempty(clause) && push!(clauses, clause)
    end
    join(clauses, ' ')
end
