# module Bukdu.Octo

module SQL

import ..Database
import .Database: Adapter
import .Adapter: AdapterBase
import ..Query
import ..Query: SubQuery, InsertQuery, UpdateQuery, DeleteQuery
import ..Logger

function all(adapter::AdapterBase, statement::String)::Base.Generator
    Adapter.all(adapter, statement)
end

function execute(adapter::AdapterBase, statement::String)::Bool
    Adapter.execute(adapter, statement)
end

function all(adapter::AdapterBase, sub::SubQuery)::Base.Generator
    all(adapter, Query.statement(sub))
end

function insert(adapter::AdapterBase, ins::InsertQuery)::Bool
    execute(adapter, Query.statement(ins))
end

function update(adapter::AdapterBase, up::UpdateQuery)::Bool
    execute(adapter, Query.statement(up))
end

function delete(adapter::AdapterBase, del::DeleteQuery)::Bool
    execute(adapter, Query.statement(del))
end

end # module Bukdu.Octo.SQL
