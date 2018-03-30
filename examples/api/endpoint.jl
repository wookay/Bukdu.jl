module Endpoint

export CustomerController

using Bukdu
import Bukdu.Actions: index, show, new, edit, create, delete, update
# using Octo.Adapters.PostgreSQL

struct CustomerController <: ApplicationController
    conn::Conn
end

# Repo.debug_sql()
# Repo.connect(
#    adapter = Octo.Adapters.PostgreSQL,
#    dbname = "postgresqltest",
#    user = "postgres",
#)

struct Customer
end
# Schema.model(Customer, table_name="customers", primary_key="id")

function index(c::CustomerController) # GET
    # customers = Repo.all(Customer)
    customers = [(firstName="John", lastName="Doe"),
                 (firstName="Russ", lastName="Smith"),
                 (firstName="Kate", lastName="Williams")]
    render(JSON, customers)
end

function show(c::CustomerController) # GET
    customer_id = c.params.id
    # customer = Repo.get(Customer, customer_id)
    customer = (firstName="John", lastName="Doe")
    render(JSON, customer)
end

function new(c::CustomerController) # GET
    "new"
end

function edit(c::CustomerController) # GET
    c.params.id
end

function create(c::CustomerController) # POST
    "create"
end

function delete(c::CustomerController) # DELETE
    c.params.id
end

function update(c::CustomerController) # PATCH, PUT
    (c.conn.request.method, c.params.id)
end

end # module Endpoint



if PROGRAM_FILE == basename(@__FILE__)

using .Endpoint
using Bukdu
import Bukdu.Actions: index, show, new, edit, create, delete, update

pipeline(:api) do conn::Conn
end

routes(:api) do
    resources("/customers", CustomerController)
end

Bukdu.start(8080)

# Router.call(get, "/customers") #
# julia> CLI.routes()
# GET     /customers           CustomerController  index   :api
# GET     /customers/new       CustomerController  new     :api
# GET     /customers/:id/edit  CustomerController  edit    :api
# GET     /customers/:id       CustomerController  show    :api
# POST    /customers           CustomerController  create  :api
# DELETE  /customers/:id       CustomerController  delete  :api
# PATCH   /customers/:id       CustomerController  update  :api
# PUT     /customers/:id       CustomerController  update  :api


Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()

end # if


# TEST URL
# curl -X GET http://localhost:8080/customers
# curl -X GET http://localhost:8080/customers/1
# curl -X PUT http://localhost:8080/customers/1

#=
CREATE TABLE customers (
    ID SERIAL,
    firstName VARCHAR(255),
    lastName VARCHAR(255),
    PRIMARY KEY (ID) )
=#
