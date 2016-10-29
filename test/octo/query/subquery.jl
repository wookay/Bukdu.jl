module test_octo_query_subquery

import Bukdu.Octo.Schema: Field
importall Bukdu.Octo.Query
import Base.Test: @test, @test_throws

module A
import ..Query
type Comment <: Query.Model
    user_id
end
end

#=
user_id = Field(A.Comment, :user_id)
@test Predicate(in,user_id,[1,2]) == (user_id in [1,2])

@test "comments" == Query.table_name(A.Comment)

pred = user_id in [1,2]
tables = Query.tables(pred)
@test [A.Comment] == tables
@test "c" == Query.table_alias_name(tables, A.Comment)

=#

end # module test_octo_query_subquery
