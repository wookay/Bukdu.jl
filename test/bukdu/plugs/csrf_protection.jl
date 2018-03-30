using Test
using Bukdu
import .Bukdu: Deps

req = Deps.Request()
conn = Conn(req)
@test applicable(plug, Plug.CSRF.Protection, conn)
