module test_bukdu_not_found

using Test
using Bukdu

result = Router.call(get, "/Lorem ipsum dolor sit amet consectetur")
@test result.route.action === Bukdu.System.not_found

result = Router.call(get, "/Lorem ipsum                           ")
@test result.route.action === Bukdu.System.not_found

result = Router.call(get, "/오우놀줄아는놈인가")
@test result.route.action === Bukdu.System.not_found

end # module test_bukdu_not_found
