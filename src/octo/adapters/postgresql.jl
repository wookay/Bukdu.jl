# module Bukdu.Octo.Database.Adapter

import Bukdu.Octo: Logger

module LoadPostgreSQL

import ..Database
import ..Adapter
import ..Logger

# Logger.info("LoadPostgreSQL")

module Mock
module PostgreSQL
PGRES_TUPLES_OK = 2
type Postgres
end
connect(::Type{Postgres}, h, u, p, db) = nothing
disconnect(h) = nothing
prepare(h, s) = nothing
execute(s) = nothing
finish(s) = nothing
fetchall(r) = []
errcode(r) = PGRES_TUPLES_OK
end # LoadPostgreSQL.Mock.PostgreSQL
end # LoadPostgreSQL.Mock

const adapter_name = "PostgreSQL"
try
    Pkg.installed(adapter_name)
    import PostgreSQL
catch
    if Database.settings[:automatically_install_packages]
        Logger.info("Installing $adapter_name...")
        Pkg.add(adapter_name)
        import PostgreSQL
    else
        Logger.warn(string("Please install $adapter_name with ", Logger.with_color(:bold, """Pkg.add("$adapter_name")""")))
        import .Mock: PostgreSQL
    end
end

import .PostgreSQL: Postgres
function Adapter.connect(adapter::Adapter.PostgreSQL; kw...)
    info = Dict(kw)
    (host, user, pass, db) = map(x->info[x], (:host, :user, :pass, :db))
    adapter.handle = PostgreSQL.connect(Postgres, host, user, pass, db)
end

function Adapter.disconnect(adapter::Adapter.PostgreSQL)
    PostgreSQL.disconnect(adapter.handle)
end

function Adapter.all(adapter::Adapter.PostgreSQL, statement::String)::Base.Generator
    stmt = PostgreSQL.prepare(adapter.handle, statement)
    result = PostgreSQL.execute(stmt)
    PostgreSQL.errcode(result) == PostgreSQL.PGRES_TUPLES_OK # throw
    Logger.debug("all    ", statement, " |", Logger.with_color(:bold, length(result)))
    rows = PostgreSQL.fetchall(result)
    PostgreSQL.finish(stmt)
    Base.Generator(identity, rows)
end

function Adapter.execute(adapter::Adapter.PostgreSQL, statement::String)::Bool
    stmt = PostgreSQL.prepare(adapter.handle, statement)
    result = PostgreSQL.execute(stmt)
    Logger.debug("execute", statement)
    PostgreSQL.finish(stmt)
    PostgreSQL.errcode(result) == PostgreSQL.PGRES_TUPLES_OK
end

end # Bukdu.Octo.Database.Adapter.LoadMySQL
