importall Bukdu
import Bukdu.Octo: default, change
import Bukdu.Tag: form_for, text_input, select, submit

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
    form1 = test_form()
    render(HTML/Layout, form1)
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

form1 = test_form()

using Base.Test
conn = (Router)(get, "/")
@test "<div>$form1</div>" == conn.resp_body

conn = (Router)(post, "/post_result", user_name="jack")
@test Dict("user_namee" => "jack") == conn.resp_body

conn = (Router)(post, "/post_result", user_age="20")
@test Dict("user_age" => "20") == conn.resp_body
