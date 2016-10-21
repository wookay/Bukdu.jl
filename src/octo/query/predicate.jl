
# Predicate
type Predicate
    iden::Function
    f::Function
    first::Any
    second::Any
    Predicate(f::Function, first::Any, second::Any) = new(identity, f, first, second)
    Predicate(iden::Function, f::Function, first::Any, second::Any) = new(iden, f, first, second)
end

function isless(n::Int64, field::Field)::Predicate
    Predicate(<, n, field.name)
end

function isless(field::Field, n::Int64)::Predicate
    Predicate(>, n, field.name)
end

function ==(n::Int, field::Field)::Predicate
    Predicate(==, n, field.name)
end

function ==(field::Field, n::Int)::Predicate
    Predicate(==, n, field.name)
end

function !(pred::Predicate)::Predicate
    Predicate(identity==pred.iden ? (!) : identity, pred.f, pred.first, pred.second)
end

function ==(lhs::Predicate, rhs::Predicate)::Bool
    ==(lhs.iden, rhs.iden) && ==(lhs.f, rhs.f) && ==(lhs.first, rhs.first) && ==(lhs.second, rhs.second)
end

function in(field::Field, vec::Vector{Int})::Predicate
    Predicate(in, field.name, vec)
end

# and
function (&)(lhs::Predicate, rhs::Predicate)::Predicate
    Predicate(&, lhs, rhs)
end

# or
function (|)(lhs::Predicate, rhs::Predicate)::Predicate
    Predicate(|, lhs, rhs)
end

