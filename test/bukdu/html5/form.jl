module test_bukdu_html5_form

using Test # @test
import Bukdu.HTML5.Form: @tags

@tags a

@test string(a[:href => "/"]()) == """<a href="/"></a>"""

end  # module test_bukdu_html5_form
