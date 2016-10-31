# module Bukdu.Octo.Database.Adapter

import Bukdu.Octo: Logger

module LoadMySQL

import ..Database
import ..Adapter
import ..Logger

# Logger.info("LoadMySQL")

module Mock
module MySQL
MYSQL_OPT_RECONNECT = UInt32(20)
function mysql_connect(h,u,p,d;kw...)
    nothing
end
function mysql_disconnect(h)
end
function mysql_query(h,s)
end
type MySQLRowIterator
    h
    s
    rowsleft
    MySQLRowIterator(h,s) = new(h,s,0)
end
Base.start(::MySQLRowIterator) = 1
Base.next(::MySQLRowIterator, ::Int) = false
Base.done(::MySQLRowIterator, ::Int) = true
end # LoadMySQL.Mock.MySQL
end # LoadMySQL.Mock

const adapter_name = "MySQL"
try
    Pkg.installed(adapter_name)
    import MySQL
catch
    if Database.settings[:automatically_install_packages]
        Logger.info("Installing $adapter_name...")
        Pkg.add(adapter_name)
        import MySQL
    else
        Logger.warn(string("Please install $adapter_name with ", Logger.with_color(:bold, """Pkg.add("$adapter_name")""")))
        import .Mock: MySQL
    end
end

function Adapter.connect(adapter::Adapter.MySQL; kw...)
    info = Dict(kw)
    (host, user, pass, db) = map(x->info[x], (:host, :user, :pass, :db))
    adapter.handle = MySQL.mysql_connect(host, user, pass, db; opts=Dict(MySQL.MYSQL_OPT_RECONNECT => 1))
end

function Adapter.disconnect(adapter::Adapter.MySQL)
    MySQL.mysql_disconnect(adapter.handle)
end

Base.length(itr::MySQL.MySQLRowIterator) = itr.rowsleft

function Adapter.all(adapter::Adapter.MySQL, statement::String)::Base.Generator
    itr = MySQL.MySQLRowIterator(adapter.handle, statement)
    Logger.debug("all    ", statement, " |", Logger.with_color(:bold, itr.rowsleft))
    Base.Generator(identity, collect(itr))
end

function Adapter.execute(adapter::Adapter.MySQL, statement::String)::Bool
    Logger.debug("execute", statement)
    result = MySQL.mysql_query(adapter.handle, statement)
    0 == result
end

end # Bukdu.Octo.Database.Adapter.LoadMySQL
