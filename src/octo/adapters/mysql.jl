# module Bukdu.Octo.Database.Adapter

import Bukdu.Octo: Logger

module LoadMySQL

import ..Database
import ..Adapter
import .Adapter: disconnect
import ..SQL: execute
import ..Logger
import Base: connect, all

module Mock
    MYSQL_OPT_RECONNECT = UInt32(20)
    function mysql_connect(h,u,p,d;kw...)
        nothing
    end
    function mysql_disconnect(h)
    end
    function mysql_query(h,s)
    end
    type Itr
        rowsleft
    end
    function MySQLRowIterator(h, s)
        Itr(0)
    end
end

try
    Pkg.installed("MySQL")
    import MySQL: mysql_connect, mysql_disconnect, mysql_query, MySQLRowIterator, MYSQL_OPT_RECONNECT
catch
    if Database.settings[:automatically_install_packages]
        Logger.info("Installing MySQL...")
        Pkg.add("MySQL")
        import MySQL: mysql_connect, mysql_disconnect, mysql_query, MySQLRowIterator, MYSQL_OPT_RECONNECT
    else
        import .Mock: mysql_connect, mysql_disconnect, mysql_query, MySQLRowIterator, MYSQL_OPT_RECONNECT
    end
end

function connect(adapter::Adapter.MySQL; kw...)
    info = Dict(kw)
    (host, user, pass, db) = map(x->info[x], (:host, :user, :pass, :db))
    adapter.handle = mysql_connect(host, user, pass, db; opts=Dict(MYSQL_OPT_RECONNECT => 1))
end

function disconnect(adapter::Adapter.MySQL)
    mysql_disconnect(adapter.handle)
end

function all(adapter::Adapter.MySQL, statement::String)::Base.Generator
    itr = MySQLRowIterator(adapter.handle, statement)
    Logger.debug("all    ", statement, " |", Logger.with_color(:bold, itr.rowsleft))
    function f(i)
        Base.next(itr, true)
    end
    Base.Generator(f, 1:itr.rowsleft)
end

function execute(adapter::Adapter.MySQL, statement::String)::Bool
    result = mysql_query(adapter.handle, statement)
    Logger.debug("execute", statement)
    0 == result
end

end # Bukdu.Octo.Database.Adapter.LoadMySQL
