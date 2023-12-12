module QuartoTools

export @cached

set_cache_path!(path::AbstractString) = (ENV["QUARTO_TOOLS_CACHE"] = path)

# pretty_html(df) = pretty_table(df; backend = Val(:html), formatters = ft_round(2))
using Serialization

# macro cached(expr::Expr, force::Bool=false)
#     cached_fn(expr, force)
# end
# macro cached(force::Bool, expr::Expr)
#     cached_fn(expr, force)
# end
macro cached(expr::Expr)
    cached_fn(expr, false)
end
macro uncached(expr::Expr)
    cached_fn(expr, true)
end
function cached_fn(expr::Expr, force::Bool)
    @assert expr.head == :(=)
    lhs, rhs = expr.args
    path = joinpath(get(ENV, "QUARTO_TOOLS_CACHE", "output"), "$lhs.jls")
    if isfile(path) && !force
        :($(esc(lhs)) = deserialize($path))
    else
        return :($(esc(expr)); mkpath(dirname($path)); serialize($path, $(esc(lhs))); $(esc(lhs)))
    end
end

end # module QuartoTools
