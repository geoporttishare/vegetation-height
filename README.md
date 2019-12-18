<img src="https://github.com/geoportti/Logos/blob/master/geoportti_logo_300px.png">

# Point cloud to vegetation height

This repository contains R-script that read LAZ point clouds and generate a vegetation height data. At the first is done the digital detain model (DTM) and then the digital height model (CHM), which is normamalized by DTM. 
Script use lidR library - grid_terrain algorithm, see https://www.rdocumentation.org/packages/lidR/versions/1.6.1/topics/grid_terrain and grid_canopy algorithm, see: https://rdrr.io/cran/lidR/man/grid_canopy.html
This script use the LAScatalog processing engine, see https://rdrr.io/cran/lidR/man/catalog_apply.html.

This script shows the technical way how calculate vegetation height in CSC environment using laz-files stored in directory `/proj/ogiir-csc/mml/laserkeilaus/`. Is doesn't give the most perfect results, used parameters should be changed. 

## Getting Started

This script is designed to work in CSC environment (https://www.csc.fi/get-started), but works also in your own desktop -  install all the required libraries (see Dependencies and Installing) and change parameter `LASPOLKU` (=path, where laz files are stored), see Running / Deployment.
Use RSrudio to run and test the script first time. RSrudio is already installed in the CSC Taito (and Puhti) environment, see detailed information https://research.csc.fi/-/r.

### Dependencies

CSC rspatial-env environment in Taito (Puhti), see https://research.csc.fi/-/rspatial-env, use libraries:
- lidR - https://cran.r-project.org/web/packages/lidR/index.html
- rgdal - https://cran.r-project.org/web/packages/rgdal/index.html

`(library("gdalUtils", lib.loc="/homeappl/appl_taito/stat/R/R-3.5.0/lib64/R/library"))`

### Installing

Desktop: RStudio download, see https://rstudio.com/products/rstudio/download/.

## Running / Deployment

CSC - Taito (and Puhti): see https://research.csc.fi/-/r; srun and sbatch

CSC and Desktop: RStudio => Code => Run region => Run All 
- Be sure to change the Laz files path (=`LASPOLKU`), it is recursive.

By this script can calculate CHM, just comment out in veg_detection_method-module rows:
```
dtm = grid_terrain(las, algorithm = knnidw(k = 6L, p = 2), keep_lowest = FALSE)
las_norm <- lasnormalize(las, dtm)
```
and change row:
```
veg_1 <- grid_canopy(las_norm, res = resoluutio, pitfree(thr, edg))
```
to 
```
veg_1 <- grid_canopy(las, res = resoluutio, pitfree(thr, edg))
```


Example: Running the script in RStudio, where `LASPOLKU <- "/proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533/"`, prints in Console:
```
> source('~/Rstudio_scriptit/las2chm_raster_all_catalog.R', echo=TRUE)

[1] "Tiedostojen maara yhteensa: 16 kpl"
[1] "/homeappl/home/%username%/Downloads"

[1] "Tiedosto: /proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533//1/P5333A1.laz"
[1] "Tiedosto - koko polku: /proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533//1/P5333A1.laz"
[1] "Hakemisto: /wrk/%username%/P533/1/"
[1] "Tiedosto: P5333A1.laz"
[1] "Tiedosto: P5333A1"
[1] "  Rasteria ei ole olemassa! - luodaan tiedosto: /wrk/%username%/P533/1/P5331_veg_100_m.tif"
[1] "Menossa kierros  : 1/16 kpl"
[1] "/wrk/project_ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533/1/"
[1] "Hakemisto olemassa /wrk/project_ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533/1/"
[1] "Catalog polku: /wrk/project_ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533/1/"
[1] "output parametrit määritys OK "
[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 0" "- bbox: 0" "- bbox: 0" "- bbox: 0"
[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 668000"     "- bbox: 6954000"    "- bbox: 669009.99"  "- bbox: 6955009.99"
[1] " - las_norm laskettu"
[1] " - bbox"
[1] " - veg"
[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 668990"     "- bbox: 6954000"    "- bbox: 670009.99"  "- bbox: 6955009.99"
[1] " - las_norm laskettu"
[1] " - bbox"
[1] " - veg"
Processing [>---------------------------------------------------------]   1% (2/144) eta: 29m[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 669990"     "- bbox: 6954000"    "- bbox: 671009.99"  "- bbox: 6955009.99"
[1] " - las_norm laskettu"
[1] " - bbox"
[1] " - veg"
Processing [>---------------------------------------------------------]   2% (3/144) eta: 49m[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 670990"     "- bbox: 6954000"    "- bbox: 672009.99"  "- bbox: 6955009.99"
[1] " - las_norm laskettu"
[1] " - bbox"
[1] " - veg"
Processing [=>--------------------------------------------------------]   3% (4/144) eta:  1h[1] 
...
[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 677990"     "- bbox: 6964990"    "- bbox: 679009.99"  "- bbox: 6965999.99"
[1] " - las_norm laskettu"
[1] " - bbox"
[1] " - veg"
[1] "Alkaa...kasvillisuuden korkeus laskenta, resoluutio: 10"
[1] "- bbox: 678990"     "- bbox: 6964990"    "- bbox: 679999.99"  "- bbox: 6965999.99"
[1] " - las_norm laskettu"
[1] " - bbox"
[1] " - veg"
[1] "veg_merge OK "
[1] "Vegetation height valmis! "
[1] "Rasteriksi tallennus alkaa...:/wrk/%username%/P533/1/P5331_veg_10_m.tif"
[1] " => Rasteriksi muunnos OK! - tiedosto: /wrk/%username%/P533/1/P5331_veg_10_m.tif"
...
[1] "Tiedostojen maara yhteensa: 1 kpl  haku: *_veg_100_m.tif"
[1] "Virtuaalirasteriksi muunnos OK! - .vrt: /homeappl/home//%username%/Downloads///out_all.vrt"
[1] "Virtual to Raster tallennus alkaa...:/homeappl/home//%username%/Downloads//out_all_veg_10_m.tif"
[1] "Rasteriksi muunnos OK! - tiedosto: /homeappl/home//%username%/Downloads//out_all_veg_10_m.tif"
```

## Use of parameters

- `HOME`: home environment
- `WRK`: working environment
- `resoluutio` = output raster resolution
- `out_vrt_file` = name of the virtual raster
- `teema_haku` = name of the tiff rasters in the WRK-directory
- `teema` = name of the 'theme'

## Output file and temporary files

The final output raster (the virtual raster and the tiff raster) is stored to the directory which the variable `HOME` refers. The name of the final raster is specified in the variable `output_vrt_tiff` (paste from the variable `HOME`, the variable `out_vrt_file` and the variable `teema_haku`, which consists of ("_",teema,"_",resolution,"_m.tif"))
Add all the temporary rasters are stored to the directory which the variable `WRK` refers. In the CSC environment the data in the `WRK` directory will be deleted after 90 days.

## Usage and Citing

When used, the following citing should be mentioned: "We made use of geospatial
data/instructions/computing resources provided by the Open Geospatial
Information Infrastructure for Research (oGIIR,
urn:nbn:fi:research-infras-2016072513) funded by the Academy of Finland."



