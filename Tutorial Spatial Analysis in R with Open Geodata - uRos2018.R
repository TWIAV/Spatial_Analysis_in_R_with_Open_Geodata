## ----setup, include=FALSE, cache = FALSE---------------------------------
knitr::opts_chunk$set(tidy.opts = list(width.cutoff = 60), tidy = TRUE, strip.white = FALSE, echo = TRUE)
knitr::opts_chunk$set(error = TRUE)

## ----eval = FALSE--------------------------------------------------------
## library(knitr)
## purl("Tutorial Spatial Analysis in R with Open Geodata - uRos2018.Rmd")

## ----install_sf, eval = FALSE--------------------------------------------
## install.packages("sf")

## ----library_sf----------------------------------------------------------
library(sf)

## ------------------------------------------------------------------------
ap <- "Lelystad Airport"
cd <- "LEY"
class(cd)
lat <- 52.460278
lon <- 5.527222
class(lon)

## ------------------------------------------------------------------------
airport <- data.frame(ap, cd, lat, lon, stringsAsFactors = FALSE)

## ------------------------------------------------------------------------
NL_Airports <- 
  read.csv("http://www.twiav.nl/files/NL_Airports.csv", stringsAsFactors = FALSE)

NL_Airports

## ------------------------------------------------------------------------
NL_Airports <- rbind(NL_Airports, airport) 
# Oh yeah, of course: this will generate an error...

## ------------------------------------------------------------------------
names(airport) <- names(NL_Airports)

## ------------------------------------------------------------------------
NL_Airports <- rbind(NL_Airports, airport)
NL_Airports
class(NL_Airports)

## ------------------------------------------------------------------------
library(sf)

NL_Airports <- st_as_sf(NL_Airports, coords = c("longitude","latitude"), crs = 4326)

class(NL_Airports)

## ------------------------------------------------------------------------
NL_Airports

## ------------------------------------------------------------------------
plot(st_geometry(NL_Airports), main = "Airports in the Netherlands", pch = 17)

## ------------------------------------------------------------------------
st_write(NL_Airports, "NL_Airports.shp")

## ----echo = FALSE--------------------------------------------------------
# Delete the output files to keep the repository clean
unlink("NL_Airports.*")

## ------------------------------------------------------------------------
st_write(NL_Airports, "NL_Airports.geojson")

## ---- eval = FALSE-------------------------------------------------------
## install.packages("mapview")

## ------------------------------------------------------------------------
library(mapview)

## ----eval = FALSE--------------------------------------------------------
## mapview(NL_Airports, color = "red", col.regions = "orange", alpha.regions = 1, label = NL_Airports$airport)

## ---- eval = FALSE-------------------------------------------------------
## install.packages("tmap")

## ------------------------------------------------------------------------
library(tmap)

## ----results = 'hide'----------------------------------------------------
# Store the URL to the file to download in a variable
URL2zip <- "http://data.statistik.gv.at/data/OGDEXT_GEM_1_STATISTIK_AUSTRIA_20180101.zip"

# Create a temporary file 
zip_file <- tempfile(fileext = ".zip")

# Download the file
download.file(URL2zip, destfile = zip_file, mode = "wb")

# Create a subfolder in your working directory to store the unzipped data
dir.create("./Data", showWarnings = FALSE)

# Unzip the file
unzip(zip_file, exdir = "./Data")
      
# After unzipping you can delete (i.e. unlink) the file
unlink(zip_file)

# Remove variables you do not longer need
rm(URL2zip, zip_file)

## ------------------------------------------------------------------------
library(sf)
library(tmap)
AUSTRIA_GEM_20180101 <- st_read("./Data/STATISTIK_AUSTRIA_GEM_20180101.shp")

## ------------------------------------------------------------------------
qtm(AUSTRIA_GEM_20180101)

## ----echo = FALSE--------------------------------------------------------
# Delete the Data directory to keep the repo clean
unlink("./Data", recursive = TRUE)

## ------------------------------------------------------------------------
# NL: Example with Dutch data
library(sf)
library(tmap)
library(httr)
library(data.table)

url <- list(hostname = "geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetFeature",
                         typename = 
                           "cbsgebiedsindelingen:cbs_gemeente_2017_gegeneraliseerd",
                         outputFormat = "application/json")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
NL_Municipalities2017 <- st_read(request)

## ------------------------------------------------------------------------
qtm(NL_Municipalities2017)
head(NL_Municipalities2017)

## ------------------------------------------------------------------------
# FI: Example with Finnish data
library(sf)
library(tmap)
library(httr)
library(data.table)

url <- list(hostname = "geo.stat.fi/geoserver/vaestoalue/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetFeature",
                         typename = "vaestoalue:kunta_vaki2017",
                         outputFormat = "application/json")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
FI_Municipalities2018_Pop2017 <- st_read(request)

## ------------------------------------------------------------------------
qtm(FI_Municipalities2018_Pop2017)

## ------------------------------------------------------------------------
sum(FI_Municipalities2018_Pop2017$vaesto)
sum(FI_Municipalities2018_Pop2017$miehet)
sum(FI_Municipalities2018_Pop2017$naiset)

## ------------------------------------------------------------------------
# FI: Example with Finnish data
library(httr)
library(data.table)

url <- list(hostname = "geo.stat.fi/geoserver/vaestoalue/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetFeature",
                         typename = "vaestoalue:kunta_vaki2017",
                         count = 5,
                         outputFormat = "application/json")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
# FI: Example with Finnish data
library(httr)
library(data.table)

url <- list(hostname = "geo.stat.fi/geoserver/vaestoalue/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetFeature",
                         typename = "vaestoalue:kunta_vaki2017",
                         propertyname = "geom,nimi,vaesto",
                         outputFormat = "application/json")) %>% 
       setattr("class","url")
request <- build_url(url)

## ----message = FALSE-----------------------------------------------------
library(magrittr)
library(httr)
library(data.table)
library(xml2)

url <- list(hostname = "geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetCapabilities")) %>% 
       setattr("class","url")
request <- build_url(url)
doc <- GET(request) %>% content(as = "text", encoding="UTF-8") %>% read_xml() 
xpath <- paste0("//ows:Operation[@name='GetFeature']",
                "/ows:Parameter[@name='outputFormat']",
                "/ows:AllowedValues/ows:Value")
output_formats <- doc %>% xml_find_all(xpath) %>% xml_text()
output_formats

## ------------------------------------------------------------------------
xpath  <- "//wfs:FeatureType/wfs:Name"
feature_types  <- doc %>% xml_find_all(xpath) %>% xml_text()
head(feature_types) 

## ------------------------------------------------------------------------
xpath <- "//ows:Constraint[@name='CountDefault']/ows:DefaultValue"
maxRecordCount <- doc %>% xml_find_first(xpath) %>% xml_integer()
maxRecordCount

## ------------------------------------------------------------------------
url$query = list(service = "WFS",
                 version = "2.0.0",
                 request = "GetFeature",
                 typename = "cbsgebiedsindelingen:cbs_arbeidsmarktregio_2014_gegeneraliseerd",
                 resultType = "hits") %>% 
            setattr("class","url")
request <- build_url(url)
doc <- doc <- GET(request) %>% content(as = "text", encoding="UTF-8") %>% read_xml() 
xpath <- "//wfs:FeatureCollection/@numberMatched"
hits <- doc %>% xml_find_first(xpath) %>% xml_integer()
hits

## ------------------------------------------------------------------------
url <- list(hostname = "geodata.nationaalgeoregister.nl/bag/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetCapabilities")) %>% 
            setattr("class","url")
request <- build_url(url)
doc <- GET(request) %>% content(as = "text", encoding="UTF-8") %>% read_xml() 
xpath <- "//wfs:FeatureType/wfs:Name"
feature_types <- doc %>% xml_find_all(xpath) %>% xml_text()
feature_types

xpath <- "//ows:Constraint[@name='CountDefault']/ows:DefaultValue"
maxRecordCount <- doc %>% xml_find_first(xpath) %>% xml_integer()
maxRecordCount

url$query = list(service = "WFS",
                 version = "2.0.0",
                 request = "GetFeature",
                 typename = "bag:verblijfsobject",
                 cql_filter = "bag:woonplaats='Hoek van Holland'",
                 resultType = "hits") %>% 
            setattr("class","url")
request <- build_url(url)
doc <- GET(request) %>% content(as = "text", encoding="UTF-8") %>% read_xml()
xpath <- "//wfs:FeatureCollection/@numberMatched"
hits <- doc %>% xml_find_first(xpath) %>% xml_integer()
hits

## ---- message = FALSE, warning = FALSE, results = 'hide'-----------------
library(sf)

url$query <- list(service = "wfs", 
                  version = "2.0.0", 
                  request = "GetFeature",
                  typename = "bag:verblijfsobject",
                  cql_filter = "woonplaats='Hoek van Holland'",
                  outputFormat = "application/json",
                  resultType = "results",
                  count = maxRecordCount,
                  sortBy = "bag:identificatie")

requestAddresses <- function(x) {
  url$query$startIndex <- x
  request <- build_url(url) 
  st_read(request, stringsAsFactors = FALSE)
}

addresses <- lapply(seq(0, hits, maxRecordCount), requestAddresses) %>% do.call(rbind, .)

## ------------------------------------------------------------------------
nrow(addresses)

## ----eval = FALSE--------------------------------------------------------
## library(tmap)
## 
## tmap_mode('view')
## tm_shape(addresses) +  tm_dots(col = "black", scale = 0.1) +
##   tm_legend(show = FALSE) + tm_view(basemaps = 'OpenStreetMap')

## ------------------------------------------------------------------------
# USA: An example with American data
library(sf)
library(tmap)
library(httr)
library(data.table)

url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = "USA_States_Generalized/FeatureServer/0/query",
            query = list(where = "1=1",
                         outFields = "*",
                         returnGeometry = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
USA_States_2017 <- st_read(request)

## ------------------------------------------------------------------------
qtm(USA_States_2017)

## ------------------------------------------------------------------------
# USA: An example with American data
library(httr)
library(data.table)

url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = "USA_States_Generalized/FeatureServer/0/query",
            query = list(where = "POPULATION>10000000",
                         outFields = "STATE_NAME,POPULATION",
                         returnGeometry = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
# USA: An example with American data
library(httr)
library(data.table)

url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = "USA_States_Generalized/FeatureServer/0/query",
            query = list(where = "1=1",
                         outFields = "STATE_NAME,POPULATION",
                         returnGeometry = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)

## ---- message = FALSE, warning = FALSE-----------------------------------
library(httr)
library(data.table)
library(dplyr)
library(jsonlite)
library(sf)

## ------------------------------------------------------------------------

url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = "USA_Railroads_1/FeatureServer",
            query = list(f = "json")) %>% 
       setattr("class","url")
response <- build_url(url) %>% fromJSON() 

## ------------------------------------------------------------------------
response$description
response$copyrightText

## ------------------------------------------------------------------------
response$layers$name

## ------------------------------------------------------------------------
layer_id <- response$layers %>% filter(name == 'USA Railroads') %>% select(id) 
layer_id

## ------------------------------------------------------------------------
layer_path <- paste("USA_Railroads_1/FeatureServer", layer_id, sep = "/")
layer_path

## ------------------------------------------------------------------------
response$maxRecordCount

## ----echo = FALSE, results = 'hide'--------------------------------------
maxRecordCount <- response$maxRecordCount

## ------------------------------------------------------------------------
url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = layer_path,
            query = list(f = "json")) %>% 
       setattr("class","url")
response <- build_url(url) %>% fromJSON() 

## ------------------------------------------------------------------------
response$fields %>% select(name, type)

## ------------------------------------------------------------------------
url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = paste(layer_path, "query", sep = "/"),
            query = list(where = "1=1",
                         returnCountOnly = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)
response <- build_url(url) %>% fromJSON() 
hits <- response$properties$count
hits

## ------------------------------------------------------------------------
url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = paste(layer_path, "query", sep = "/"),
            query = list(where = "1=1",
                         outFields = "OBJECTID, NET_DESC",
                         returnGeometry = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)
railroads <- st_read(request)

## ------------------------------------------------------------------------
nrow(railroads)

## ------------------------------------------------------------------------
url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = paste(layer_path, "query", sep = "/"),
            query = list(where = "NET_DESC <> 'Abandoned'",
                         outFields = "OBJECTID, NET_DESC",
                         returnGeometry = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
railroads_in_use <- st_read(request)
nrow(railroads_in_use)

## ------------------------------------------------------------------------
url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = "USA_States_Generalized/FeatureServer/0/query",
            query = list(where = "1=1",
                         returnGeometry = "true",
                         f = "geojson")) %>% 
       setattr("class","url")
request <- build_url(url)
USA_States_2017 <- st_read(request)

## ----railroads_map, results = 'hide'-------------------------------------
library(tmap)

tm_shape(USA_States_2017) +
  tm_borders("black") +
  tm_shape(railroads_in_use) +
  tm_symbols(col = "red", scale = 0.1, border.lwd = NA) +
  tm_legend(show = FALSE) 

## ----table_of_contents, echo=FALSE, results='hide'-----------------------
library(cbsodataR)

toc <- cbs_get_toc()
nrow(toc)
toc_nl <- cbs_get_toc(Language = "nl")
nrow(toc_nl)
toc_en <- cbs_get_toc(Language = "en")
nrow(toc_en)

## ----ref.label = 'table_of_contents'-------------------------------------

## ----eval = FALSE--------------------------------------------------------
## NL_Regional_Statistics2017 <- cbs_get_data('70072ned')

## ---- message = FALSE, warning = FALSE-----------------------------------
library(dplyr)
library(data.table)
library(stringr)

## ------------------------------------------------------------------------
NL_Regional_Statistics2017 <- cbs_get_data('70072ned', Perioden = "2017JJ00") %>% 
  select(RegioS, Perioden, TotaleBevolking_1, Code_291, Naam_292, Code_293, Naam_294)

## ------------------------------------------------------------------------
NL_Regional_Statistics2017 <- cbs_add_label_columns(NL_Regional_Statistics2017)

## ------------------------------------------------------------------------
NL_Regional_Statistics2017 <- rename(NL_Regional_Statistics2017, 
                                     Code = RegioS, 
                                     Name = RegioS_label,
                                     Year = Perioden,
                                     Year_label = Perioden_label,
                                     Total_population = TotaleBevolking_1,
                                     Region_code = Code_291,
                                     Region_name = Naam_292,
                                     Province_code = Code_293,
                                     Province_name = Naam_294)

## ------------------------------------------------------------------------
cols <- colnames(NL_Regional_Statistics2017)
for (c in cols) {
  attr(NL_Regional_Statistics2017[[c]], "label") <- NULL
}

## ------------------------------------------------------------------------
head(NL_Regional_Statistics2017)

## ------------------------------------------------------------------------
paste(NL_Regional_Statistics2017$Code[1])
paste(NL_Regional_Statistics2017$Region_name[6])

## ------------------------------------------------------------------------
my_string <- paste(NL_Regional_Statistics2017$Region_name[6])
nchar(my_string)

## ------------------------------------------------------------------------
cols <- c('Code', 'Region_code', 'Region_name', 'Province_code', 'Province_name')
NL_Regional_Statistics2017[cols] <- 
  lapply(NL_Regional_Statistics2017[cols], function(x){as.factor(trimws(x))})

## ------------------------------------------------------------------------
head(NL_Regional_Statistics2017)

## ------------------------------------------------------------------------
NL_Regions2017_data <- filter(NL_Regional_Statistics2017, Code %like% "LD")
NL_Provinces2017_data <- filter(NL_Regional_Statistics2017, Code %like% "PV")

## ------------------------------------------------------------------------
# Make sure to drop unused levels from the factors in those new data.frames
NL_Regions2017_data <- droplevels(NL_Regions2017_data)
NL_Provinces2017_data <- droplevels(NL_Provinces2017_data)

## ------------------------------------------------------------------------
NL_Provinces2017_data %>% 
  select(Code, Name, Total_population, Region_code, Region_name)

## ------------------------------------------------------------------------
NL_Provinces2017_data$Name <- 
  as.factor(str_replace(NL_Provinces2017_data$Name," \\(PV\\)", ""))

## ------------------------------------------------------------------------
NL_Regions2017_data %>% select(Code, Name, Total_population)
NL_Regions2017_data$Name <- 
  as.factor(str_replace(NL_Regions2017_data$Name," \\(LD\\)", ""))

## ----exbplot1, eval= FALSE-----------------------------------------------
## barplot(NL_Provinces2017_data$Total_population)
## # Try this yourself - result not printed in this manual

## ----exbplot2------------------------------------------------------------
barplot(NL_Provinces2017_data$Total_population / 1000000, 
        names = NL_Provinces2017_data$Name, 
        las = 2, cex.axis = .6, cex.names = .6, 
        cex.main = .8, cex.lab = .8, space = 0, 
        col = "lightblue", 
        ylab = "Inhabitants (* 1.000.000)", 
        main = "Number of Inhabitants by Province - The Netherlands - 2017")

## ------------------------------------------------------------------------
palette(c("royalblue3", "firebrick3", "darkolivegreen4", "goldenrod1"))

## ------------------------------------------------------------------------
barplot(NL_Provinces2017_data$Total_population / 1000000, 
        names = NL_Provinces2017_data$Name, 
        las = 2, cex.axis = .6, cex.names = .6, 
        cex.main = .8, border = "grey", 
        col = NL_Provinces2017_data$Region_code, 
        ylab = "Inhabitants ( * 1,000,000)", 
        main = "Number of Inhabitants by Province - The Netherlands - 2017", 
        legend.text = unique(NL_Provinces2017_data$Region_name), 
        args.legend = list(x = 'topleft', 
                           bty = 'n', 
                           fill = unique(NL_Provinces2017_data$Region_name), 
                           border = 'grey'))

## ------------------------------------------------------------------------
pie(NL_Regions2017_data$Total_population, labels = NL_Regions2017_data$Name)

## ------------------------------------------------------------------------
pct <- paste0(round(NL_Regions2017_data$Total_population / 
                      sum(NL_Regions2017_data$Total_population) * 100, 1), "%")
lbls <- paste(NL_Regions2017_data$Name, "\n", pct)
palette(c("royalblue3", "firebrick3", "darkolivegreen4", "goldenrod1"))
pie(NL_Regions2017_data$Total_population, labels = lbls, clockwise = TRUE,
    cex = .8, col = NL_Regions2017_data$Name, border = "grey",
    main = "Percentage of Inhabitants by Region - The Netherlands - 2017")

## ----echo = FALSE, results = 'hide', message = FALSE---------------------
palette("default")

## ------------------------------------------------------------------------
NL_Municipalities2017_data <- filter(NL_Regional_Statistics2017, Code %like% "GM")
nrow(NL_Municipalities2017_data)

## ------------------------------------------------------------------------
NL_Municipalities2017_data <- filter(NL_Municipalities2017_data, Total_population != "")
nrow(NL_Municipalities2017_data)

## ------------------------------------------------------------------------
NL_Municipalities2017_data <- droplevels(NL_Municipalities2017_data)

## ------------------------------------------------------------------------
# NL: Example with Dutch data
library(sf)
library(tmap)
library(httr)
library(data.table)
library(dplyr)

url <- list(hostname = "geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetFeature",
                         typename = 
                           "cbsgebiedsindelingen:cbs_gemeente_2017_gegeneraliseerd",
                         outputFormat = "application/json")) %>% 
       setattr("class","url")
request <- build_url(url)

NL_Municipalities2017 <- st_read(request)

## ------------------------------------------------------------------------
NL_Municipalities2017 <- select(NL_Municipalities2017, statcode, statnaam)

## ------------------------------------------------------------------------
NL_Municipalities2017 <- rename(NL_Municipalities2017, Code = statcode, Name2 = statnaam)

## ------------------------------------------------------------------------
NL_Municipalities2017 <- 
  merge(NL_Municipalities2017, NL_Municipalities2017_data, by = "Code")

class(NL_Municipalities2017)

## ----echo=FALSE----------------------------------------------------------
palette(c("royalblue3", "firebrick3", "darkolivegreen4", "goldenrod1"))

## ------------------------------------------------------------------------
qtm(shp = NL_Municipalities2017,
    title = "Regional subdivison",
    fill = "Region_name",
    fill.title = "The Netherlands - 2017\nRegion",
    fill.palette = 
      palette(c("royalblue3", "firebrick3", "darkolivegreen4", "goldenrod1")),
    borders = "grey",
    format = "NLD_wide")

## ----ordered_factor------------------------------------------------------
NL_Municipalities2017 <- mutate(NL_Municipalities2017,
  Category = case_when(Total_population < 50000 ~ "Small population",
                       Total_population >= 50000 & 
                       Total_population < 200000 ~ "Medium population",
                       Total_population >= 200000 ~ "Large population"))

## ----ordered_factor2-----------------------------------------------------
class(NL_Municipalities2017$Category)

## ------------------------------------------------------------------------
population_levels <- c("Small population", "Medium population", "Large population")
NL_Municipalities2017 <- mutate(NL_Municipalities2017, 
  Category = factor(Category, levels = population_levels, ordered = TRUE))

class(NL_Municipalities2017$Category)

## ----change_categories, echo = FALSE, results = 'hide', message = FALSE----
population_levels <- c("Very small population", "Small population", "Medium population", "Large population")
NL_Municipalities2017 <- mutate(NL_Municipalities2017, 
  Category = case_when(Total_population < 20000 ~ "Very small population", TRUE ~ as.character(Category)) %>% 
    factor(levels = population_levels, ordered = TRUE))

## ----tmapcategories------------------------------------------------------
qtm(shp = NL_Municipalities2017, title = "Municipalities by Population Size",
    fill = "Category", fill.title = "The Netherlands - 2017\nCategory", 
    borders = "grey", format = "NLD_wide")

## ------------------------------------------------------------------------
NL_Airports <- st_read("NL_Airports.geojson")

## ------------------------------------------------------------------------
NL_Airports <- st_join(NL_Airports, NL_Municipalities2017)

## ------------------------------------------------------------------------
NL_Airports <- st_join(st_transform(NL_Airports, 28992), NL_Municipalities2017[,c("Name","Province_name","Region_name")])
NL_Airports

## ----echo = FALSE--------------------------------------------------------
# Delete the output files to keep the repository clean
unlink("NL_Airports.geojson")

## ------------------------------------------------------------------------
library(sf)
library(dplyr)

# Neighborhoods in The Hague
url <- "https://ckan.dataplatform.nl/dataset/c1059cef-be66-4a7a-9657-2f38f55794ed/resource/a175afe5-67e2-4e45-8b71-62f30377bf7d/download/wijken.json"
neighborhoods <- st_read(url)

## ------------------------------------------------------------------------
neighborhoods <- st_transform(neighborhoods, 28992)

## ------------------------------------------------------------------------
# Trees in The Hague
url <- "https://ckan.dataplatform.nl/dataset/d604d9bb-8c2f-4e7d-a69c-ee6102890baf/resource/85327fde-9e76-40f3-a8d4-25970896fd8f/download/bomen-json.zip"
zip_file <- tempfile(fileext = ".zip")
download.file(url, destfile = zip_file, mode = "wb")
dir.create("./Data", showWarnings = FALSE)
unzip(zip_file, exdir = "./Data")
unlink(zip_file)
rm(url, zip_file)
trees <- st_read("Data/bomen-json.json") %>%
         select(id = ID, species = BOOMSOORT_WETENSCHAPPELIJ, age = LEEFTIJD)

## ------------------------------------------------------------------------
# Bat flight routes in The Hague
url <- "https://ckan.dataplatform.nl/dataset/c7e9cb41-3b2d-47a4-9f1e-60ee7708f561/resource/ed7d5778-c890-4f4e-bfc3-048923761ace/download/vleermuisroutes.json"
bat_flight_paths <- st_read(url) %>% select(func = FUNCTIE, id = COUNTER)

## ------------------------------------------------------------------------
levels_dutch <- c("Migratieroute water- en meervleermu", 
                  "Vliegroute gewone dwergvleermuis", 
                  "Vliegroute laatvlieger", 
                  "Vliegroute rosse vleermuis", 
                  "Vliegroute watervleermuis")
levels_eng <- c("Migration route Myotis daubentonii and Myotis dasycneme", 
                "Flight path Pipistrelllus pipistrellus", 
                "Flight path Eptesicus serotinus", 
                "Flight path Nyctalus noctula", 
                "Flight path Myotis daubentoni")
bat_flight_paths$func <- 
  plyr::mapvalues(bat_flight_paths$func, from = levels_dutch, to = levels_eng)

## ------------------------------------------------------------------------
bat_flight_paths <- st_transform(bat_flight_paths, 28992)

## ------------------------------------------------------------------------
class(neighborhoods$OPPERVLAKTE)

## ------------------------------------------------------------------------
neighborhoods$area <- st_area(neighborhoods)

## ------------------------------------------------------------------------
class(neighborhoods$area)

## ------------------------------------------------------------------------
neighborhoods[,c("OPPERVLAKTE","area")]

## ------------------------------------------------------------------------
neighborhoods <- neighborhoods %>%
                 select(nh_code = WIJKCODE, nh_name = WIJKNAAM, district_code = STADSDEELCODE)

## ------------------------------------------------------------------------
neighborhoods$area <- st_area(neighborhoods)

## ------------------------------------------------------------------------
library(units)
neighborhoods$area2 <- set_units(neighborhoods$area, km^2)

## ------------------------------------------------------------------------
neighborhoods$area3 <- round(neighborhoods$area2, digits = 2)

## ------------------------------------------------------------------------
neighborhoods %>% filter(area == max(area)) %>% st_set_geometry(NULL)

## ------------------------------------------------------------------------
bat_flight_paths$length <- st_length(bat_flight_paths)

## ------------------------------------------------------------------------
bat_flight_paths %>% arrange(length) %>% 
                     st_set_geometry(NULL) %>% 
                     head(n = 5)

## ------------------------------------------------------------------------
tree_1351893 <- filter(trees, id == 1351893)
tree_1398051 <- filter(trees, id == 1398051)

st_distance(tree_1351893, tree_1398051) %>% round()


## ------------------------------------------------------------------------
st_distance(tree_1351893, bat_flight_paths) %>% min() %>% round()

## ------------------------------------------------------------------------
flight_path_1509 <- filter(bat_flight_paths, id == 1509)
lengths(st_is_within_distance(flight_path_1509, trees, dist = 20))

## ------------------------------------------------------------------------
trees %>% select(species, age) %>% 
          group_by(species) %>% 
          summarize(mean_age = round(mean(age, na.rm =  TRUE), 2), count = n()) %>% 
          arrange(species) %>%
          st_set_geometry(NULL) %>% 
          head(n = 3)

## ------------------------------------------------------------------------
the_hague <- st_union(neighborhoods)

## ------------------------------------------------------------------------
the_hague_districts <- neighborhoods %>% group_by(district_code) %>% summarise()

## ------------------------------------------------------------------------
tm_shape(neighborhoods) +
  tm_borders(col = "grey", alpha = 0.5) +
tm_shape(the_hague_districts) +
  tm_borders(col = "blue", lwd = 2, alpha = 0.5) +
tm_shape(the_hague) +
  tm_borders("red", lwd = 3) +
tm_layout(frame = FALSE)

## ----warning = FALSE-----------------------------------------------------
neighborhoods$total_trees <- lengths(st_covers(neighborhoods, trees))

## ------------------------------------------------------------------------
nrow(trees)
sum(neighborhoods$total_trees)

## ----message = FALSE-----------------------------------------------------
trees_not_in_neighborhood <- trees[the_hague, op = st_disjoint]
nrow(trees_not_in_neighborhood)

## ----message = FALSE-----------------------------------------------------
tm_shape(neighborhoods) +
  tm_borders("black") +
tm_shape(trees) +
  tm_symbols(col = "darkgreen", scale = 0.05, border.lwd = NA) +
tm_shape(trees_not_in_neighborhood) +
  tm_symbols(col = "red", scale = 0.05, border.lwd = NA) +
tm_layout(frame = FALSE) + 
tm_legend(show = FALSE)

## ----message = FALSE, warning = FALSE------------------------------------
trees <- trees[the_hague, op = st_intersects]
nrow(trees)

## ----message = FALSE, warning = FALSE------------------------------------
zorgvliet <- filter(neighborhoods, nh_name == "Zorgvliet")
bat_flight_paths_zorgvliet <- bat_flight_paths[zorgvliet, op = st_intersects]

tm_shape(zorgvliet) +
  tm_borders("black") +
tm_shape(bat_flight_paths_zorgvliet) +
  tm_lines(col = "blue") +
tm_layout(frame = FALSE) +  
tm_legend(show = FALSE)

## ----message = FALSE, warning = FALSE------------------------------------
bat_flight_paths_zorgvliet <- st_intersection(bat_flight_paths, zorgvliet)
trees_zorgvliet <- st_intersection(trees, zorgvliet)

tm_shape(zorgvliet) +
  tm_borders("black") +
tm_shape(trees_zorgvliet) +
  tm_symbols(col = "darkgreen", scale = 0.05, border.lwd = NA) +
tm_shape(bat_flight_paths_zorgvliet) +
  tm_lines(col = "blue") +
tm_layout(frame = FALSE) +
tm_legend(show = FALSE)

## ------------------------------------------------------------------------
neighborhoods$nh_name[which.min(neighborhoods$total_trees)] %>% as.character()
neighborhoods$nh_name[which.max(neighborhoods$total_trees)] %>% as.character()

## ----message = FALSE-----------------------------------------------------
no_trees <- filter(neighborhoods, total_trees == 0)

tm_shape(neighborhoods) +
  tm_borders("black") +
tm_shape(no_trees) +
  tm_fill("grey") +
tm_shape(trees) +
  tm_symbols(col = "darkgreen", scale = 0.05, border.lwd = NA) +
tm_layout(frame = FALSE) + 
tm_legend(show = FALSE)

## ------------------------------------------------------------------------
neighborhoods$tree_density <- 
  round(neighborhoods$total_trees / units::set_units(neighborhoods$area, km^2))
qtm(shp = neighborhoods, fill = "tree_density", 
fill.palette = "Greens",
fill.style = "kmeans", title = "Tree density",
fill.title = parse(text = "trees/km^2"))

## ----echo = FALSE--------------------------------------------------------
# Delete the Data directory to keep the repository clean
unlink("./Data", recursive = TRUE)

## ----message = FALSE-----------------------------------------------------
library(dplyr)
library(httr)
library(data.table)
library(jsonlite)
library(sf)

url <- list(hostname = "nominatim.openstreetmap.org",
            scheme = "http",
            path = paste("search", URLencode("Martinikerkhof 3 Groningen"), sep = "/"),
            query = list(format = "json", adressdetails = 0, limit = 1)) %>% 
       setattr("class","url")
request <- build_url(url)
result <- fromJSON(request) %>% 
          mutate(lat = as.numeric(lat),lon = as.numeric(lon)) %>%
          select(lat, lon, display_name)
result

## ------------------------------------------------------------------------
martini_tower <- st_as_sf(result, coords = c("lon", "lat"), crs = 4326)
martini_tower

## ----eval=FALSE----------------------------------------------------------
## library(tmap)
## 
## tmap_mode('view')
## tm_shape(martini_tower) + tm_markers() +
##   tm_legend(show = FALSE) + tm_view(basemaps = 'OpenStreetMap')

## ------------------------------------------------------------------------
url <- list(hostname = "nominatim.openstreetmap.org",
            scheme = "http",
            query = list(format = "json", adressdetails = 0, limit = 1)) %>% 
       setattr("class","url")

geocodeAddress <- function(x){
  url$path <- paste("search", URLencode(x[2]), sep = "/")
  request <- build_url(url)
  result <- fromJSON(request)
  data.frame(name = x[1], address = result$display_name, 
            lat = as.numeric(result$lat), lon = as.numeric(result$lon),
            row.names = x[1], stringsAsFactors = FALSE)
}

name <- c("Martinitoren", "Sint-Janskerk", "Onze-Lieve-Vrouwekathedraal")
address <- c("Martinikerkhof 3 Groningen", "Vrijthof 24 Maastricht", "Groenplaats 21 Antwerpen")
poi <- data.frame(name, address, stringsAsFactors = FALSE)

poi <- apply(poi, 1, geocodeAddress) %>% 
       bind_rows() %>% 
       st_as_sf(coords = c("lon","lat"), crs = 4326)
poi

## ----message = FALSE-----------------------------------------------------
library(dplyr)
library(httr)
library(data.table)
library(jsonlite)
library(sf)

url <- list(hostname = "geodata.nationaalgeoregister.nl",
            scheme = "https",
            path = paste("locatieserver/v3/free"),
            query = list(q = "'Martinikerkhof 3 Groningen' and type:adres", rows = 1)) %>% 
       setattr("class","url")
request <- build_url(url)
result <- fromJSON(request) 
martini_tower <- data.frame(addres = result$response$docs$weergavenaam, 
                            wkt = result$response$docs$centroide_rd) %>% 
                 st_as_sf(wkt = 2, crs = 28992)

martini_tower

## ------------------------------------------------------------------------
url <- list(hostname = "geodata.nationaalgeoregister.nl",
            scheme = "https",
            path = paste("locatieserver/v3/free"),
            query = list(rows = 1)) %>% 
       setattr("class","url")

geocodeAddress <- function(x){
  url$query$q <- paste("'", x[2], "'", "and type:adres")
  request <- build_url(url)
  result <- fromJSON(request)
  data.frame(name = x[1], 
             addres = result$response$docs$weergavenaam, 
             wkt = result$response$docs$centroide_rd, 
             score = result$response$docs$score, 
             stringsAsFactors = FALSE)
}

name <- c("Martinitoren", "Sint-Janskerk", "Onze-Lieve-Vrouwekathedraal")
address <- c("Martinikerkhof 3 Groningen", "Vrijthof 24 Maastricht", 
             "Groenplaats 21 Antwerpen")
poi <- data.frame(name, address)

poi <- apply(poi, 1, geocodeAddress) %>% 
       bind_rows() %>% 
       st_as_sf(wkt = 3, crs = 28992)
poi

## ------------------------------------------------------------------------
# NL: Human Settlement Analysis
library(sf)
library(tmap)
library(httr)
library(data.table)

url <- list(hostname = "geodata.nationaalgeoregister.nl/bevolkingskernen2011/wfs",
            scheme = "https",
            query = list(service = "WFS",
                         version = "2.0.0",
                         request = "GetFeature",
                         typename = "bevolkingskernen2011:cbsbevolkingskernen2011",
                         outputFormat = "application/json")) %>% 
       setattr("class","url")
request <- build_url(url)

## ------------------------------------------------------------------------
NL_Human_Settlements2011 <- st_read(request)

## ------------------------------------------------------------------------
plot(st_geometry(NL_Human_Settlements2011), col = "orange", border = "red")

## ----echo = FALSE, results = 'hide'--------------------------------------
unlink("./Data", recursive = TRUE)

