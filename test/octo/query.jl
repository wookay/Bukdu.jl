module test_octo_query

importall Bukdu
importall Bukdu.Octo.Repo
importall Bukdu.Octo.Query
import Base.Test: @test, @test_throws

type User
    name::String
    age::Int
end

type Comment
    body::String
end

u = in(User)
@test isa(u, Query.models[User])
@test isa(u.id, Field)
@test isa(u.age, Field)
@test isa(u.name, Field)

query = from(User, id=1)
@test isa(query, SubQuery)

query = from(where= u.age > 0, select= u.name)
@test isa(query, SubQuery)

schema(User) do user
    has_many(user, :comments, Comment)
end

c = in(Comment)
@test isa(c, Query.models[Comment])
@test isa(c.user_id, Field)

query = from(where= c.user_id in [1,2], select= c.body)
@test isa(query, SubQuery)

end # module test_octo_query
