function make_ts(filename)
    local csv
    try
        csv = CSV.File(filename, header = 4, 
                       select = [17, 18], silencewarnings = true)
        @assert typeof(csv[1][1]) <: AbstractString && typeof(csv[1][2]) <: Real
    catch
        csv = CSV.File(filename, header = 4, 
                       select = [17, 18] .+ 2, silencewarnings = true)   
    end
    fechas = Dates.Date[]
    pcp = Float64[]
    already_printed = false
    for (fecha, p) ∈ csv[begin:end-1]
        if !(typeof(fecha) <: AbstractString); continue; end
        try
            push!(fechas, Date(fecha, DateFormat("d/m/y")))
            push!(pcp, p)
        catch
            push!(fechas, Date(fecha, DateFormat("m/d/y")))
            push!(pcp, p)
        end
    end
    return TimeData(fechas, pcp) 
end

function make_all_ts(directory)
    stations = WeatherStation[]
    for file in readdir(directory)
        source, _, name = split(file, "-")
        name = replace(name, ".csv" => "")
        data = make_ts(directory*file)
        coords = get_coords(directory*file)
        current_station = WeatherStation(name, source, data, coords)
        push!(stations, current_station)
    end
    return stations
end

function get_coords(filename)
    local elevación, X, Y
    for (i, line) in enumerate(readlines(open(filename)))
        if i == 1
            try
                elevación = parse(Float64, split(temp, ",")[10])
            catch
                temp = split(line, ",,")[5]
                elevación = parse(Float64, split(temp, ",")[2]) 
            end
        elseif i == 2
            X = parse(Float64, split(line, ",")[8])
        elseif i == 3
            Y = parse(Float64, split(line, ",")[8])
        else
            break
        end
    end
    return UTM(X, Y, elevación) |> LLAfromUTM(16, true, wgs84)
end

function make_stations()
    local lista_estaciones::Vector{WeatherStation}
    try 
        lista_estaciones = deserialize(STATIONS_SERIALIZED_FILEPATH)
    catch
        lista_estaciones = make_all_ts(PRECIPITATION_DATA_FILEPATH);
        serialize(open(STATIONS_SERIALIZED_FILEPATH, "w"), lista_estaciones)
    end
    return lista_estaciones |> StructArray
end

const STATIONS = make_stations()

function findminmax(v::AbstractVector{WeatherStation})
    fechas = Set{Date}()
    for data ∈ v.data
        for date ∈ data.dates
            push!(fechas,date)
        end
    end
    return min(fechas...), max(fechas...)
end
const MINMAX_DATES_TUPLE = findminmax(STATIONS)

# TODO: Las fechas se importaron incorrectamente. Revisar el archivo de bash que pasa de Excel a csv
function make_time_densities()
    mind, maxd = MINMAX_DATES_TUPLE
    rango_fechas = mind:Day(1):maxd
    dict_results = Dict()
    for fecha ∈ rango_fechas
        try
            dict_results[fecha] = STATIONS[fecha]
        catch
        end
    end
    return dict_results
end