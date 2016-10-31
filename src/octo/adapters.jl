# module Bukdu.Octo.Database

module Adapter

abstract DatabaseAdapter

# Adapter.MySQL
type MySQL <: DatabaseAdapter
    handle
    MySQL() = new(nothing)
end

function connect
end

function disconnect
end

# Adapter.SQLite
type SQLite <: DatabaseAdapter
    db
    SQLite() = new(nothing)
end

function open
end

function close
end


typealias AdapterBase Union{Adapter.MySQL, Adapter.SQLite}


function execute
end

function all
end

type NoAdapter <: DatabaseAdapter
end

type NoAdapterError
    message::String
end

end # Bukdu.Octo.Database.Adapter
