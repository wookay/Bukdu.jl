# module Bukdu.Octo

module SQL

import ..Database
import ..Query
import ..Query: SubQuery, InsertQuery
import ..Logger
import Base: all

function execute(statement::String)::Bool
    adapter = Database.get_adapter()
    execute(adapter, statement)
end

function execute(sub::SubQuery)::Bool
    execute(Query.statement(sub))
end

function all(statement::String)::Base.Generator
    adapter = Database.get_adapter()
    all(adapter, statement)
end

function all(sub::SubQuery)::Base.Generator
    all(Query.statement(sub))
end

function insert(ins::InsertQuery)::Bool
    execute(Query.statement(ins))
end

end # module Bukdu.Octo.SQL
