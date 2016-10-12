"""
    exp10(x)

Compute the base ``10`` exponential of ``x``, in other words ``10^x``.
"""
function exp10 end

#  Method
#    1. Argument reduction: Reduce x to an r so that |r| <= 0.5*log10(2). Given x,
#       find r and integer k such that
#
#                x = k*log10(2) + r,  |r| <= 0.5*log10(2).
#
#    2. Approximate exp2(r) by a polynomial on the interval [-0.5*log10(2), 0.5*log10(2)]:
#
#           exp10(x) = 1.0 + polynomial(x),
#
#    3. Scale back: exp10(x) = 2^k * exp10(r)

@inline @oftype_float _exp10{T}(x::T) = 1 + x *
    (2.30258509299404590109361379290930926799774169921875 + x *
    (2.6509490552391992146397114993305876851081848144531 + x *
    (2.03467859229311986979382709250785410404205322265625 + x *
    (1.17125514891208704071345891861710697412490844726562 + x *
    (0.53938292936491272211441128092701546847820281982422 + x *
    (0.206995848748471877875942936952924355864524841308594 + x *
    (6.8089329573666590444958046646206639707088470458984e-2 + x *
    (1.9597687819971908868010856963337573688477277755737e-2 + x *
    (5.0177511919914418239696551893302967073395848274231e-3 + x *
    (1.15495355449438488228131038937362973229028284549713e-3 + x *
    (2.1189769162835504529192320877228894460131414234638e-5 + x *
    (3.1495643924820348157067595451508168480359017848969e-5 + x *
    (6.4863474217555774567478543701781745767220854759216e-3 + x *
    (1.91957613063707931968723818805244718532776460051537e-4 + x *
    (-7.6153088869436891261699429378495551645755767822266e-2)))))))))))))))

# not recommended for use
@inline @oftype_float _exp10{T<:SmallFloatTypes}(x::T) = 1 + x *
    (2.302585124969482421875 + x *
    (2.650949001312255859375 + x *
    (2.03466701507568359375 + x *
    (1.171257495880126953125 + x *
    (0.54041683673858642578125 + x *
    (0.207421600818634033203125 + x *
    4.1938722133636474609375e-2))))))

@oftype_float function exp10{T}(x::T)
    # reduce
    k = round(T(LOG210)*x)
    n = _trunc(k)
    r = muladd(k, -LOG102U(T), x)
    r = muladd(k, -LOG102L(T), r)

    # compute approximation
    u = _exp10(r)
    u = _ldexp(u,n)
    
    u = ifelse(x == Inf, Inf, u)
    u = ifelse(x == -Inf, 0.0, u)
    return u
end