# module Bukdu

using JSON: JSON as JSON1
const json_encode = JSON1.json

function build_response(header::Pair{String, String}; body)::HT.Response
    status = 200
    headers = [
        "Server" => string("Bukdu/", BUKDU_VERSION),
        header,
    ]
    HT.Response(status, headers; body)
end

function render(::Type{JSON}, obj)::HT.Response
    build_response("Content-Type" => "application/json; charset=utf-8"; body = json_encode(obj))
end

function render(::Type{Text}, plain)::HT.Response
    build_response("Content-Type" => "text/plain; charset=utf-8"; body = plain)
end

function render(::Type{HTML}, html)::HT.Response
    build_response("Content-Type" => "text/html; charset=utf-8"; body = html)
end

# module Bukdu
