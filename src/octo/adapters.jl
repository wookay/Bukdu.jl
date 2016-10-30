# module Bukdu.Octo.Database

module Adapter

abstract DatabaseAdapter

type MySQL <: DatabaseAdapter
    handle
    MySQL() = new(nothing)
end

typealias AdapterBase Union{Adapter.MySQL}


function connect
end

function disconnect
end

type NoAdapter <: DatabaseAdapter
end

type NoAdapterError
    message::String
end

end # Bukdu.Octo.Database.Adapter
