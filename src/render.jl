# module Bukdu

using JSON: JSON as JSON1
json_encode = JSON1.json

function render(::Type{JSON}, obj)
    HT.Response(200, ["Content-Type" => "application/json"]; body = json_encode(obj))
end

function render(::Type{Text}, text)
    HT.Response(200, ["Content-Type" => "text/plain"]; body = text)
end

# module Bukdu
