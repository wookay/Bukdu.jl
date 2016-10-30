module test_octo_adapters_mysql

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
import .Octo.Database: Adapter, disconnect
import Base.Test: @test, @test_throws

adapter = Database.setup(Adapter.MySQL) do adapter
    connect(adapter, host="127.0.0.1", user="root", pass="", db="")
end

# @test !isa(adapter.handle, Void)

function init_test()
    SQL.execute("DROP DATABASE IF EXISTS mysqltest;")
    SQL.execute("GRANT USAGE ON *.* TO 'test'@'127.0.0.1';")
    SQL.execute("DROP USER 'test'@'127.0.0.1';")
end

function create_test_database()
    SQL.execute("CREATE DATABASE mysqltest;")
    SQL.execute("CREATE USER test@127.0.0.1 IDENTIFIED BY 'test';")
    SQL.execute("GRANT ALL ON mysqltest.* TO test@127.0.0.1;")
end

init_test()
create_test_database()
disconnect(adapter)

connect(adapter, host="127.0.0.1", user="test", pass="test", db="mysqltest")

SQL.execute("""CREATE TABLE Employee
                 (
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

SQL.execute("""INSERT INTO Employee (Name, Salary, JoinDate, LastLogin, LunchTime, OfficeNo, JobType, Senior, empno)
                 VALUES
                 ('John', 10000.50, '2015-8-3', '2015-9-5 12:31:30', '12:00:00', 1, 'HR', b'1', 1301),
                 ('Tom', 20000.25, '2015-8-4', '2015-10-12 13:12:14', '13:00:00', 12, 'HR', b'1', 1422),
                 ('Jim', 30000.00, '2015-6-2', '2015-9-5 10:05:10', '12:30:00', 45, 'Management', b'0', 1567),
                 ('Tim', 15000.50, '2015-7-25', '2015-10-10 12:12:25', '12:30:00', 56, 'Accounts', b'1', 3200);
              """)
SQL.all("show tables from mysqltest")

type Employee
    name
end
Schema.table_name(::Type{Employee}) = "Employee"

e = in(Employee)
SQL.all(from(select= e.name))
SQL.all(from(select= *, where= "John" == e.name))

disconnect(adapter)
Database.reset()

end # module test_octo_adapters_mysql
