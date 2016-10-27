module test_octo_query

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
import .Octo.Database: Adapter, NotImplementedError
import Base.Test: @test, @test_throws

type User
    id::PrimaryKey
    name::String
    age::Int
end

type Comment
    id::PrimaryKey
    body::String
end

u = in(User)
@test isa(u, Query.A.User)
@test isa(u.id, Field)
@test isa(u.age, Field)
@test isa(u.name, Field)

subquery = from(User, id=1)
@test isa(subquery, SubQuery)

subquery = from(select= *, where= u.age > 20)
@test isa(subquery, SubQuery)

adapter = Adapter{Dict}
@test_throws NotImplementedError Query.statement(adapter, subquery)

Database.enable(Adapter{Dict})
@test "select * from users as u where 20 < u.age" == Query.statement(adapter, subquery)

schema(User) do user
    has_many(user, :comments, Comment)
end

c = in(Comment)
@test isa(c, Query.A.Comment)
@test isa(c.user_id, Field)

query = from(where= c.user_id in [1,2], select= c.body)
@test isa(query, SubQuery)

Database.reset(Adapter{Dict})

end # module test_octo_query
