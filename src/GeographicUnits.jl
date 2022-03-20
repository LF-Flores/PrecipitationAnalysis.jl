abstract type AbstractGeographicUnit end

struct País <: AbstractGeographicUnit
    name::Symbol
    parts::Vector{Vector{Shapefile.Point}}
end

struct Departamento <: AbstractGeographicUnit
    name::Symbol
    parts::Vector{Vector{Shapefile.Point}}
end

struct Municipio <: AbstractGeographicUnit
    name::Symbol
    parts::Vector{Vector{Shapefile.Point}}
end

# Constructing constants
function make_honduras_data()
    honduras = GEOMETRIES[:Honduras]
    parts = honduras.parts
    connected_components = Vector{Shapefile.Point}[]
    n = length(parts)-1
    for i ∈ 1:n
        range = (1+parts[i]):(parts[i+1])
        component = honduras.points[range]
        push!(connected_components, component)
    end
    component = honduras.points[parts[end]:end]
    push!(connected_components, component)
    return País(:Honduras, connected_components)
end
const HONDURAS = make_honduras_data()

function make_departamentos_data()
    departamentos = GEOMETRIES[:departamentos]
    deptos = Departamento[]
    for (name, depto) ∈ departamentos
        parts = depto.parts
        connected_components = Vector{Shapefile.Point}[]
        n = length(parts)-1
        for i ∈ 1:n
            range = (1+parts[i]):parts[i+1]
            component = depto.points[range]
            push!(connected_components, component)
        end
        index = n>0 ? parts[end]+1 : 1
        component = depto.points[index:end]
        push!(connected_components, component)

        push!(deptos, Departamento(name, connected_components))
    end
    return deptos
end
const DEPARTAMENTOS = make_departamentos_data()

# TODO: Municipio si es necesario, el problema con éstos es que hay nombres repetidos. Para lidiar con ello, el nombre puede venir acompañado con el depto al que pertenecen, pero se debe revisar si la conexión depto-municipio existe en la data


# Tres casos problemáticos:
# - Roatán: No parece que la estación estacion en algún pedazo de tierra representado en los datos, pero sí en la bounding box. Se puede hacer una excepción y manualmente corregir que sí está.
# - El Coco y La Esperanza: tienen coordenadas erróneas.
function check_estaciones(mostrar_encontradas = false)
    for s ∈ STATIONS
        found = false
        for d ∈ PrecipitationAnalysis.DEPARTAMENTOS
            for part ∈ d.parts
                if inpolygon(s.coords, part) == 1 
                    mostrar_encontradas ? println("La estación $(s.name) está en $(d.name)") : nothing
                    found = true
                    break
                end
            end
        end
        found ? nothing : println(" ==> La estación $(s.name) no ha sido encontrada")
    end
end