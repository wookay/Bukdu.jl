using Bukdu

# https://github.com/zalandoresearch/fashion-mnist

struct FashionController <: ApplicationController
    conn::Conn
end

function index(c::FashionController)
    FashionClothes  = first.(split("""
👕
👖
🏂
👗
🧥
👡
👔
👟
👜
👢  """, '\n'))
    x = rand(1:10)
    render(HTML, string(x, ' ', FashionClothes[x]))
end



if PROGRAM_FILE == basename(@__FILE__)

routes() do
    get("/", FashionController, index)
end

Bukdu.start(8080)

# Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if
