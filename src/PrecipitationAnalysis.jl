module PrecipitationAnalysis

using CSV, Serialization, Dates, Geodesy, DataStructures, Statistics, StructArrays, Shapefile
using PolygonOps
import Base: getindex, eltype

export STATIONS, GEOMETRIES, DEPARTAMENTOS, TIME_DENSITIES, CONTEO_DE_COINCIDENCIAS
export count_date_matching_stations, dates_with_matches_over
export WeatherStation

include("constants.jl")
include("weather_station.jl")
include("load_stations.jl")
include("load_shapefiles.jl")
include("GeographicUnits.jl")

end # module
