module test_octo_adapters_mysql

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
import .Octo.Database: Adapter
import Base.Test: @test, @test_throws

# Logger.set_level(:debug)

adapter = Database.setup(Adapter.MySQL) do adapter
    Adapter.connect(adapter, host="127.0.0.1", user="root", pass="", db="")
end

# @test !isa(adapter.handle, Void)

function init_test()
    SQL.execute(adapter, "DROP DATABASE IF EXISTS mysqltest;")
    SQL.execute(adapter, "GRANT USAGE ON *.* TO 'test'@'127.0.0.1';")
    SQL.execute(adapter, "DROP USER 'test'@'127.0.0.1';")
end

function create_test_database()
    SQL.execute(adapter, "CREATE DATABASE mysqltest;")
    SQL.execute(adapter, "CREATE USER test@127.0.0.1 IDENTIFIED BY 'test';")
    SQL.execute(adapter, "GRANT ALL ON mysqltest.* TO test@127.0.0.1;")
end

init_test()
create_test_database()
Adapter.disconnect(adapter)

Adapter.connect(adapter, host="127.0.0.1", user="test", pass="test", db="mysqltest")

SQL.execute(adapter, """CREATE TABLE Employee (
                     ID INT NOT NULL AUTO_INCREMENT,
                     Name VARCHAR(255),
                     Salary FLOAT(7,2),
                     JoinDate DATE,
                     LastLogin DATETIME,
                     LunchTime TIME,
                     OfficeNo TINYINT,
                     JobType ENUM('HR', 'Management', 'Accounts'),
                     Senior BIT(1),
                     empno SMALLINT,
                     PRIMARY KEY (ID)
                 );""")

SQL.execute(adapter, """INSERT INTO Employee (Name, Salary, JoinDate, LastLogin, LunchTime, OfficeNo, JobType, Senior, empno)
                 VALUES
                 ('John', 10000.50, '2015-8-3', '2015-9-5 12:31:30', '12:00:00', 1, 'HR', b'1', 1301),
                 ('Tom', 20000.25, '2015-8-4', '2015-10-12 13:12:14', '13:00:00', 12, 'HR', b'1', 1422),
                 ('Jim', 30000.00, '2015-6-2', '2015-9-5 10:05:10', '12:30:00', 45, 'Management', b'0', 1567)
              ;""")

type Employee
    name
end
Schema.table_name(::Type{Employee}) = "Employee"

e = in(Employee)
@test isa(e, Query.A.Employee)

if !isa(adapter.handle, Void)

    r = SQL.all(adapter, "show tables from mysqltest")
    @test [("Employee",)] == collect(r)

    r = SQL.all(adapter, from(select= e.name))
    @test isa(r, Base.Generator)
    @test 3 == length(r)

    r = SQL.all(adapter, from(select= *, where= "John" == e.name))
    @test 1 == length(r)

    Adapter.disconnect(adapter)
end

Database.reset()

end # module test_octo_adapters_mysql
