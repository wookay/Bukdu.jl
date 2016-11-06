# module Bukdu.Octo

module Migration

import ..Query
import .Query: SubQuery, InsertQuery, UpdateQuery, DeleteQuery, desc
import ..Schema
import .Schema: Table, ColumnPhrase, ComponentQuery, add, drop
import ..Adapter
import ..SQL
import ..Logger

include("migration/schema_migration.jl")

typealias MigrationQuery Union{ComponentQuery,
                               SubQuery,
                               InsertQuery,
                               UpdateQuery,
                               DeleteQuery}

type MigrationSet
    version::VersionNumber
    up::Vector{MigrationQuery}
    down::Vector{MigrationQuery}
end

type MigrationItem
    op::Function
    query::MigrationQuery
end

immutable MigrationError
    message::String
end

function Base.:(+)(com::MigrationQuery)
    task = current_task()
    push!(task.storage[:migration], MigrationItem(+, com))
end

function Base.:(-)(com::MigrationQuery)
    task = current_task()
    push!(task.storage[:migration], MigrationItem(-, com))
end

function Base.:(~)(com::MigrationQuery)
    task = current_task()
    push!(task.storage[:migration], MigrationItem(~, com))
end

function migrate(adapter::Adapter.AdapterBase, version::VersionNumber)
     #drop_query = Schema.drop(:table, "schema_migrations")
     #Logger.info("dr", Query.statement(adapter, drop_query))
     #SQL.execute(adapter, drop_query)

     #SQL.all(adapter, "SHOW TABLES LIKE 'schema_migrations'")

     create_if_query = Schema.create_if_not_exists(:table, "schema_migrations") do t
         add(t, :id, PrimaryKey{Int})
         add(t, :version, String)
         add(t, :inserted_at, DateTime)
     end
     #Logger.info("cr", Query.statement(adapter, create_if_query))
     SQL.execute(adapter, create_if_query)
     sm = in(Migration.SchemaMigration)
     ver = string(version)
     r = SQL.all(adapter, Query.from(where= sm.version == ver, limit= 1, order_by= desc(sm.id)))
     #v"1.2".major * 10^12 + v"1.2".minor * 10^6 + v"1.2".patch
     insert_query = Query.insert(Migration.SchemaMigration, version = ver)
     SQL.execute(adapter, Query.statement(adapter, insert_query))
end


function migration_revert_query(com::ComponentQuery)::ComponentQuery # MigrationError
    action = Base.function_name(com.action)
    if action in [:create, :create_if_not_exists]
        ComponentQuery(drop, com.kind, com.table_name, com.table, com.options)
    else
        throw(MigrationError(""))
    end
end

function migration_revert_query(::MigrationQuery)::MigrationQuery # MigrationError
    throw(MigrationError(""))
end

end # module Bukdu.Octo.Migration

import .Migration: migrate
