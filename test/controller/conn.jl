module test_controller_conn

import Bukdu: Conn
import Bukdu: put_status
import Bukdu: halt
import Bukdu: index, action_name
import Base.Test: @test, @test_throws

conn = Conn()

## Request fields - host, method, path, req_headers, scheme
@test :get == conn.method


## Response fields - resp_body, resp_charset, resp_cookies, resp_headers, status, before_send

@test 418 == conn.status # :im_a_teapot

put_status(conn, :ok)
@test 200 == conn.status

put_status(conn, 200)
@test 200 == conn.status

put_status(conn, :not_found)
@test 404 == conn.status


## Connection fields - assigns, halted, state

@test !conn.halted

halt(conn)
@test conn.halted


## Private fields - private

end # module test_controller_conn
