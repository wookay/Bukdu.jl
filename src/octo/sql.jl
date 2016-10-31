# module Bukdu.Octo

module SQL

import ..Database
import ..Query
import ..Query: SubQuery, InsertQuery, UpdateQuery, DeleteQuery
import ..Logger
import Base: all

function execute(statement::String)::Bool
    adapter = Database.get_adapter()
    execute(adapter, statement)
end

function all(sub::SubQuery)::Base.Generator
    adapter = Database.get_adapter()
    all(adapter, Query.statement(sub))
end

function insert(ins::InsertQuery)::Bool
    execute(Query.statement(ins))
end

function update(up::UpdateQuery)::Bool
    execute(Query.statement(up))
end

function delete(del::DeleteQuery)::Bool
    execute(Query.statement(del))
end

end # module Bukdu.Octo.SQL
