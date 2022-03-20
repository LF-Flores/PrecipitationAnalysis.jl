###
# Revisar y modularizar
###
using DataStructures, PrecipitationAnalysis, Statistics, StatsPlots
theme(:dark)

# Encontrando fuentes de información y su número de datos
sources = DefaultDict{String, Int64}(0)
lista_estaciones = STATIONS
# Genera el número de estaciones venideras de cada institución.
for estacion ∈ lista_estaciones
    sources[estacion.source_of_data] += 1
end
sources

# Encuentra porcentaje de datos faltantes en una estación
function missing_percentage(station::WeatherStation, missing_signal = -9999.0)
    pcp = station.data.pcp
    return count(x->x==missing_signal, pcp)/length(pcp) 
end

# Devuelve un diccionario de diccionarios, organizando por fuentes de datos, los porcentajes de datos faltantes de cada estacíón
function get_missing_percentages(stations::AbstractVector{WeatherStation})
    result = DefaultDict{String,Dict{String, Float64}}(Dict{String, Float64})
    for station in stations
        result[station.source_of_data][station.name] = missing_percentage(station)
    end
    return Dict(result)
end

function get_statistics_per_source(stations::AbstractVector{WeatherStation})
    quality_per_source = get_missing_percentages(lista_estaciones)
    result = DefaultDict{String,Dict{String, Float64}}(Dict{String, Float64})
    for (name, stations) in quality_per_source
        data = values(stations)
        result[name]["count"] = length(stations)
        result[name]["mean_missing_percentage"] = mean(data)
        result[name]["std_missing_percentage"] = std(data)
        result[name]["quantile_75"] = quantile(data, 0.75)
        result[name]["quantile_25"] = quantile(data, 0.25)
    end
    return result
end

missing_percentage(lista_estaciones[2])
missing_percentage.(lista_estaciones) 
quality_per_source = get_missing_percentages(lista_estaciones)
num_stations_per_source = length.(values(quality_per_source))
statistics_per_source = get_statistics_per_source(lista_estaciones)

statistics_per_source["ENEE"]

function missing_percentage_plot()
    quality_per_source = get_missing_percentages(STATIONS)
    plots = []
    lw = 3
    for source ∈ ("ENEE", "SERNA", "SMN")
        percentages = quality_per_source[source] |> values |> collect
        worst = findmax(percentages)[1]
        p = density(percentages, xlims = (0,1), title = source, lw = lw)
        push!(plots, p)
    end

    complete_data = Float64[]
    for quality_vector ∈ values(quality_per_source)
        q = quality_vector |> values |> collect
        append!(complete_data, q)
    end
    worst = findmax(complete_data)[1]
    p = density(complete_data, xlims = (0,1), title = "Todas", lw = lw)
    push!(plots, p)

    return plots
end

plot(missing_percentage_plot()..., layout=(2,2))

my_density(x) = density(x, xlims = (0,1))
quality_per_source["ENEE"] |> values |> collect |> my_density
quality_per_source["SERNA"] |> values |> collect |> my_density
quality_per_source["SMN"] |> values |> collect |> my_density
y = Float64[]
for quality_vector ∈ values(quality_per_source)
    q = quality_vector |> values |> collect
    append!(y, q)
end
y


y |> values |> collect |> my_density

quality_per_source["ENEE"]


STATIONS.
STATIONS["ENEE"]["El Socorro"]

"""
Próximos análisis
1. Función que ubique por departamento cada estación e identifique clusters de los siguientes tipos:
    - Clusters de buenas estacions que permitan estudiar la dinámica
    - Clusters de malas estacions que no tengan tiempos sobrelapados para poder completarlos entre sí
    - Estaciones aisladas que deban completarse sus observaciones faltantes.
2. Reporte de las estadísticas de este archivo (informe final)
3. ¿Predicción/modelamiento? -> Neural Differential Equation -> Buscar que la replique con máxima verosimilitud, en base a un campo promedio de velocidades, la data que tengo.

# Bosquejo de partes del informe

- Introducción
- Descripción y estado de la data
- Limpieza de la data y consideraciones de calidad
- Metodología de software (Lenguaje, approach, herramientas selectas, etc.)
- Análisis de estadísticos (este archivo, 2)
- 3
- Conclusiones y trabajos futuros

"""