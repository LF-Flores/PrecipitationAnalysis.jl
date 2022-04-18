function make_ts(filename)
    local csv
    try
        csv = CSV.File(filename, header = 0, 
                       select = [17, 18], silencewarnings = true, skipto=5)
        return try_fill_ts(csv)
    catch
        csv = CSV.File(filename, header = 0, 
                       select = [17, 18] .+ 2, silencewarnings = true, skipto=5)
        return try_fill_ts(csv)
    end
end

function try_fill_ts(csv)
    local fechas
    local pcp
    try
        fechas, pcp = try_push_data(csv, "d/m/y")
    catch 
        fechas, pcp = try_push_data(csv, "m/d/y")
    end
    return TimeData(fechas, pcp) 
end

function try_push_data(csv, date_format)
    typos = (".0    .0", ".   .0", "0  0.0", "")
    fechas = Dates.Date[]
    pcp = Float64[]
    for (fecha, p) ∈ csv
        if ismissing(fecha); continue; end
        if typeof(p) <: AbstractString
            p = p ∈ typos ? "0.0" : p
            p = parse(Float64,replace(p, ',' => '.', "*" => "-9999"))
        end
        push!(fechas, Date(fecha, DateFormat(date_format)))
        push!(pcp, p)
    end
    return fechas, pcp
end

function make_all_ts(directory)
    stations = WeatherStation[]
    local data
    local coords
    for file in readdir(directory)
        source, _, name = split(file, "-")
        name = replace(name, ".csv" => "")
        try
            data = make_ts(directory*file) 
            coords = get_coords(directory*file)
        catch
            continue
        end
        ts = TimeArray(data.dates, data.pcp, [Symbol(name)])
        current_station = WeatherStation(name, string(source), ts, coords)
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
        for date ∈ eachrow(data)
            # @show date typeof(date)
            push!(fechas,date.timestamp)
        end
    end
    return min(fechas...), max(fechas...)
end
const MINMAX_DATES_TUPLE = findminmax(STATIONS)

# TODO: Las fechas se importaron incorrectamente. Revisar el archivo de bash que pasa de Excel a csv. Siguen mal, por la forma en que Julia los incorpora.
function make_time_densities()
    local dict_results
    try
        dict_results = deserialize(TIME_DENSITIES_FILEPATH)
    catch
        mind, maxd = MINMAX_DATES_TUPLE
        rango_fechas = mind:Day(1):maxd
        dict_results = Dict()
        for fecha ∈ rango_fechas
            try
                dict_results[fecha] = STATIONS[fecha]
            catch 
            end
        end
        serialize(TIME_DENSITIES_FILEPATH, dict_results)
    end
    return dict_results
end
const TIME_DENSITIES = make_time_densities()

function dates_with_matches_over(n)
    return filter(x -> x |> last |> length > n, TIME_DENSITIES) |> keys |> collect |> sort
end

## Conteo de coincidencias
struct NumFechasConCoincidencias
    coincidencias::Int
    num_de_fechas::Int
end

function Base.show(io::IO, x::NumFechasConCoincidencias) 
    i = x.coincidencias
    n = x.num_de_fechas
    s = i == 1 ? "" : "s"
    toprint = "Fechas con $i coincidencia$s => $n"
    print(io, toprint)
end

function count_date_matching_stations(time_densities)
    longs = time_densities |> values .|> length
    imin = findmin(longs)[1]
    imax = findmax(longs)[1]
    # result = Dict{String, Int64}()
    result = NumFechasConCoincidencias[]
    for i ∈ imin:imax
        elem = NumFechasConCoincidencias(i, count(y->y==i, longs))
        # result["fechas con $i coincidencias"] = count(y->y==i, longs)
        push!(result, elem) 
    end
    return result
end

const CONTEO_DE_COINCIDENCIAS = count_date_matching_stations(TIME_DENSITIES)