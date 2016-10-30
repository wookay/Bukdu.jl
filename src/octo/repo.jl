# module Bukdu.Octo

import ..Bukdu

module Repo

export NoAdapterError

import ..Bukdu: Logger
import ..Assoc
import ..typed_assoc
import ..Database
import ..Database: Adapter, NoAdapterError
import Base: ==

function set_adapter(T::Type)
    Database.set_adapter(T)
end

function Base.get(T::Type, id::Int) # throw NoAdapterError
    adapter = Database.get_adapter()
    get(adapter, T, id)
end

function insert(T::Type; kw...) # throw NoAdapterError
    adapter = Database.get_adapter()
    insert(adapter, T; kw...)
end

end # module Bukdu.Octo.Repo
