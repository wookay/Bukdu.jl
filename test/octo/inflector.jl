module test_octo_inflector

import Bukdu.Octo: Inflector
import Base.Test: @test

@test "user" == Inflector.singularize("users")
@test "users" == Inflector.pluralize("user")
@test "schema_migrations" == Inflector.tableize("SchemaMigration")
@test "Schema_Migration" == Inflector.underscore("SchemaMigration")

end # module test_octo_inflector
