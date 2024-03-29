module test_json_parse

using Test
using JSON

json_decode = JSON.parse
json_encode = JSON.json

@test_throws ErrorException json_decode(IOBuffer())  #
@test_throws ErrorException json_decode(IOBuffer("1"))  #
@test json_decode(String(take!(IOBuffer("1")))) == 1
@test json_decode(read(IOBuffer("1"), String)) == 1
@test (json_encode ∘ json_decode)(IOBuffer("[1]"))   == "[1]"
@test (json_encode ∘ json_decode)(IOBuffer("[1.0]")) == "[1.0]"

@test_throws ErrorException json_decode("")  #
@test json_decode("1")   isa Int
@test json_decode("1.0") isa Float64
@test (json_encode ∘ json_decode)("[1]")   == "[1]"
@test (json_encode ∘ json_decode)("[1.0]") == "[1.0]"

end # module test_json_parse


module test_json2_parse

using Test
using JSON2

json_decode = JSON2.read
json_encode = JSON2.write

@test json_decode(IOBuffer()) == NamedTuple()
@test json_decode(IOBuffer("1")) == 1
@test json_decode(String(take!(IOBuffer("1")))) == 1
@test json_decode(read(IOBuffer("1"), String)) == 1
@test (json_encode ∘ json_decode)(IOBuffer("[1]"))   == "[1]"
@test (json_encode ∘ json_decode)(IOBuffer("[1.0]")) == "[1]"  #

@test json_decode("") == NamedTuple()
@test json_decode("1")   isa Int
@test json_decode("1.0") isa Int  #
@test (json_encode ∘ json_decode)("[1]")   == "[1]"
@test (json_encode ∘ json_decode)("[1.0]") == "[1]"   #

end # module test_json2_parse


module test_json3_parse

using Test
using JSON3

json_decode = JSON3.read
json_encode = JSON3.write

@test_throws ArgumentError json_decode(IOBuffer()) #
@test json_decode(IOBuffer("1")) == 1
@test json_decode(String(take!(IOBuffer("1")))) == 1
@test json_decode(read(IOBuffer("1"), String)) == 1
@test (json_encode ∘ json_decode)(IOBuffer("[1]"))   == "[1]"
@test (json_encode ∘ json_decode)(IOBuffer("[1.0]")) == "[1]"  #

@test_throws ArgumentError json_decode("") #
@test json_decode("1")   isa Int
@test json_decode("1.0") isa Int  #
@test (json_encode ∘ json_decode)("[1]")   == "[1]"
@test (json_encode ∘ json_decode)("[1.0]") == "[1]"   #

end # module test_json3_parse


module test_json3_parse_jsonlines

using Test
using JSON3

json_decode(json) = JSON3.read(json, jsonlines=true)  #
json_encode = JSON3.write

@test_throws ArgumentError json_decode(IOBuffer())
@test json_decode(IOBuffer("1")) == [1]  #
@test json_decode(String(take!(IOBuffer("1")))) == [1]  #
@test json_decode(read(IOBuffer("1"), String)) == [1]  #
@test (json_encode ∘ json_decode)(IOBuffer("[1]"))   == "[[1]]"  #
@test (json_encode ∘ json_decode)(IOBuffer("[1.0]")) == "[[1]]"  #

@test_throws ArgumentError json_decode("")
@test json_decode("1")   isa JSON3.Array  #
@test json_decode("1.0") isa JSON3.Array  #
@test (json_encode ∘ json_decode)("[1]")   == "[[1]]"  #
@test (json_encode ∘ json_decode)("[1.0]") == "[[1]]"  #

end # module test_json3_parse_jsonlines
