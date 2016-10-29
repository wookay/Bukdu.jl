# module Bukdu.Octo.Schema

abstract Migration

#=
type Table
end

type Index
end

type Reference
end

type Constraint
end

function create(::Table)
end

function create(::Index)
end

function create(::Reference)
end

function create(::Constraint)
end

function rename(::Table, column::Symbol, to::Symbol)
end

Table.create(Index
Table.create(Constraint
Table.create(Reference

Table.alter
Table.rename

Table.drop(Index
Table.drop(Constraint
Table.drop(Reference

function drop(::Table)
end

function drop(::Index)
end

function drop(::Reference)
end

function drop(::Constraint)
end

# Table block
function table(block::Function, table_name::Symbol)::Migrati
end

function add(table::Table, column::Symbol, typ::Type)
end

function remove(table::Table, column::Symbol)
end

type UpDownMigration <: Migration
end


module UpDownMigration
importall ..Octo.Migration
function change()
    create(Table(:posts)) do table
        add(table, :name, String)
    end:
    create(Index(:posts, [:title]))
end
end # module UpDownMigration

Repo.up(UpDownMigration)



  defmodule ChangeMigration do
    use Ecto.Migration

    def change do
      create table(:posts) do
        add :name, :string
      end

      create index(:posts, [:title])
    end
  end
end

end

=#
