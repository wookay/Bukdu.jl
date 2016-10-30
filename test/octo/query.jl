module test_octo_query

importall Bukdu
importall Bukdu.Octo
importall .Octo.Repo
importall .Octo.Query
import .Octo.Database: Adapter, NoAdapterError
import Base.Test: @test, @test_throws

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

schema(Comment) do comment
    belongs_to(comment, :user, User)
end

u = in(User)
@test isa(u, Query.A.User)
@test isa(u.id, Field)
@test isa(u.age, Field)
@test isa(u.name, Field)

query = from(select= *, where= u.age > 20)
@test isa(query, SubQuery)
@test_throws NoAdapterError Query.statement(query)

Database.setup(Adapter.MySQL) do adapter
end

@test "SELECT * FROM users AS u WHERE 20 < u.age" == Query.statement(query)

@test "SELECT * FROM users AS u WHERE 1 = u.id" == Query.statement(from(where= u.id == 1))
@test "SELECT * FROM users AS u WHERE 1 = u.id" == Query.statement(from(where= 1 == u.id))
@test "SELECT * FROM users AS u WHERE 1 != u.id" == Query.statement(from(where= u.id != 1)) # <>
@test "SELECT * FROM users AS u WHERE 1 != u.id" == Query.statement(from(where= 1 != u.id)) # <>
@test "SELECT * FROM users AS u WHERE 1 < u.id" == Query.statement(from(where= 1 < u.id))
@test "SELECT * FROM users AS u WHERE 3 > u.id" == Query.statement(from(where= 3 > u.id))
@test "SELECT * FROM users AS u WHERE 3 >= u.id" == Query.statement(from(where= 3 >= u.id))
@test "SELECT * FROM users AS u WHERE 3 <= u.id" == Query.statement(from(where= 3 <= u.id))
@test "SELECT * FROM users AS u WHERE 3 > u.id AND 1 < u.id" == Query.statement(from(where= (3 > u.id) & (u.id > 1)))
@test "SELECT * FROM users AS u WHERE 3 > u.id AND 1 < u.id" == Query.statement(from(where= and(3 > u.id, u.id > 1)))
@test "SELECT * FROM users AS u WHERE 1 < u.id OR 3 > u.id" == Query.statement(from(where= or(1 < u.id, u.id < 3)))

@test "SELECT u.id FROM users AS u" == Query.statement(from(select= u.id))
@test_throws Query.SubQueryError Query.statement(from(select= *))

@test "SELECT u.id, u.name FROM users AS u" == Query.statement(from(select= (u.id, u.name)))
@test "SELECT u.id, u.name FROM users AS u" == Query.statement(from(select= [u.id, u.name]))

@test "SELECT DISTINCT u.name FROM users AS u" == Query.statement(from(select_distinct= u.name))

@test "SELECT * FROM users AS u WHERE u.name IN ('pear', 'banana')" == Query.statement(from(where= u.name in ["pear", "banana"]))
@test "SELECT * FROM users AS u WHERE u.age IN (20, 21, 22)" == Query.statement(from(where= u.age in [20,21,22]))
@test "SELECT * FROM users AS u WHERE u.age IN (20, 21, 22)" == Query.statement(from(where= u.age in 20:22))
@test "SELECT * FROM users AS u WHERE u.name IN ('pear', 'banana')" == Query.statement(from(where= in(u.name, ["pear", "banana"])))
@test "SELECT * FROM users AS u WHERE u.age IN (20, 21, 22)" == Query.statement(from(where= in(u.age, [20,21,22])))
@test "SELECT * FROM users AS u WHERE u.age IN (20, 21, 22)" == Query.statement(from(where= in(u.age, 20:22)))
@test "SELECT * FROM users AS u WHERE u.name NOT IN ('pear', 'banana')" == Query.statement(from(where= !in(u.name, ["pear", "banana"])))
@test "SELECT * FROM users AS u WHERE u.age NOT IN (20, 21, 22)" == Query.statement(from(where= !in(u.age, [20,21,22])))
@test "SELECT * FROM users AS u WHERE u.age NOT IN (20, 21, 22)" == Query.statement(from(where= !in(u.age, 20:22)))
@test "SELECT * FROM users AS u WHERE u.name NOT IN ('pear', 'banana')" == Query.statement(from(where= !(u.name in ["pear", "banana"])))
@test "SELECT * FROM users AS u WHERE u.age NOT IN (20, 21, 22)" == Query.statement(from(where= !(u.age in [20,21,22])))
@test "SELECT * FROM users AS u WHERE u.age NOT IN (20, 21, 22)" == Query.statement(from(where= !(u.age in 20:22)))
@test "SELECT * FROM users AS u WHERE u.name NOT IN ('pear', 'banana')" == Query.statement(from(where= not_in(u.name, ["pear", "banana"])))
@test "SELECT * FROM users AS u WHERE u.age NOT IN (20, 21, 22)" == Query.statement(from(where= not_in(u.age, [20,21,22])))
@test "SELECT * FROM users AS u WHERE u.age NOT IN (20, 21, 22)" == Query.statement(from(where= not_in(u.age, 20:22)))

@test "SELECT * FROM users AS u WHERE u.name IS NULL" == Query.statement(from(where= is_null(u.name)))
@test "SELECT * FROM users AS u WHERE u.name IS NOT NULL" == Query.statement(from(where= !is_null(u.name)))
@test "SELECT * FROM users AS u WHERE u.name IS NOT NULL" == Query.statement(from(where= is_not_null(u.name)))

@test "SELECT * FROM users AS u WHERE u.age BETWEEN 20 AND 22" == Query.statement(from(where= between(u.age, 20:22)))
@test "SELECT * FROM users AS u WHERE u.age BETWEEN 20 AND 22 ORDER BY u.id" == Query.statement(from(where= between(u.age, 20:22), order_by= u.id))
@test "SELECT * FROM users AS u ORDER BY u.id" == Query.statement(from(order_by= u.id))
@test "SELECT * FROM users AS u ORDER BY u.id, u.name" == Query.statement(from(order_by= (u.id, u.name)))
@test "SELECT * FROM users AS u ORDER BY u.id ASC" == Query.statement(from(order_by= asc(u.id)))
@test "SELECT * FROM users AS u ORDER BY u.id DESC" == Query.statement(from(order_by= desc(u.id)))
@test "SELECT * FROM users AS u ORDER BY u.id ASC, u.name DESC" == Query.statement(from(order_by= (asc(u.id), desc(u.name))))

@test "SELECT * FROM users AS u WHERE u.name LIKE 'foo%'" == Query.statement(from(where= like(u.name, "foo%")))
@test "SELECT * FROM users AS u WHERE u.name NOT LIKE 'foo%'" == Query.statement(from(where= not_like(u.name, "foo%")))

@test_throws Query.SubQueryError Query.statement(from(limit= 5))
@test "SELECT * FROM users AS u LIMIT 5" == Query.statement(from(u, limit= 5))

@test_throws Query.SubQueryError Query.statement(from(limit= 5, offset= 2))
@test "SELECT * FROM users AS u LIMIT 5 OFFSET 2" == Query.statement(from(u, limit= 5, offset= 2))

c = in(Comment)
@test "SELECT * FROM users AS u WHERE u.id IN (SELECT c.user_id FROM comments AS c WHERE 3 = c.id)" ==
    Query.statement(from(where= u.id in from(select= c.user_id, where= c.id == 3)))
@test "SELECT * FROM users AS u WHERE u.id NOT IN (SELECT c.user_id FROM comments AS c WHERE 3 = c.id)" ==
    Query.statement(from(where= not_in(u.id, from(select= c.user_id, where= c.id == 3))))
@test "SELECT u.name FROM users AS u WHERE EXISTS (SELECT 1 FROM comments AS c WHERE c.user_id = u.id)" ==
    Query.statement(from(select= u.name, where= exists(from(select= 1, where= c.user_id == u.id))))
@test "SELECT u.name FROM users AS u WHERE NOT EXISTS (SELECT 1 FROM comments AS c WHERE c.user_id = u.id)" ==
    Query.statement(from(select= u.name, where= not_exists(from(select= 1, where= c.user_id == u.id))))

query = from(select= ?, where= u.age > ?)
@test isa(query, SubQuery)
@test "SELECT ? FROM users AS u WHERE ? < u.age" == Query.statement(query)

@test isa(c, Query.A.Comment)
@test isa(c.user_id, Field)

query = from(where= c.user_id in [1,2], select= c.text)
@test isa(query, SubQuery)

end # module test_octo_query
