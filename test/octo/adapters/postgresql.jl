module test_octo_adapters_postgresql

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
import .Octo.Database: Adapter
import Base.Test: @test, @test_throws

# Logger.set_level(:debug)

adapter = Database.setup(Adapter.PostgreSQL) do adapter
    Adapter.connect(adapter, host="localhost", user="postgres", pass="postgres", db="")
end

# @test !isa(adapter.handle, Void)

function init_test()
    SQL.execute(adapter, "DROP DATABASE IF EXISTS julia_test;")
end

function create_test_database()
    SQL.execute(adapter, "CREATE DATABASE julia_test;")
end

init_test()
create_test_database()
Adapter.disconnect(adapter)

Adapter.connect(adapter, host="localhost", user="postgres", pass="postgres", db="julia_test")

SQL.execute(adapter, """CREATE TABLE Employee (
                     "ID" SERIAL,
                     Name VARCHAR(255),
                     Salary FLOAT(7),
                     LunchTime TIME,
                     PRIMARY KEY ("ID")
                 );""")

SQL.execute(adapter, """INSERT INTO Employee (Name, Salary, LunchTime)
                 VALUES
                 ('John', 10000.50, '12:00:00'),
                 ('Tom',  20000.25, '13:00:00'),
                 ('Jim',  30000.00, '12:30:00')
              ;""")

type Employee
    name
    salary
end
Schema.table_name(::Type{Employee}) = "Employee"

e = in(Employee)
@test isa(e, Query.A.Employee)

if !isa(adapter.handle, Void)
    r = SQL.all(adapter, """SELECT table_schema || '.' || table_name
                            FROM information_schema.tables
                            WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema')
                           ;""")
    @test [["public.employee"]] == collect(r)

    r = SQL.all(adapter, from(select= e.name))
    @test isa(r, Base.Generator)
    @test 3 == length(r)

    r = SQL.all(adapter, from(select= (e.name, e.salary), where= "John" == e.name))
    @test 1 == length(r)

    Adapter.disconnect(adapter)
end

Database.reset()

end # module test_octo_adapters_postgresql
