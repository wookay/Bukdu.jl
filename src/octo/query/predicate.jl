# module Bukdu.Octo.Query

type Predicate
    iden::Function
    f::Function
    first::Any
    second::Any
    Predicate(f::Function, first::Any, second::Any) = new(identity, f, first, second)
    Predicate(iden::Function, f::Function, first::Any, second::Any) = new(iden, f, first, second)
end

function isless(a::Any, field::Field)::Predicate
    Predicate(<, a, field)
end

function isless(field::Field, a::Any)::Predicate
    Predicate(>, a, field)
end

function ==(a::Any, field::Field)::Predicate
    Predicate(==, a, field)
end

function ==(field::Field, n::Int)::Predicate
    Predicate(==, n, field)
end

function !(pred::Predicate)::Predicate
    Predicate(identity==pred.iden ? (!) : identity, pred.f, pred.first, pred.second)
end

function ==(lhs::Predicate, rhs::Predicate)::Bool
    ==(lhs.iden, rhs.iden) && ==(lhs.f, rhs.f) && ==(lhs.first, rhs.first) && ==(lhs.second, rhs.second)
end

function and(lhs::Predicate, rhs::Predicate)::Predicate
    Predicate(and, lhs, rhs)
end

function (&)(lhs::Predicate, rhs::Predicate)::Predicate
    and(lhs, rhs)
end

function or(lhs::Predicate, rhs::Predicate)::Predicate
    Predicate(or, lhs, rhs)
end

function (|)(lhs::Predicate, rhs::Predicate)::Predicate
    or(lhs, rhs)
end

in(field::Field, vec::Vector)::Predicate = Predicate(in, field, vec)
in(field::Field, range::UnitRange)::Predicate = Predicate(in, field, collect(range))
not_in(field::Field, vec::Vector)::Predicate = Predicate(!, in, field, vec)
not_in(field::Field, range::UnitRange)::Predicate = Predicate(!, in, field, collect(range))

is_null(field::Field)::Predicate = Predicate(is_null, field, nothing)
is_not_null(field::Field)::Predicate = Predicate(!, is_null, field, nothing)

between(field::Field, range::UnitRange) = Predicate(between, field, range)
between(field::Field, start::Int, stop::Int) = between(field, start:stop)

like(field::Field, s::String) = Predicate(like, field, s)
not_like(field::Field, s::String) = Predicate(!, like, field, s)
