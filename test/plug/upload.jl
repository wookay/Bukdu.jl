import Bukdu.Plug: Upload
using Base.Test

lhs = Upload()
rhs = Upload()
@test lhs == rhs
