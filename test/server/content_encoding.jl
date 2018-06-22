module test_server_content_encoding

importall Bukdu
import Requests # Requests.post
import Requests: URI, statuscode, text
import Libz: inflate
import Base.Test: @test, @test_throws

deflated_data = UInt8[0x1f,0x8b,0x08,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0xb5,0x91,0xb1,0x4e,0x02,0x31,0x18,0xc7,0x0f,0x4c,0x0c,0x69,0x6c,0xe2,0xe0,0x44,0x34,0xb9,0xb0,0x17,0x39,0xe0,0x38,0x84,0x38,0x78,0xa2,0x48,0x48,0x88,0x21,0x24,0x8e,0xd0,0xeb,0xf5,0xb8,0x46,0x68,0x9b,0x6b,0x31,0x61,0x75,0xf3,0x0d,0x5c,0x0c,0x9b,0x9b,0x6c,0xbc,0x86,0x0f,0xe0,0x1b,0xf8,0x00,0x26,0x8e,0xf6,0x60,0x70,0x75,0xf0,0x9a,0xb4,0x5f,0xbf,0x7e,0x6d,0x7f,0xff,0x2f,0x7f,0x84,0xd2,0x71,0x47,0x83,0x3e,0xd3,0xd7,0x22,0x99,0xfb,0x62,0xc1,0x43,0x9c,0x2c,0xfd,0x25,0x1d,0xca,0x87,0x51,0xec,0xb0,0xc0,0x99,0x36,0x64,0x1f,0x82,0x4b,0xc1,0x35,0xe5,0x1a,0x75,0x98,0x92,0x42,0x31,0xcd,0x04,0x6f,0xd9,0x91,0x79,0x82,0x42,0xac,0x71,0xdb,0xe6,0x78,0x4e,0xcf,0x4b,0x63,0xa2,0x92,0x68,0xac,0xc5,0x3d,0xe5,0x25,0x08,0x20,0x48,0x53,0xe4,0x9e,0x79,0x75,0x5a,0x0b,0x9a,0xa8,0x49,0x03,0x17,0x39,0x0e,0x6d,0xa0,0xaa,0x4b,0xea,0xa8,0xe2,0x35,0xc2,0xd0,0xc1,0x1e,0x21,0x5e,0x0d,0x02,0xf4,0xcf,0x52,0x16,0x8a,0x26,0xe3,0x74,0xbb,0x15,0x12,0x09,0x61,0x07,0x38,0xc9,0x08,0x83,0xa7,0x3b,0x4a,0xb5,0x92,0x11,0x20,0xc6,0x52,0x32,0x4e,0x95,0xda,0x62,0x2a,0x65,0x37,0x23,0xce,0x6c,0xc1,0x49,0xbc,0x73,0x2e,0x66,0xc4,0xb8,0x98,0x11,0x27,0xa4,0x8a,0x24,0x4c,0xa6,0x57,0xb6,0xb4,0xac,0x7c,0xd1,0x1a,0x9b,0x7e,0xda,0x76,0xc4,0x66,0x74,0x77,0x2e,0x38,0x2d,0x4b,0x3e,0x2d,0xfd,0xfe,0x33,0x5a,0x4a,0xda,0xb2,0xd9,0xdc,0x98,0x78,0x6a,0x2a,0xa9,0x98,0xa7,0xdb,0x41,0x17,0x82,0x22,0xb0,0x2c,0x0b,0xf6,0x6e,0x3a,0x43,0x13,0xf7,0xcc,0xcc,0x17,0xf6,0xcd,0xfa,0xa2,0xa3,0xa2,0x09,0x39,0x35,0xec,0xfa,0xd6,0xfa,0xfd,0xf8,0xd3,0x24,0x47,0xbd,0xce,0xc5,0xa8,0x70,0x42,0xc2,0xef,0xd5,0xd7,0x2a,0x07,0x9e,0x27,0x07,0x87,0xd0,0xf2,0x5e,0xf3,0xb3,0x8f,0xb7,0xcd,0xc6,0xd4,0xad,0xde,0xd5,0xa0,0xb3,0xf6,0x27,0x8f,0x7f,0x6f,0x14,0x21,0x08,0x7e,0x00,0xa1,0x8b,0x98,0x61,0x9f,0x03,0x00,0x00]

type WelcomeController <: ApplicationController
    conn::Conn
end

function create(c::WelcomeController)
    c[:body_params][:user_name]
end

Router() do
    post("/create", WelcomeController, create)
end


port = Bukdu.start(:any)

content_type = "multipart/form-data; boundary=----WebKitFormBoundaryByeRpvTh1ib1g6pK"

resp1 = Requests.post(
    URI("http://localhost:$port/create");
    headers=Dict(
        "Content-Encoding" => "gzip, deflate",
        "Content-Type"=>content_type
    ),
    data=deflated_data)
@test 200 == statuscode(resp1)
@test "foo bar" == text(resp1)

resp2 = Requests.post(
    URI("http://localhost:$port/create");
    gzip_data=true,
    headers=Dict("Content-Type" => content_type),
    data=inflate(deflated_data))
@test 200 == statuscode(resp2)
@test "foo bar" == text(resp2)

sleep(0.1)
Bukdu.stop()

end # module test_server_content_encoding
