importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag

type UserController <: ApplicationController
end

type User
    name::String
    age::Int
end

user = User("tom", 20)

post_result(c::UserController) = change(c, user)


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
    contents = test_form(Assoc(name="jack"))
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
    Name: <input id="user_name" name="user[name]" type="text" value="jack" />
</label>

<label>
    Age: <select id="user_age" name="user[age]">
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20" selected>20</option>
</select>
</label>

<input type="submit" value="Submit" />
</form>""" == test_form(Assoc(name="jack"))

contents = test_form(Assoc(name="jack"))

using Base.Test
conn = (Router)(get, "/")
@test "<div>$contents</div>" == conn.resp_body

conn = (Router)(post, "/post_result", user_name="jack")
@test Changeset(User("tom",20),Assoc(name="jack")) == conn.resp_body

conn = (Router)(post, "/post_result", user_age="20")
@test Changeset(User("tom",20),Assoc()) == conn.resp_body

conn = (Router)(post, "/post_result", user_age="19")
@test Changeset(User("tom",20),Assoc(age=19)) == conn.resp_body

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
