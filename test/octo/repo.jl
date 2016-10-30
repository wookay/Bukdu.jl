module test_octo_repo

importall Bukdu
importall Bukdu.Octo
importall Bukdu.Octo.Repo
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

#@test !isdefined(Schema.A, :User)

schema(User) do user
    has_many(user, :comments, Comment)
end

@test isdefined(Schema.A, :User)

#=
@test_throws NoAdapterError Repo.insert(User, name="foo bar", age=20)

Repo.set_adapter(Dict)

user = Repo.insert(User, name="foo bar", age=20)
@test isa(user, Schema.A.User)

comment = Repo.insert(Comment, user_id=user.id, body="1")
@test isa(comment, Schema.A.Comment)

comment = Repo.insert(Comment, user_id=user.id, body="2")

user = Repo.get(User, 1)
@test isa(user, Schema.A.User)
@test isa(user.id, Int)
@test isa(user.name, String)
@test 1 == user.id
@test "foo bar" == user.name

@test isa(user.comments, Base.Generator)

comments = user.comments

Database.reset(Adapter{Dict})
#@test 2 == length(collect(comments))
#@test [Comment(PrimaryKey(1), "1"),Comment(PrimaryKey(2), "2")] == collect(comments)

=#
end # module test_octo_repo
