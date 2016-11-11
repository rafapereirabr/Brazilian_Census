# This code:
# > downloads 2000 Brazilian Census microdata from IBGE
# > unzip the microdata
# > reads .txt microdata into data frame
# > saves data sets as .csv files



# By, Rafael Pereira
# you can fund my contacts at www.urbandemographics.blogspot.com
# 11-Nov-2016, Oxford, UK
# R version:  RRO 3.2.2 (64 bits)


############################################################################
## ATTENTION: This is the only modification you have to do in this script, I hope ;)
setwd("R:/Dropbox/bases_de_dados/censo_demografico/censo_2000") # set working Directory
############################################################################




##################### Load packages ----------------------------------------

library(microdadosBrasil)
library(dicionariosIBGE)
library(magrittr) # using pipes %>%
library(data.table) # to manipulate data frames (fread is ultrafast for reading CSV files)
library(LaF)
library(readr) #fast read of fixed witdh files
library(readxl) # read excel spreadsheets
library(beepr)    # Beeps at the end of the command
library(dplyr)    # Beeps at the end of the command

options(scipen=999) # disable scientific notation


_____________________________________________________________________________________
######## Download Census DATA -----------------------------------------------------

# create subdirectories where we'll save files
  dir.create(file.path(".", "dados_txt2000"))
  dir.create(file.path(".", "dados_csv2000"))
  

  destfolder <- "./dados_txt2000/"
  UFlist <- c("AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO")
  ftppath <- "ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2000/Microdados/"
  tf <- tempfile()
  td <- tempdir()
  
  for (i in UFlist){
                    tf <- paste0(ftppath, i, ".zip")
                    td <- paste0("./dados_txt2000/", i, ".zip")
                    print(i)
                    download.file(tf, td, mode="wb")
                    }

# unzip all Files
  filenames <- list.files("./dados_txt2000", pattern=".zip", full.names=TRUE)
  lapply(filenames,unzip, exdir = "./dados_txt2000")

  
  
  # Using Mation's package
  # Download and Unzip Censo 2000
  # download_sourceData("CENSO", 2000, unzip = T)
  
_____________________________________________________________________________________
######## Download Census Documentation -----------------------------------------------------
  
  file_url <- "ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2000/Microdados/1_Documentacao_20160309.zip"
  download.file(file_url,"Documentacao.zip", mode="wb")
  unzip("Documentacao.zip", exdir="documentacao2000", junkpaths=T)



_____________________________________________________________________________________
######## Prepare Documentation files to read .txt -----------------------------------------------------
  
  # Open variables layout from Excel file
    dic_dom <- get_import_dictionary("CENSO", 2000, "domicilios") %>% setDT()
    dic_pes <- get_import_dictionary("CENSO", 2000, "pessoas") %>% setDT()
    

  
    
_____________________________________________________________________________________
### HOUSEHOLD Files   ----------------------------------------------------
    
##### UNCOMMENT THIS PART IF YOU ONLY WANT TO READ A SUBSET OF VARIABLES #####
# ## Select a subset of variables will be read from .txt files
# myvariblesDOM <- c( "V0102" # state
#                   , "V0103" # municipality
#                   , "V0104" # district
#                   , "V0300" # controle - household id
#                   , "V0400" # person order
#                   , "V1007"
#                   , "AREAP" # Sampling area - Area de ponderacao
#                   , "V1006" # urban x rural
#                   , "V7100" # Number of people in the household
#                   , "V7616" # total household income
#                   , "PESO_DOMIC"  # weight
#                   , "V7203" # dwellers density21
#                   , "V7204" # dwellers density2
#                   , "V7617" # household salaries
#                   )
#                   
# dic_dom <- dic_dom[var_name %in% myvariblesDOM] # filter documentation
                

# list with all Household files
  data_files  <- list.files(path="./dados_txt2000",
                            recursive=T,
                            pattern="Dom",
                            full.names=T)


# Create function to readem Household files
  readDOM <- function(f) {cat(f)
                          read_fwf(f,
                                   fwf_positions(start= dput(dic_dom[,int_pos]),
                                                 end= dput(dic_dom[,fin_pos]),
                                                 col_names = dput(dic_dom[,var_name])),
                                   progress = interactive())
                          }


# apply function to read national data into 'temp'
  temp <- rbindlist(lapply(data_files, readDOM))
  setDT(temp)

  
# Update decimals in the data
  var.decimals <- dic_dom[decimal_places > 0, ] # identify variables with decimals to update
  var.decimals <- var.decimals[, c("var_name","decimal_places"), with = FALSE]
  var <-  dput(var.decimals$var_name) # list of variables to update decimals

# Update decimals in the data
  for(j in seq_along(var)){
    set(temp, i=NULL, j=var[j], value=as.numeric(temp[[var[j]]])/10^var.decimals[, decimal_places][j])
    }

# Save national data set as a '.csv' file
  #fwrite(temp, file.path="./dados_csv2000/censo2000_BRdom.csv")
  write_csv(temp, path="./dados_csv2000/censo2000_BRdom.csv")
  
  rm(temp,readDOM); gc()
  
  proc.time() - ptm   # Stop the clock







_____________________________________________________________________________________
### INDIVIDUALS Files  (__ minutes) ----------------------------------------------------
    # readr each .txt files and save it appending to one single data set
    # not as fast
    # not memory intensive for big data sets

##### UNCOMMENT THIS PART IF YOU ONLY WANT TO READ A SUBSET OF VARIABLES #####
# ## Select a subset of variables will be read from .txt files
# myvariblesPES <- c( "V0102" # state
#                     , "V0103" # municipality
#                     , "V0104" # district
#                     , "V0300" # controle - household id
#                     , "V0400" # person order
#                     , "V1007"
#                     , "V0401" # sex
#                     , "V4752" # Age
#                     , "V0408" # race
#                     , "V4614" # total income
#                     , "AREAP" # Sampling area - Area de ponderacao
#                     , "V1006" # urban x rural
#                     , "PES_PESSOA"  # weight
#                     , "V4514"
#                     , "V4524"
#                     , "V4526" 
#                     , "V4615"
#                     )
# dic_pes <- dic_pes[var_name %in% myvariblesPES] # filter documentation
  
  
  
data_files  <- list.files(path="./dados_txt2000",
                          recursive=T,
                          pattern="Pes",
                          full.names=T)


# Prepare documentation to Update decimals in the data
  var.decimals <- dic_pes[decimal_places > 0, ] # identify variables with decimals to update
  var.decimals <- var.decimals[, c("var_name","decimal_places"), with = FALSE]
  var <-  dput(var.decimals$var_name) # list of variables to update decimals
  

ptm <- proc.time()  # Start the clock!
for (i in 1:length(data_files)){
  
  # select state file
    file <- data_files[i]
  
  # read data into temp
  temp <-   read_fwf(file,
                     fwf_positions(start= dput(dic_pes[,int_pos]),
                                   end= dput(dic_pes[,fin_pos]),
                                   col_names = dput(dic_pes[,var_name])),
                     progress = interactive())
  setDT(temp) # set as Data Table 
  

  
  
  # Update decimals in the data
  for(j in seq_along(var)){
    set(temp, i=NULL, j=var[j], value=as.numeric(temp[[var[j]]])/10^var.decimals[, decimal_places][j])
  }
  
  cat("saving", i, "out of", length(data_files), file) # update status of the loop
  
  # Save national data set as a '.csv' file
  #fwrite(temp, file="./dados_csv2000/censo2000_BRpes.csv", append = T)
  write_csv(temp, path="./dados_csv2000/censo2000_BRpes.csv", append = T)
  
 # rm(temp); gc()
}
proc.time() - ptm   # Stop the clock


beep()
