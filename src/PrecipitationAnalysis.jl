module PrecipitationAnalysis

using CSV, Serialization, Dates, Geodesy, DataStructures, Statistics, StructArrays, Shapefile, TimeSeries
using PolygonOps, DSP
import Base: getindex, eltype

export STATIONS, GEOMETRIES, DEPARTAMENTOS, TIME_DENSITIES, CONTEO_DE_COINCIDENCIAS
export count_date_matching_stations, dates_with_matches_over
export WeatherStation
export frequency_analysis, highest_powers_and_freqs, clean_missing_values_by_mean_substitution

include("constants.jl")
include("weather_station.jl")
include("load_stations.jl")
include("load_shapefiles.jl")
include("GeographicUnits.jl")
include("spectral_analysis.jl")

end # module
