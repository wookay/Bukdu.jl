import Bukdu
importall Bukdu.Octo
using Base.Test

@test "user" == singularize("users")
@test "users" == pluralize("user")
