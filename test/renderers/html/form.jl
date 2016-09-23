importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag

type UserController <: ApplicationController
end

type User
    name::String
    age::Int
    description::String
end

user = User("tom", 20, "")

function post_result(c::UserController)
    change(c, user)
end

function test_form(changes::Assoc)
    form = Changeset(user, changes)
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
    contents = test_form(Assoc(name="foo bar"))
    render(HTML/Layout, contents)
end


Router() do
    get("/", UserController, index)
    post("/post_result", UserController, post_result)
end


using Base.Test

contents = test_form(Assoc(name="foo bar"))

@test """
<form action="/post_result" method="post" accept-charset="utf-8">
<label>
    Name: <input id="user_name" name="user[name]" type="text" value="foo bar" />
</label>

<label>
    Age: <select id="user_age" name="user[age]">
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20" selected>20</option>
</select>
</label>

<input type="submit" value="Submit" />
</form>""" == contents

conn = (Router)(get, "/")
@test "<div>$contents</div>" == conn.resp_body

conn = (Router)(post, "/post_result", user_name="jack")
@test Changeset(User("tom",20,""),Assoc(name="jack")) == conn.resp_body

conn = (Router)(post, "/post_result", user_age="20")
@test Changeset(User("tom",20,""),Assoc()) == conn.resp_body

conn = (Router)(post, "/post_result", user_age="19")
@test Changeset(User("tom",20,""),Assoc(age=19)) == conn.resp_body

conn = (Router)(post, "/post_result", user_undefined="undefined")
@test Changeset(User("tom",20,""),Assoc()) == conn.resp_body

form = change(default(User), name="jack")
@test_throws NoRouteError form_for(()->"", form, action=post_result)
@test """
<form method="post" action="/post_result" accept-charset="utf-8">
</form>""" == form_for((f)->"", form, method=post, action=post_result)
@test """
<form id="ex" method="post" action="/post_result" accept-charset="utf-8">
</form>""" == form_for((f)->"", form, id="ex", method=post, action=post_result)
@test """
<form class="ex" method="post" action="/test" accept-charset="utf-8">
</form>""" == form_for((f)->"", form, class="ex", method=post, action="/test")
@test """
<form class="ex" action="/test" method="get" accept-charset="utf-8">
</form>""" == form_for((f)->"", form, class="ex", action="/test")

@test """
<textarea id="user_description" name="user[description]">
</textarea>""" == textarea(form, :description)

import Requests: statuscode, text

Bukdu.start(8082)
resp1 = Requests.get("http://localhost:8082/")
@test 200 == statuscode(resp1)
@test "<div>$contents</div>" == text(resp1)

resp2 = Requests.post("http://localhost:8082/post_result", data=Dict("user[name]"=>"foo bar"))
@test 200 == statuscode(resp2)
@test """Bukdu.Octo.Changeset(User("tom",20),Bukdu.Octo.Assoc(Tuple{Symbol,Any}[(:name,"foo bar")]))""" == text(resp2)

sleep(0.1)
Bukdu.stop()
