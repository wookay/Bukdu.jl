import Bukdu.Octo: default, change
import Bukdu.Tag: label

type User
    name::String
    age::Int
end

form = change(default(User), name="jack")

using Base.Test
@test """<label for="user_name">Name</label>""" == label(form, :name, "Name")
