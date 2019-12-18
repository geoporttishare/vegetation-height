# ./Rstudio_scriptit/las2chm_raster_all.R
# 
# lidar aineistojen luku, kasvillisuuden korkeuden teko (cmh-dtm) ja muunnos rasteriksi
#
# SYKE/TK/MH 03.07.2019, päivitys 16.12.2019

library(lidR)
#
library(rgdal)
#library(installr)
# library("gdalUtils", lib.loc="/homeappl/appl_taito/stat/R/R-3.5.0/lib64/R/library")
# tulee laittaa paalle Packages 
gdal_setInstallation()

# aika
t <- Sys.time()
aika_str <- strftime(t,"%Y%m%d%H%M%S")

# parameters
#
# resoluutio
resoluutio = 10
# teema
teema = "veg"
# tiff tiedostot talletuvat teema haku loppunimella 
#"_",teema,"_",resoluutio,"_m.tif"
teema_haku = paste0("_",teema,"_",resoluutio,"_m.tif")
teema_pattern = paste0("*_",teema,"_",resoluutio,"_m.tif")
# output - lopullinen alkunimi
out_vrt_file = paste0(teema,"_out_all")

#
full.names=TRUE

# whoami
username <- system("whoami", intern=TRUE)

# 
# /wrk/ + username
TEMP = paste0("/tmp/",username)
# WRK
WRK = paste0("/wrk/",username)
#HOME 
HOME = paste0("/homeappl/home//",username,"/Downloads//")

# hakemisto, josta laz-tiedostot luetaan
# voi olla 
# joko yksittäinen hakemisto, esim. "/proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533/"
# tai kokonainen hakemistorakenne, esim. "/proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/"
# tai "/proj/ogiir-csc/mml/laserkeilaus/2008_latest/"
# LASPOLKU
LASPOLKU <- "/proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/N544/"
LASPOLKU <- "/proj/ogiir-csc/mml/laserkeilaus/2008_latest/2018/P533/"

setwd(HOME)

veg_detection_method <- function(cluster, resoluutio)
{
  # lasketaan kasvillisuuden korkeus - toimii 
  #
  print (paste0("Alkaa...kasvillisuuden korkeus laskenta, resoluutio: ", resoluutio))

  # The cluster argument is a LAScluster object. The user does not need to know how it works.
  # readLAS will load the region of interest (chunk) with a buffer around it, taking advantage of
  # point cloud indexation if possible. The filter and select options are propagated automatically
  las <- readLAS(cluster)
  
  # Negation of data is also available (all except intensity and angle)
  # las = readLAS(LASfile, select = "* -i -a")
  print (paste0("- bbox: ", las@bbox))
  
  if (is.empty(las)) return(NULL)
  # use default values
  # dtm = maanpinnan korkeusmalli
  #
  dtm = grid_terrain(las, algorithm = knnidw(k = 6L, p = 2), keep_lowest = FALSE)
  # ja sen normalisointi
  las_norm <- lasnormalize(las, dtm)
  
  # if (is.empty(las_norm)) return(NULL)
  # 
  print (" - las_norm laskettu")

  # Khosravipour et al. pitfree algorithm
  # use default values
  #
  thr <- c(0,2,5,10,15)
  edg <- c(0, 1.5)
  # lasketaan kasvillisuuden korkeus, kaytetaan normalisointua korkeusmallia (= maanpinta), jolloin
  # kasvillisuuden korkedet on maanpinnasta laskettuja
  #
  veg_1 <- grid_canopy(las_norm, res = resoluutio, pitfree(thr, edg))
  
  # mukaan vain extentin alue lopulliseen rasteriin
  #
  bbox <- raster::extent(cluster)
  print (" - bbox")
  veg <- raster::crop(veg_1, bbox)
  #
  print(" - veg")
  # crs(chm) <- CRS('+init=EPSG:3067')
  # error ?
  # crs(chm) <- CRSargs(CRS("+init=EPSG:3067"))
  # Error in CRS("+init=EPSG:3067") : no system list, errno: 2
  # crs(chm) <- "+init=epsg:3067 +proj=utm +zone=35 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
  # => OK

  #
  return(veg)
}

# luuppi
files <- list.files(path=LASPOLKU, pattern="*.laz", full.names=TRUE, recursive=TRUE)
maara = length(files)
print(paste0("Tiedostojen maara yhteensa: ",paste0(maara," kpl")))

kier = 0
print (getwd())
# loop starts
#
for (file in files){
  name <- file
  # 
  print (paste0("Tiedosto: ",name))
  print (paste0("Tiedosto - koko polku: ",name))
  #
  hak_strings =  strsplit(name, "/")[[1]]
  #
  m = length(hak_strings)
  # 
  hakemisto_1 = hak_strings[m-1]
  hakemisto_2 = hak_strings[m-2]
  if (hakemisto_2 == "") {
    hakemisto_2 = hak_strings[m-3]    
  }
  
  wrk_hakemisto_1 = paste0(WRK, "/", hakemisto_2, "/", hakemisto_1, "/")
  filename_in_wrk_hakemisto_1 = paste0(hakemisto_2, hakemisto_1)
  
  print (paste0("Hakemisto: ", wrk_hakemisto_1))
  
  wrk_hakemisto_2 = paste0(WRK, "/", hakemisto_2, "/")
  if (!dir.exists(wrk_hakemisto_2)){
    # mkdir
    dir.create(wrk_hakemisto_2, showWarnings = TRUE, recursive = FALSE, mode = "0777")
    print (paste0("Hakemisto: ", wrk_hakemisto_2, "luotu!!!"))
  }
  if (!dir.exists(wrk_hakemisto_1)){
    # mkdir
    dir.create(wrk_hakemisto_1, showWarnings = TRUE, recursive = FALSE, mode = "0777")
    print (paste0("Hakemisto: ", wrk_hakemisto_1, " luotu!!!"))
  }
  
  basename <- basename(name)
  print (paste0("Tiedosto: ",basename))
  basename_noext<- tools::file_path_sans_ext(basename(name))
  print (paste0("Tiedosto: ",basename_noext))
  # 
  LASFILE <- basename_noext # 
  # LASFILE_FULL
  LASFILE_FULL = name
  
  # output tiff
  # tallennus wrk_hakemisto_1:oon
  # 
  output_tiff = paste0(wrk_hakemisto_1,filename_in_wrk_hakemisto_1,"_",teema,"_",resoluutio,"_m.tif") 
  
  # file exists rstudio
  # one raster by path
  # example all the files in directory /1/P533 are stored to the same file named P5331
  # and all the files in directory /2/P533 are stored to the same file named P5332
  # Tassa vahan turhaa luupittaa kaikkia hakemiston tiedostoja, kun ensimmaisen 
  # kohdalla tehdaan koko hakemistosta valiaikainen rasteri, eli hiukna kehitettavaa
  # ...17.12.2019 by MH
  #
  if(!file.exists(output_tiff)){  

    print (paste0("  Rasteria ei ole olemassa! - luodaan tiedosto: ", output_tiff))
    kier = kier + 1
    
    msg = paste0("Menossa kierros  : ", kier, "/",maara," kpl")
    print (msg)
    
    # laz-files path
    polku = paste(normalizePath(dirname(LASFILE_FULL)), fsep = .Platform$file.sep,  sep = "")
    
    # print(normalizePath(dirname(LASFILE_FULL))  )
    print(paste(normalizePath(dirname(LASFILE_FULL)), fsep = .Platform$file.sep,  sep = "")) 
    
    # polku olemassa?
    #
    if (dir.exists(polku)) {
      print(paste0("Hakemisto olemassa ", polku))
    } else {
      print(paste0("Hakemistoa ei ole olemassa ", polku))
      stop(" ei jatketa")
    }
    
    print(paste0("Catalog polku: ", polku))
    
    # if (is.empty(las)) return(NULL)
    
    # catalog
    project <- catalog(polku)
    
    # 3. Set some catalog options.
    # 
    # Displays a progress estimate.
    opt_progress(project) <- TRUE
    opt_chunk_buffer(project) <- 10
    opt_cores(project) <- 4L
    # 
    # virhetilanne joissakin datoissa
    # Error in grid_terrain.LAS(las, algorithm = knnidw(k = 6L, p = 2), keep_lowest = FALSE) : 
    #  No ground points found. Impossible to compute a DTM.
    
    # chunk_size arvon kasvatus
    opt_chunk_size(project) <- 1000
    # 
    opt_laz_compression(project) <- TRUE
    # -drop_z_below 0
    opt_filter(project) <- "-drop_z_below 0"
    opt <- list(need_buffer = TRUE) # catalog_apply will throw an error if buffer = 0
    print("output parametrit määritys OK ")
    
    # create vegetation height
    #
    output_veg <- catalog_apply(project, veg_detection_method, resoluutio, .options = opt)
    
    # merge
    #
    veg_merge <- do.call(raster::merge, output_veg)
    # plot(output, col = height.colors(50))
    
    #
    print("veg_merge OK ")
    
    # 
    print ("Vegetation height valmis! ")
    
    if (require(rgdal)){
      #
      # crs(chm) <- CRS('+init=EPSG:3067')
      #
      # save to raster
      # one raster by path
      #
      print (paste0("Rasteriksi tallennus alkaa...:",output_tiff))
      #
      rf <- writeRaster(veg_merge,filename=output_tiff,format="GTiff", overwrite=TRUE)
      #
      print (paste0(" => Rasteriksi muunnos OK! - tiedosto: ", output_tiff))
    }
  } 
  else {
    print (paste0("  Rasteri on jo olemassa! - tiedosto: ", output_tiff))
  }
}

#
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))

# list raster files
tiff_files <- list.files(path=WRK, pattern=teema_pattern, full.names=TRUE, recursive=TRUE)

maara = length(tiff_files)
print(paste0("Tiedostojen maara yhteensa: ",paste0(maara," kpl  haku: ", teema_pattern)))

if (maara > 0){
  if(valid_install)
  {
    #
    # output virtual raster
    #
    out_vrt_veg <- file.path(HOME, paste0(out_vrt_file,".vrt"))
    
    # tiedostot listattuna
    # 
    gdalUtils::gdalbuildvrt(gdalfile = c(tiff_files), output.vrt = out_vrt_veg , overwrite = TRUE)
    
    #
    print (paste0("Virtuaalirasteriksi muunnos OK! - .vrt: ", out_vrt_veg))

    #
    if (require(rgdal)){
      #
      # crs(chm) <- CRS('+init=EPSG:3067')
      #
      if(file.exists(out_vrt_veg)){  
        # lopullinen rasteri virtuaalirasterista
        # hakemistoon HOME, rastert luetaan teema_haku maarityksista
        # teema_haku = "_",teema,"_",resoluutio,"_m.tif"
        # 
        output_vrt_tiff = paste0(HOME,out_vrt_file,teema_haku) 
        
        print (paste0("Virtual to Raster tallennus alkaa...:",output_vrt_tiff))
        
        #  
        gdal_translate(out_vrt_veg,output_vrt_tiff)
        #
        print (paste0("Rasteriksi muunnos OK! - tiedosto: ", output_vrt_tiff))
      }
    }
  }
}
# warnings()
#
# Invalid file: the header states the file contains 9549745 returns numbered '1' but 14679941 were found.
#
# mahdollinen ratkaisu: https://www.cs.unc.edu/~isenburg/lastools/download/lasinfo_README.txt
# lasinfo -i *.las -repair
