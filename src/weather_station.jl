struct TimeData
    dates::Vector{Date}
    pcp::Vector{Float64}
end

struct WeatherStation
    name::String
    source_of_data::String
    data::TimeData
    coords::LLA{Float64}
end

function Base.getindex(v::AbstractVector{<:WeatherStation}, i::AbstractString)
    for s ∈ v
        if i == s.name
            return s
        end
    end
    throw(ErrorException("No encontrado"))
end

function Base.getindex(v::AbstractVector{<:WeatherStation}, i::Dates.Date)
    result = WeatherStation[]
    for s ∈ v
        dates = s.data.dates
        mindate = findmin(dates)[1]
        maxdate = findmax(dates)[1]
        if mindate ≤ i ≤ maxdate
            push!(result, s)
        end
    end
    if length(result)>0
        return result |> StructArray
    end
    throw(ErrorException("No encontrado"))
end

# Devuelve todas las estaciones que contengan todas las fechas en el rango `r`
function Base.getindex(v::AbstractVector{<:WeatherStation}, r::StepRange{Dates.Date, Dates.Day})
    result = Base.getindex(v,first(r))
    for d ∈ r
        sub_v = Base.getindex(v,d)
        result = result ∩ sub_v
    end
    if length(result)>0
        return result 
    end
    throw(ErrorException("No encontrado"))
end

function Base.getindex(p::Geodesy.LLA{T}, i::Integer) where {T<:Number}
    if i == 1
        return p.lon
    elseif i == 2
        return p.lat
    elseif i == 3
        return p.alt
    else 
        return 0.0
    end
end

function Base.getindex(p::Shapefile.Point, i::Integer)
    if i == 1
        return p.x
    elseif i == 2
        return p.y
    else 
        return 0.0
    end
end

Base.eltype(::Geodesy.LLA{T}) where {T<:Number} = T
