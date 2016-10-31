module test_octo_adapters_sqlite

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
import .Octo.Database: Adapter
import Base.Test: @test, @test_throws

# Logger.set_level(:debug)

adapter = Database.setup(Adapter.SQLite) do adapter
    Adapter.open(adapter, file=":memory:")
end

# @test !isa(adapter.db.handle, Void)

SQL.execute(adapter, """CREATE TABLE Employee
                 (
                     ID INTEGER PRIMARY KEY AUTOINCREMENT,
                     Name VARCHAR(255),
                     Salary FLOAT(7,2),
                     JoinDate DATE,
                     LastLogin DATETIME,
                     LunchTime TIME,
                     OfficeNo TINYINT,
                     JobType TEXT CHECK( JobType IN ('HR','Management','Accounts') ),
                     Senior BOOLEAN,
                     empno SMALLINT
                 );""")

SQL.execute(adapter, """INSERT INTO Employee (Name, Salary, JoinDate, LastLogin, LunchTime, OfficeNo, JobType, Senior, empno)
                 VALUES
                 ('John', 10000.50, '2015-8-3', '2015-9-5 12:31:30', '12:00:00', 1, 'HR', '1', 1301),
                 ('Tom', 20000.25, '2015-8-4', '2015-10-12 13:12:14', '13:00:00', 12, 'HR', '1', 1422),
                 ('Jim', 30000.00, '2015-6-2', '2015-9-5 10:05:10', '12:30:00', 45, 'Management', '0', 1567)
              ;""")

type Employee
    name
end
Schema.table_name(::Type{Employee}) = "Employee"

e = in(Employee)
@test isa(e, Query.A.Employee)

type User
    id::PrimaryKey
    name::String
    age::Int
end

if !isa(adapter.db.handle, Void)
    r = SQL.all(adapter, from(select= e.name))
    @test isa(r, Base.Generator)
    @test 3 == length(r)

    r = SQL.all(adapter, from(select= *, where= "John" == e.name))
    @test 1 == length(r)

    SQL.execute(adapter, """CREATE TABLE users (
                         ID INTEGER PRIMARY KEY AUTOINCREMENT,
                         name VARCHAR(255),
                         age INT,
                         Salary FLOAT(7,2)
                     );""")

    @test "INSERT INTO users (name, age) VALUES ('foo bar', 20)" == Query.statement(Query.insert(User, name="foo bar", age=20))
    @test "INSERT INTO users (name, age) VALUES (?, ?)" == Query.statement(Query.insert(User, name=?, age=?))

    # insert
    SQL.insert(adapter, Query.insert(User, name="foo bar", age=20))
    Repo.insert(User, name="bar", age=20)

    hey = User(0, "hey", 30)
    Repo.insert(hey)

    r = SQL.all(adapter, from(User))
    @test 3 == length(r)

    user1 = Repo.get(User, 1)
    @test isa(user1, User)
    @test "foo bar" == user1.name

    user2 = Repo.get(User, 2)
    @test isa(user2, User)
    @test "bar" == user2.name

    user1000 = Repo.get(User, 1000)
    @test isa(user1000, Void)
    change1 = Changeset(user1, Assoc(name="change1"))
    Repo.update(change1)

    u = in(User)
    users = Repo.get(Vector{User}, where= u.age == 20)
    @test isa(users, Vector{User})
    @test 2 == length(users)

    users = Repo.get(Vector{User}, where= or(u.age == 20, u.name == "hey"))
    @test 3 == length(users)

    Repo.delete(User, 1)

    Adapter.close(adapter)
end

Database.reset()

end # module test_octo_adapters_sqlite
