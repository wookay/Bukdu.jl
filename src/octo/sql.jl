# module Bukdu.Octo

module SQL

import ..Database
import ..Query
import ..Query: SubQuery
import Base: all

function execute(statement::String)
    adapter = Database.get_adapter()
    execute(adapter, statement)
end

function all(statement::String)
    adapter = Database.get_adapter()
    all(adapter, statement)
end

function all(sub::SubQuery)
    adapter = Database.get_adapter()
    all(adapter, Query.statement(sub))
end

function execute(sub::SubQuery)
end

end # module Bukdu.Octo.SQL
