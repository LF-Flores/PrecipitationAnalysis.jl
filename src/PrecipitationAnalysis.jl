module PrecipitationAnalysis

using CSV, Serialization, Dates, Geodesy, DataStructures, Statistics, StructArrays, Shapefile
using PolygonOps
import Base: getindex, eltype

export STATIONS, GEOMETRIES, DEPARTAMENTOS
export WeatherStation

include("constants.jl")
include("weather_station.jl")
include("load_stations.jl")
include("load_shapefiles.jl")
include("GeographicUnits.jl")

end # module
