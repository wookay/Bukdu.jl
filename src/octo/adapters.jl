# module Bukdu.Octo.Database

module Adapter

abstract DatabaseAdapter

# Adapter.MySQL
type MySQL <: DatabaseAdapter
    handle
    MySQL() = new(nothing)
end

# Adapter.PostgreSQL
type PostgreSQL <: DatabaseAdapter
    handle
    PostgreSQL() = new(nothing)
end

# Adapter.SQLite
type SQLite <: DatabaseAdapter
    db
    SQLite() = new(nothing)
end

typealias AdapterBase Union{Adapter.MySQL, Adapter.PostgreSQL, Adapter.SQLite}


function execute
end

function all
end

function connect
end

function disconnect
end

function open
end

function close
end

type NoAdapter <: DatabaseAdapter
end

type NoAdapterError
    message::String
end

end # Bukdu.Octo.Database.Adapter
