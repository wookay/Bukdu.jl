importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag

type User
    name::String
    attendance::Bool
    age::Int
    description::String
end


using Base.Test

form = change(User)
@test """<label for="user_name" />""" == label(form, :name)

f = change(User, name="foo bar")
@test """<label for="user_name" />""" == label(f, :name)
@test """<label for="user_name">Name</label>""" == label(f, :name, "Name")

@test """<input id="user_name" name="user[name]" type="text" value="foo bar" />""" == text_input(f, :name)

@test """
<select id="user_age" name="user[age]">
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20">20</option>
</select>""" == select(f, :age, 18:20)

user = User("tom", false, 20, "")
f = change(user)
@test """
<select id="user_age" name="user[age]">
    <option value="18">18</option>
    <option value="19">19</option>
    <option value="20" selected>20</option>
</select>""" == select(f, :age, 18:20)

@test """<textarea id="user_description" name="user[description]">
</textarea>""" == textarea(f, :description)

f = nothing
@test """<input id="description" name="description" type="hidden" />""" == hidden_input(f, :description)
@test """<input id="description" name="description" type="hidden" value="hello" />""" == hidden_input(f, :description, value="hello")
