using Bukdu # ApplicationController Conn Plug Render JavaScript render get

#=
using Charlotte # @code_wasm

    relu(x) = ifelse(x < 0, 0, x)
    w = @code_wasm relu(1)
    wast = string(w)
    Render("application/octet-stream", unsafe_wrap(Vector{UInt8}, wast))

(func (param i64) (result i64)
  (i64.const 0)
  (get_local 0)
  (get_local 0)
  (i64.const 0)
  (i64.lt_s)
  (select)
  (return))
=#

struct WasmController <: ApplicationController
    conn::Conn
end

function hello_wast(::WasmController)
    render(Text, """
(module
  (type (;0;) (func (param i32 i32)))
  (type (;1;) (func))
  (import "env" "memory" (memory (;0;) 256 256))
  (import "env" "print" (func (;0;) (type 0)))
  (func (;1;) (type 1)
    i32.const 1400
    i32.const 13  ;; length
    call 0)
  (export "_main" (func 1))
  (data (i32.const 1400) "Hello, world!"))
""")
end

# https://gist.github.com/SpaceManiac/daf03e0ac6ed56e7a7723ccdeaf5cfe2
function hello_js(::WasmController)
    render(JavaScript, """
var memory = new WebAssembly.Memory({initial:256, maximum:256});
var imports = { 'env': { 'memory': memory, 'print': print, } };

function console_out(text) {
    let LF = "\\n";
    var c = document.getElementById('console');
    c.innerText += text + LF;
}

function print(ptr, len) {
    let text = new TextDecoder().decode(new DataView(memory.buffer, ptr, len));
    console_out(text);
};

async function fetch_wast() {
    console_out("fetch_wast /hello.wast");
    let res = await fetch('/hello.wast');
    return res.arrayBuffer();
}

function wast_to_wasm(buf) {
    console_out("wast_to_wasm (wast: " + buf.byteLength + " bytes)");
    let module = wabt.parseWat('hello.wast', buf);
    module.resolveNames();
    module.validate();
    let bin = module.toBinary({log: true, write_debug_names: true});
    return bin.buffer;
}

function wasm_instantiate(bytes) {
    console_out("wasm_instantiate (wasm: " + bytes.length + " bytes)");
    return WebAssembly.instantiate(bytes, imports);
}

function call_result_instance_main(result) {
    console_out("call_result_instance_main()");
    result.instance.exports._main();
}

document.addEventListener('DOMContentLoaded', function () {
    wabt.ready.then(fetch_wast)
              .then(wast_to_wasm)
              .then(wasm_instantiate)
              .then(call_result_instance_main);
});
""")
end

import InteractiveUtils # InteractiveUtils.versioninfo
function get_banner_versioninfo()
    oldout = stdout
    rdout, wrout = redirect_stdout()
    out = @async read(rdout, String)
    Base.banner() #
    InteractiveUtils.versioninfo() #
    redirect_stdout(oldout)
    close(wrout)
    rstrip(fetch(out))
end

function index(::WasmController)
    render(HTML, """
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Bukdu sevenstars</title>
  <script src="/javascripts/libwabt.js"></script>
  <script src="/hello.js"></script>
  <style>
    div#console {
      background-color: lightgoldenrodyellow;
      border-style: ridge;
    }
  </style>
</head>
<body>
  <h3>Bukdu sevenstars</h3>
  <ul>
    <li><a href="https://github.com/wookay/Bukdu.jl/tree/sevenstars">https://github.com/wookay/Bukdu.jl/tree/sevenstars</a></li>
  </ul>
  <pre>$(get_banner_versioninfo())</pre>
  <div id="console" />
</body>
</html>
""")
end

Router() do
    get("/", WasmController, index)
    get("/hello.js", WasmController, hello_js)
    get("/hello.wast", WasmController, hello_wast)
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "public"))
end

Bukdu.start(8080)

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
