function get_optimizer(method::Optimizer)
    method
end

function optimize(f::Function,
                  initial_x::Array;
                  method = NelderMead(),
                  xtol::Real = 1e-32,
                  ftol::Real = 1e-8,
                  grtol::Real = 1e-8,
                  iterations::Integer = 1_000,
                  store_trace::Bool = false,
                  show_trace::Bool = false,
                  extended_trace::Bool = false,
                  show_every::Integer = 1,
                  autodiff::Bool = false,
                  callback = nothing)
    options = OptimizationOptions(;
        xtol = xtol, ftol = ftol, grtol = grtol,
        iterations = iterations, store_trace = store_trace,
        show_trace = show_trace, extended_trace = extended_trace,
        callback = callback, show_every = show_every,
        autodiff = autodiff)
    if options.show_trace
        @printf "Iter     Function value   Gradient norm \n"
    end
    method = get_optimizer(method)::Optimizer
    optimize(f, initial_x, method, options)
end

function optimize(f::Function,
                  g!::Function,
                  initial_x::Array;
                  method = LBFGS(),
                  xtol::Real = 1e-32,
                  ftol::Real = 1e-8,
                  grtol::Real = 1e-8,
                  iterations::Integer = 1_000,
                  store_trace::Bool = false,
                  show_trace::Bool = false,
                  extended_trace::Bool = false,
                  show_every::Integer = 1,
                  callback = nothing)
    options = OptimizationOptions(;
        xtol = xtol, ftol = ftol, grtol = grtol,
        iterations = iterations, store_trace = store_trace,
        show_trace = show_trace, extended_trace = extended_trace,
        callback = callback, show_every = show_every)
    if options.show_trace
        @printf "Iter     Function value   Gradient norm \n"
    end
    method = get_optimizer(method)::Optimizer
    d = DifferentiableFunction(f, g!)
    optimize(d, initial_x, method, options)
end

function optimize(f::Function,
                  g!::Function,
                  h!::Function,
                  initial_x::Array;
                  method = Newton(),
                  xtol::Real = 1e-32,
                  ftol::Real = 1e-8,
                  grtol::Real = 1e-8,
                  iterations::Integer = 1_000,
                  store_trace::Bool = false,
                  show_trace::Bool = false,
                  extended_trace::Bool = false,
                  show_every::Integer = 1,
                  callback = nothing)
    options = OptimizationOptions(;
        xtol = xtol, ftol = ftol, grtol = grtol,
        iterations = iterations, store_trace = store_trace,
        show_trace = show_trace, extended_trace = extended_trace,
        callback = callback, show_every = show_every)
    if options.show_trace
        @printf "Iter     Function value   Gradient norm \n"
    end
    method = get_optimizer(method)::Optimizer
    d = TwiceDifferentiableFunction(f, g!, h!)
    optimize(d, initial_x, method, options)
end

function optimize(d,
                  initial_x::Array,
                  method::Optimizer)
    optimize(d, initial_x, method, OptimizationOptions())
end

function optimize(f::Function,
                  initial_x::Array,
                  method::Optimizer,
                  options::OptimizationOptions)
    if !options.autodiff
        d = DifferentiableFunction(f)
    else
        d = Optim.autodiff(f, eltype(initial_x), length(initial_x))
    end
    optimize(d, initial_x, method, options)
end

function optimize(d::DifferentiableFunction,
                  initial_x::Array,
                  method::Optimizer,
                  options::OptimizationOptions)
    optimize(d.f, initial_x, method, options)
end

function optimize(d::TwiceDifferentiableFunction,
                  initial_x::Array,
                  method::Optimizer,
                  options::OptimizationOptions)
    dn = DifferentiableFunction(d.f, d.g!, d.fg!)
    optimize(dn, initial_x, method, options)
end

function optimize(d::DifferentiableFunction,
                  initial_x::Array;
                  method = LBFGS(),
                  xtol::Real = 1e-32,
                  ftol::Real = 1e-8,
                  grtol::Real = 1e-8,
                  iterations::Integer = 1_000,
                  store_trace::Bool = false,
                  show_trace::Bool = false,
                  extended_trace::Bool = false,
                  show_every::Integer = 1,
                  callback = nothing)
    options = OptimizationOptions(;
        xtol = xtol, ftol = ftol, grtol = grtol,
        iterations = iterations, store_trace = store_trace,
        show_trace = show_trace, extended_trace = extended_trace,
        callback = callback, show_every = show_every)
    if options.show_trace
        @printf "Iter     Function value   Gradient norm \n"
    end
    method = get_optimizer(method)::Optimizer
    optimize(d, initial_x, method, options)
end

function optimize(d::TwiceDifferentiableFunction,
                  initial_x::Array;
                  method = Newton(),
                  xtol::Real = 1e-32,
                  ftol::Real = 1e-8,
                  grtol::Real = 1e-8,
                  iterations::Integer = 1_000,
                  store_trace::Bool = false,
                  show_trace::Bool = false,
                  extended_trace::Bool = false,
                  show_every::Integer = 1,
                  callback = nothing)
    options = OptimizationOptions(;
        xtol = xtol, ftol = ftol, grtol = grtol,
        iterations = iterations, store_trace = store_trace,
        show_trace = show_trace, extended_trace = extended_trace,
        callback = callback, show_every = show_every)
    if options.show_trace
        @printf "Iter     Function value   Gradient norm \n"
    end
    method = get_optimizer(method)::Optimizer
    optimize(d, initial_x, method, options)
end

function optimize{T <: AbstractFloat}(f::Function,
                                      lower::T,
                                      upper::T;
                                      method = Brent(),
                                      rel_tol::Real = sqrt(eps(T)),
                                      abs_tol::Real = eps(T),
                                      iterations::Integer = 1_000,
                                      store_trace::Bool = false,
                                      show_trace::Bool = false,
                                      callback = nothing,
                                      show_every = 1,
                                      extended_trace::Bool = false)
    show_every = show_every > 0 ? show_every: 1
    if extended_trace && callback == nothing
        show_trace = true
    end
    if show_trace
        @printf "Iter     Function value   Gradient norm \n"
    end
    method = get_optimizer(method)::Optimizer
    optimize(f, Float64(lower), Float64(upper), method;
             rel_tol = rel_tol,
             abs_tol = abs_tol,
             iterations = iterations,
             store_trace = store_trace,
             show_trace = show_trace,
             show_every = show_every,
             callback = callback,
             extended_trace = extended_trace)
end

function optimize(f::Function,
                  lower::Real,
                  upper::Real;
                  kwargs...)
    optimize(f,
             Float64(lower),
             Float64(upper);
             kwargs...)
end
