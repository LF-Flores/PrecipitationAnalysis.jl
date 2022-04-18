# Limpieza de datos
function clean_missing_values_by_mean_substitution(station_data::Vector, missing_signal = -9999)
    non_missing_values = filter(x -> x!=-9999, station_data)
    station_mean = non_missing_values |> mean
    restored_station_data = replace(station_data, missing_signal => station_mean)
    return restored_station_data
end

function strongest_periods(station_data, max_points = 3, yearly = true)
    restored_station_data = clean_missing_values_by_mean_substitution(station_data)
    p_station = periodogram(restored_station_data)
    powers_and_freqs = highest_powers_and_freqs(p_station, max_points)
    periods = (x->1/x[2]).(powers_and_freqs) 
    return yearly ? periods ./ 365 : periods
end

function highest_powers_and_freqs(p::Periodograms.Periodogram, max_points = 3)
    powers = p.power |> values |> deepcopy
    freqs = collect(p.freq)
    result = Tuple{Float64,Float64}[]
    for _ ∈ 1:max_points+1
        power, i = findmax(powers)
        f = freqs[i]
        push!(result, (power, f))
        deleteat!(powers, i)
        deleteat!(freqs, i)
    end
    return result[2:end]
end

highest_powers_and_freqs(p::Vector, max_points = 3) = highest_powers_and_freqs(periodogram(p), max_points)
highest_powers_and_freqs(p::WeatherStation, max_points = 3) = highest_powers_and_freqs(values(p.data), max_points)

function frequency_analysis(station)
    p = station.data |> values
    return strongest_periods(p)
end