importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag

type UserController <: ApplicationController
end

post_result(c::UserController) = c[:query_params]

type User
    name::String
    age::Int
end

function test_form()
    form = change(default(User), name="jack")
    form_for(form, action=post_result, method=post) do f
"""
<label>
    Name: $(text_input(f, :name))
</label>

<label>
    Age: $(select(f, :age, 18:20))
</label>

$(submit("Submit"))
"""
    end
end

layout(::Layout, body) = "<div>$body</div>"
function index(::UserController)
    contents = test_form()
    render(HTML/Layout, contents)
end


Router() do
    get("/", UserController, index)
    post("/post_result", UserController, post_result)
end


using Base.Test

@test """
<form action="/post_result" method="post">
<label>
    Name: <input id="user_name" name="user[name]" type="text" value="" />
</label>

<label>
    Age: <select id="user_age" name="user[age]">
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20">20</option>
</select>
</label>

<input type="submit" value="Submit" />
</form>""" == test_form()

contents = test_form()

using Base.Test
conn = (Router)(get, "/")
@test "<div>$contents</div>" == conn.resp_body

conn = (Router)(post, "/post_result", user_name="jack")
@test Dict("user_name" => "jack") == conn.resp_body

conn = (Router)(post, "/post_result", user_age="20")
@test Dict("user_age" => "20") == conn.resp_body

form = change(default(User), name="jack")
@test_throws NoRouteError form_for(()->"", form, action=post_result)
@test """
<form method="post" action="/post_result">
</form>""" == form_for((f)->"", form, method=post, action=post_result)
@test """
<form id="ex" method="post" action="/post_result">
</form>""" == form_for((f)->"", form, id="ex", method=post, action=post_result)
@test """
<form class="ex" method="post" action="/test">
</form>""" == form_for((f)->"", form, class="ex", method=post, action="/test")
