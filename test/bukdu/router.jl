module test_bukdu_router

using Test
using Bukdu

struct ExController <: ApplicationController
    conn::Conn
end

f1(::ExController) = nothing
f2(::ExController) = "a"
f3(::ExController) = "abc"[1:2]
f4(::ExController) = 0
f5(::ExController) = 3.14
f6(::ExController) = (1, 2)
f7(::ExController) = (a=1,)

routes() do
    for func in (f1, f2, f3, f4, f5, f6, f7)
        get(string("/", nameof(func)), ExController, func)
    end
end

result = Router.call(get, "/f1")
@test result.got === nothing
@test result.resp.body == Vector{UInt8}("nothing")

result = Router.call(get, "/f2")
@test result.got == "a"
@test result.resp.body == Vector{UInt8}("a")

result = Router.call(get, "/f3")
@test result.got == "ab"
@test result.resp.body == Vector{UInt8}("ab")

result = Router.call(get, "/f4")
@test result.got == 0
@test result.resp.body == Vector{UInt8}("0")

result = Router.call(get, "/f5")
@test result.got == 3.14
@test result.resp.body == Vector{UInt8}("3.14")

result = Router.call(get, "/f6")
@test result.got == (1, 2)
@test result.resp.body == Vector{UInt8}("(1, 2)")

result = Router.call(get, "/f7")
@test result.got == (a=1,)
@test result.resp.body == Vector{UInt8}("(a = 1,)")

Routing.empty!()

end # module test_bukdu_router
