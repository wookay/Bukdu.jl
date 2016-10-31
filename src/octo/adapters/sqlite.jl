# module Bukdu.Octo.Database.Adapter

import Bukdu.Octo: Logger

module LoadSQLite

import ..Octo: normalize, table_as_clause
import ..Database
import ..Adapter
import ..Query: From, Field
import ..Logger

# Logger.info("LoadSQLite")

module Mock
module SQLite
module Data
type Sink
end
end
Base.size(::Data.Sink) = (0,0)
type DB
    file
    handle
    DB(file) = new(file, nothing)
end
function query(db, s)
    Data.Sink()
end
end # LoadSQLite.Mock.SQLite
end # LoadSQLite.Mock

const adapter_name = "SQLite"
try
    Pkg.installed(adapter_name)
    import SQLite
catch
    if Database.settings[:automatically_install_packages]
        Logger.info("Installing $adapter_name...")
        Pkg.add(adapter_name)
        import SQLite
    else
        Logger.warn(string("Please install $adapter_name with ", Logger.with_color(:bold, """Pkg.add("$adapter_name")""")))
        import .Mock: SQLite
    end
end

function Adapter.open(adapter::Adapter.SQLite; kw...)
    info = Dict(kw)
    file = info[:file]
    adapter.db = SQLite.DB(file)
end

function Adapter.close(adapter::Adapter.SQLite; kw...)
    adapter.db = nothing
end

function Adapter.all(adapter::Adapter.SQLite, statement::String)::Base.Generator
    r = SQLite.query(adapter.db, statement)
    (rows, columns) = size(r)
    Logger.debug("all    ", statement, " |", Logger.with_color(:bold, rows))
    function f(i)
        map(col->getindex(getindex(r[i,:], col)), 1:columns)
    end
    Base.Generator(identity, collect(Base.Generator(f, 1:rows)))
end

function Adapter.execute(adapter::Adapter.SQLite, statement::String)::Bool
    Logger.debug("execute", statement)
    result = SQLite.query(adapter.db, statement)
    true
end

end # Bukdu.Octo.Database.Adapter.LoadSQLite
