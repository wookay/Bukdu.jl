module test_octo_schema

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
importall .Octo.Schema
import .Octo.Database: Adapter
import Base.Test: @test, @test_throws

Database.setup(Adapter.MySQL) do adapter
end

type User
    id::PrimaryKey
    name::String
    age::Int
end

type Comment
    id::PrimaryKey
    text::String
end

schema(User) do user
    has_many(user, :comments, Comment)
end

u = in(User)
@test "SELECT * FROM users AS u WHERE 20 = u.age" == Query.statement(from(select= *, where= u.age == 20))


schema(User) do user
    field(user, :age, column_name=:User_Age)
    has_many(user, :comments, Comment)
end

u = in(User)
#@test "SELECT * FROM users AS u WHERE 20 = u.User_Age" == Query.statement(from(select= *, where= u.age == 20))
#@test "SELECT ? FROM users AS u WHERE ? = u.User_Age" == Query.statement(from(select= ?, where= u.age == ?))

Database.reset()

end # module test_octo_schema
