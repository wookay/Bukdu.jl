# https://html.spec.whatwg.org/multipage/web-sockets.html

module ExampleWebSocket

using Bukdu
const ServerHost = "localhost"
const ServerPort = 8080

struct WSController <: ApplicationController
    conn::Conn
end

function index(c::WSController)
    render(HTML, """
<!DOCTYPE html>
<head>
  <meta charset="utf-8" />
  <title>WebSocket Test</title>
  <script language="javascript" type="text/javascript">

  var wsUri = "ws://$ServerHost:$ServerPort/";
  var output;

  function init()
  {
    output = document.getElementById("output");
    testWebSocket();
  }

  function testWebSocket()
  {
    websocket = new WebSocket(wsUri);
    websocket.onopen = function(evt) { onOpen(evt) };
    websocket.onclose = function(evt) { onClose(evt) };
    websocket.onmessage = function(evt) { onMessage(evt) };
    websocket.onerror = function(evt) { onError(evt) };
  }

  function onOpen(evt)
  {
    writeToScreen("CONNECTED");
    doSend("WebSocket rocks");
  }

  function onClose(evt)
  {
    writeToScreen("DISCONNECTED");
  }

  function onMessage(evt)
  {
    writeToScreen('<span style="color: blue;">RESPONSE: ' + evt.data+'</span>');
    websocket.close();
  }

  function onError(evt)
  {
    writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
  }

  function doSend(message)
  {
    writeToScreen("SENT: " + message);
    websocket.send(message);
  }

  function writeToScreen(message)
  {
    var pre = document.createElement("p");
    pre.style.wordWrap = "break-word";
    pre.innerHTML = message;
    output.appendChild(pre);
  }

  window.addEventListener("load", init, false);

  </script>
</head>
<body>

  <h2>WebSocket Test</h2>

  <div id="output"></div>
</body>
</html>
""")
end

end # module ExampleWebSocket



if PROGRAM_FILE == basename(@__FILE__)

using Bukdu
import .ExampleWebSocket: WSController, ServerHost, ServerPort, index
import Base.CoreLogging: global_logger

global_logger(Bukdu.Logger(
    access_log=(path=normpath(@__DIR__, "access.log"),)
))

routes() do
    get("/", WSController, index)
    plug(Plug.WebSocket) #
end

Bukdu.start(ServerPort, host=ServerHost)

# Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
