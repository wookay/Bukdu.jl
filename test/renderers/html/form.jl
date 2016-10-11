module test_renderers_html_form

importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag
import Requests # Requests.get, Requests.post
import Requests: URI, statuscode, text
import Base.Test: @test, @test_throws

type UserController <: ApplicationController
    conn::Conn
end

type User
    name::String
    attendance::Bool
    age::Int
    job::Vector{String}
    lunch::String
    description::String
    happiness::Float64
    attach::Plug.Upload
end

user = User("foo bar", false, 20, [], "chicken", "", 0.5, Plug.Upload())

function post_result(c::UserController)
    change(c, user)
end

function test_form(changes::Assoc)
    form = Changeset(user, changes)
    form_for(form, action=post_result, method=post, multipart=true) do f
        """
<div>
    Name: $(text_input(f, :name))
</div>

<div>
    Attendance: $(checkbox(f, :attendance))
</div>

<div>
    Age: $(select(f, :age, 18:22))
</div>

<div>
    Happiness: $(text_input(f, :happiness))
</div>

<div>
Job: $(checkbox(f, :job, "chef", label_for="Chef"))
     $(checkbox(f, :job, "designer", label_for="Designer"))
     $(checkbox(f, :job, "artist", label_for="Artist"))
</div>

<div>
Lunch: $(radio_button(f, :lunch, "pizza", label_for="Pizza"))
       $(radio_button(f, :lunch, "chicken", label_for="Chiken"))
       $(radio_button(f, :lunch, "noodles", label_for="Noodles"))
</div>

<div>
    $(textarea(f, :description, placeholder="enter description"))
</div>

<div>
    $(file_input(f, :attach))
</div>

$(submit("Submit"))
"""
    end
end

type FormLayout <: ApplicationLayout
end

layout(::FormLayout, body) = "<div>$body</div>"
function index(::UserController)
    contents = test_form(Assoc(name="foo bar"))
    render(HTML/FormLayout, contents)
end


Router() do
    get("/", UserController, index)
    post("/post_result", UserController, post_result)
end


contents = test_form(Assoc(name="foo bar"))

@test """
<form action="/post_result" method="post" enctype="multipart/form-data" accept-charset="utf-8">
<div>
    Name: <input id="user_name" name="user_name" type="text" value="foo bar" />
</div>

<div>
    Attendance: <input id="user_attendance" name="user_attendance" type="checkbox" value="true" />
</div>

<div>
    Age: <select id="user_age" name="user_age">
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20" selected>20</option>
    <option value="21">21</option>
    <option value="22">22</option>
</select>
</div>

<div>
    Happiness: <input id="user_happiness" name="user_happiness" type="text" value="0.5" />
</div>

<div>
Job: <input id="user_job[chef]" name="user_job[chef]" type="checkbox" value="chef"><label for="user_job[chef]">Chef</label></input>
     <input id="user_job[designer]" name="user_job[designer]" type="checkbox" value="designer"><label for="user_job[designer]">Designer</label></input>
     <input id="user_job[artist]" name="user_job[artist]" type="checkbox" value="artist"><label for="user_job[artist]">Artist</label></input>
</div>

<div>
Lunch: <input id="user_lunch[pizza]" name="user_lunch" type="radio" value="pizza"><label for="user_lunch[pizza]">Pizza</label></input>
       <input id="user_lunch[chicken]" name="user_lunch" type="radio" checked="checked" value="chicken"><label for="user_lunch[chicken]">Chiken</label></input>
       <input id="user_lunch[noodles]" name="user_lunch" type="radio" value="noodles"><label for="user_lunch[noodles]">Noodles</label></input>
</div>

<div>
    <textarea id="user_description" name="user_description" placeholder="enter description">
</textarea>
</div>

<div>
    <input id="user_attach" name="user_attach" type="file" />
</div>

<input type="submit" value="Submit" />
</form>""" == contents

conn = (Router)(get, "/")
@test "<div>$contents</div>" == conn.resp_body

conn = (Router)(post, "/post_result", user_name="jack")
@test isa(conn.resp_body, Changeset)
@test Changeset(user,Assoc(name="jack")) == conn.resp_body

conn = (Router)(post, "/post_result", user_attendance="true")
@test Changeset(user,Assoc(attendance=true)) == conn.resp_body

conn = (Router)(post, "/post_result", user_age="20")
@test Changeset(user,Assoc()) == conn.resp_body

conn = (Router)(post, "/post_result", user_age="19")
@test Changeset(user,Assoc(age=19)) == conn.resp_body

conn = (Router)(post, "/post_result", user_undefined="undefined")
@test Changeset(user,Assoc()) == conn.resp_body

form = change(default(User), name="jack")
@test_throws Tag.FormBuildError form_for(()->"", form, action=post_result)
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

Bukdu.start(8082)
resp1 = Requests.get(URI("http://localhost:8082/"))
@test 200 == statuscode(resp1)
@test "<div>$contents</div>" == text(resp1)

resp2 = Requests.post(URI("http://localhost:8082/post_result"), data=Dict("user_name"=>"foo bar"))
@test 200 == statuscode(resp2)
@test """Bukdu.Octo.Changeset(test_renderers_html_form.User("foo bar",false,20,String[],"chicken","",0.5,Bukdu.Plug.Upload("","application/octet-stream",UInt8[])),Bukdu.Octo.Assoc(Tuple{Symbol,Any}[]))""" == text(resp2)

sleep(0.1)
Bukdu.stop()

end # module test_renderers_html_form
