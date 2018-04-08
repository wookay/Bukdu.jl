# https://html.spec.whatwg.org/multipage/server-sent-events.html

module ExampleSSE

using Bukdu

struct SSEController <: ApplicationController
    conn::Conn
end

function index(c::SSEController)
    render(HTML, """
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Server Sent Events</title>
  <style>
div#console {
  color: red;
}
  </style>
  <script>
function console_out() {
  let LF = "\\n";
  var text = "";
  var c = document.getElementById('console');
  for(var i = 0; i < arguments.length; i++) {
    text += arguments[i];
  }
  c.innerText += text + LF;
}
  </script>
</head>
<body>
<pre style="background-color: #ffffcc;">
julia> h = first(Bukdu.sse_streams())
HTTP.Streams.Stream{HTTP.Messages.Request,HTTP.ConnectionPool.Transaction{Sockets.TCPSocket}}(HTTP.Messages.Request:
\"\"\"
GET /sse HTTP/1.1
Host: 127.0.0.1:8080
Connection: keep-alive
Accept: text/event-stream
Cache-Control: no-cache
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36
Referer: http://127.0.0.1:8080/
Accept-Encoding: gzip, deflate, br
Accept-Language: ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7

\"\"\", T1  ⏸    1↑🔒    1↓🔒   127.0.0.1:8080:8080 ≣16 inactive 10.4s, true, false, 0)

julia> write(h, string("data: ", repr("Hello"), "\\r\\n\\r\\n"))
23
</pre>
  <script>
    let eventSource = new EventSource('/sse');
    eventSource.addEventListener('message', function(e) {
      console_out(e.data)
    }, false);
  </script>
  <div id="console">
  </div>
</body>
</html>""")
end

function sse(c::SSEController)
    render(EventStream)
end

end # module ExampleSSE



if PROGRAM_FILE == basename(@__FILE__)

using Bukdu
import .ExampleSSE: SSEController, index, sse
import Base.CoreLogging: global_logger

global_logger(Bukdu.Logger(
    access_log=(path=normpath(@__DIR__, "access.log"),)
))

routes() do
    get("/", SSEController, index)
    get("/sse", SSEController, sse)
    plug(Plug.ServerSentEvents) #
end

Bukdu.start(8080)

# Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
