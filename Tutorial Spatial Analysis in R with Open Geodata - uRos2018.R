## ----setup, include=FALSE, cache = FALSE---------------------------------
knitr::opts_chunk$set(tidy.opts = list(width.cutoff = 60), tidy = TRUE, strip.white = FALSE, echo = TRUE)
knitr::opts_chunk$set(error = TRUE)

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

## ------------------------------------------------------------------------
st_write(NL_Airports, "NL_Airports.shp")

## ----echo = FALSE--------------------------------------------------------
# Delete the output files to keep the repository clean
unlink("NL_Airports.*")

## ------------------------------------------------------------------------
st_write(NL_Airports, "NL_Airports.geojson")

## ----echo = FALSE--------------------------------------------------------
# Delete the output files to keep the repository clean
unlink("NL_Airports.geojson")

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
# USA: An example with USA Railroads data

library(httr)
library(data.table)
library(dplyr)
library(jsonlite)

## ------------------------------------------------------------------------

url <- list(hostname = "services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services",
            scheme = "https",
            path = "USA_Railroads_1/FeatureServer",
            query = list(f = "json")) %>% 
       setattr("class","url")
response <- build_url(url) %>% fromJSON() 

## ------------------------------------------------------------------------
response$layers %>% select(id, name)

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

exploited_railroads <- st_read(request)
nrow(exploited_railroads)

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

## ------------------------------------------------------------------------
library(tmap)

tmap_mode("plot")

tm_shape(USA_States_2017) +
  tm_borders("black") +
tm_shape(exploited_railroads) +
  tm_symbols(col = "red", scale = 0.1, border.lwd = NA) +
tm_legend(show = FALSE) 

## ----table_of_contents, echo = FALSE, results = 'hide'-------------------
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
  select(Code, Name, Total_population, Region_code, Region_name) %>% as.data.frame()

## ------------------------------------------------------------------------
NL_Provinces2017_data$Name <- 
  as.factor(str_replace(NL_Provinces2017_data$Name," \\(PV\\)", ""))

## ------------------------------------------------------------------------
NL_Regions2017_data %>% select(Code, Name, Total_population) %>% as.data.frame()
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
NL_Municipalities2017 <- rename(NL_Municipalities2017, Code = statcode, Name = statnaam)

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

