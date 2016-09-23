importall Bukdu
importall Bukdu.Octo
importall Bukdu.Tag

type User
    name::String
    age::Int
end


using Base.Test

form = change(User)
@test """<label for="user_name" />""" == label(form, :name)

form = change(User, name="jack")
@test """<label for="user_name">jack</label>""" == label(form, :name)
@test """<label for="user_name">Name</label>""" == label(form, :name, "Name")
