importall Bukdu
import Bukdu.Ecto: default, change
import Bukdu.Tag: form_for, text_input, select, submit

type UserController <: ApplicationController
end

post_result(::UserController) = ""

Router() do
    post("/post_result", UserController, post_result)
end

type User
    name::String
    age::Int
end

form = change(default(User), name="jack")

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

<submit type="submit" value="Submit" />
</form>""" ==

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
