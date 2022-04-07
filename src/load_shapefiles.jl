const HONDURAS_FILE_PATH = "$(SHAPEFILES_PATH)/hnd_admbnda_adm0_sinit_20161005.shp"
const DEPARTAMENTOS_FILE_PATH = "$(SHAPEFILES_PATH)/hnd_admbnda_adm1_sinit_20161005.shp"
const MUNICIPIOS_FILE_PATH = "$(SHAPEFILES_PATH)/hnd_admbnda_adm2_sinit_20161005.shp"
const GEOM_HONDURAS = Shapefile.Table(HONDURAS_FILE_PATH) 
const GEOM_DEPARTAMENTOS = Shapefile.Table(DEPARTAMENTOS_FILE_PATH) 
const GEOM_MUNICIPIOS = Shapefile.Table(MUNICIPIOS_FILE_PATH) 

function make_geometries()
    d_geoms = Shapefile.shapes(GEOM_DEPARTAMENTOS)
    d_names = GEOM_DEPARTAMENTOS.ADM1_ES
    m_geoms = Shapefile.shapes(GEOM_MUNICIPIOS)
    m_names = GEOM_MUNICIPIOS.ADM2_ES
    result = DefaultDict(Dict)
    
    # Departamentos
    for (name, geom) ∈ zip(d_names, d_geoms)
        result[:departamentos][Symbol(name)] = geom
    end

    # Municipios
    for (name, geom) ∈ zip(m_names, m_geoms)
        result[:municipios][Symbol(name)] = geom
    end

    result[:Honduras] = Shapefile.shapes(GEOM_HONDURAS)[1]
    return Dict(result)
end

const GEOMETRIES = make_geometries()