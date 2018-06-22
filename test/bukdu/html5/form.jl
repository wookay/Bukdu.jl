module test_bukdu_html5_form

using Test # @test
using Bukdu # Changeset
import Bukdu.HTML5.Form: @tags
import Bukdu.HTML5.Form: form_for, label_for
import Bukdu.HTML5.Form: text_input, text_area, radio_button, checkbox
import Bukdu.HTML5.Form: submit

@tags input button form label textarea

struct User
end

f = Changeset(User, (name="Alex",))

@test text_input(f, :name, "Chen")                  ==  input[:id => "user_name", :name => "user_name", :type => "text", :value => "Chen"]

@test submit("Submit")                              ==  button[:type => "submit"]("Submit")

@test form_for((f) -> nothing, f, "/post")          ==  form[:action => "/post", :method => "POST"]

@test label_for(radio_button(f, :choice, "Choice")) ==  [input[:id => "user_choice_Choice", :name => "user_choice", :type => "radio", :value => "Choice"],
                                                         label[:for => "user_choice_Choice"]]

@test checkbox(f, :famous, true)                    ==  [input[:name => "user_famous", :type => "hidden", :value => "false"],
                                                         input[:checked => "checked", :id => "user_famous", :name => "user_famous", :type => "checkbox", :value => "true"]]

@test checkbox(f, :famous, false)                   ==  [input[:name => "user_famous", :type => "hidden", :value => "false"],
                                                         input[:id => "user_famous", :name => "user_famous", :type => "checkbox", :value => "true"]]

@test text_area(f, :intro, nothing)                  ==  textarea[:id => "user_intro", :name => "user_intro"]("")

@tags a
@test string(a[:href => "/"]()) == """<a href="/"></a>"""

end  # module test_bukdu_html5_form
