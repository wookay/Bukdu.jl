module test_octo_schema

import Bukdu: Logger
importall Bukdu.Octo
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

in(User) do user
    has_many(user, :comments, Vector{Comment})
end

u = in(User)
@test "SELECT * FROM users AS u WHERE 20 = u.age" == Query.statement(from(select= *, where= u.age == 20))

u = in(User) do user
    add(user, :age, Int, column_name = :User_Age)
    has_many(user, :comments, Vector{Comment})
end

c = in(Comment) do comment
    belongs_to(comment, :user, User)
end

@test "SELECT * FROM users AS u WHERE 20 = u.User_Age" == Query.statement(from(select= *, where= u.age == 20))
@test "SELECT ? FROM users AS u WHERE ? = u.User_Age" == Query.statement(from(select= ?, where= u.age == ?))
@test "SELECT c.text FROM comments AS c, users AS u WHERE 20 = u.User_Age AND c.user_id = u.id" == Query.statement(from(select= c.text, where= and(u.age == 20, c.user_id == u.id)))

Database.reset()

end # module test_octo_schema
