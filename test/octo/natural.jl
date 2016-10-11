module test_octo_natural

import Bukdu
importall Bukdu.Octo
import Base.Test: @test

@test "user" == singularize("users")
@test "users" == pluralize("user")

end # module test_octo_natural
