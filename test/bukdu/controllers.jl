module test_bukdu_controllers

using Test # @test_throws
using Bukdu # routes get ApplicationController Routing
import Bukdu.Actions: index

@test_throws Routing.AbstractControllerError routes(() -> get("/", ApplicationController, index))

end # module test_bukdu_controllers
