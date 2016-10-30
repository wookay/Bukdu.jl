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
        true
    end
    function mysql_query(h,s)
    end
    function mysql_disconnect(h)
    end
    function MySQLRowIterator(h, s)
        []
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

function all(adapter::Adapter.MySQL, statement::String)
    for row in MySQLRowIterator(adapter.handle, statement)
#        Logger.info(row)
    end
end

function execute(adapter::Adapter.MySQL, statement::String)
    result = mysql_query(adapter.handle, statement)
#    Logger.info(result)
end

end # Bukdu.Octo.Database.Adapter.LoadMySQL
