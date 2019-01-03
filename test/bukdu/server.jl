module test_bukdu_server

using Bukdu

Bukdu.start(8190)
sleep(0)
Bukdu.stop()

Bukdu.start(8190, host="127.0.0.1")
sleep(0)
Bukdu.stop()

end # module test_bukdu_server
