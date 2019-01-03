module test_bukdu_server

using Bukdu
using Test

Bukdu.start(8190)
sleep(0)
Bukdu.stop()

Bukdu.start(8190, host="127.0.0.1")
sleep(0)
Bukdu.stop()

version_line = first(filter(line -> startswith(line, "version"), readlines(normpath(pathof(Bukdu), "..", "..", "Project.toml"))))
@test occursin(string(Bukdu.BUKDU_VERSION), version_line)

end # module test_bukdu_server
