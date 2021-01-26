module test_bukdu_multipart

using Test
using Bukdu
using HTTP: HTTP, Form, Multipart

function preview(multipart::Multipart)
    mark(multipart)
    data = read(multipart)
    reset(multipart)
    [multipart.filename, String(data)]
end

routes() do
    post("/upload") do conn::Conn
        pre = preview.((conn.params.user_file1, conn.params.user_file2))
        render(Text, pre)
    end
end

Bukdu.start(8191, host="127.0.0.1")

part1 = Multipart("mycoolfile1.txt", IOBuffer("hello"))
part2 = Multipart("mycoolfile2.txt", IOBuffer("world"))
r = HTTP.post("http://127.0.0.1:8191/upload", [], Form(["user_file1" => part1, "user_file2" => part2]))
@test r.body == Vector{UInt8}("""(["mycoolfile1.txt", "hello"], ["mycoolfile2.txt", "world"])""")

seekstart(part2.data)
r = HTTP.post("http://127.0.0.1:8191/upload", [], Form(["user_file1" => Multipart("", IOBuffer()), "user_file2" => part2]))
@test r.body == Vector{UInt8}("""(["", ""], ["mycoolfile2.txt", "world"])""")

Bukdu.stop()

Routing.reset!()

end # module test_bukdu_multipart
