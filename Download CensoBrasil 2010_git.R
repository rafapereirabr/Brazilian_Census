# This code:
# > downloads 2010 Brazilian Census microdata from IBGE
# > unzip the microdata
# > reads .txt microdata into data frame
# > saves data sets as .csv files



# By, Rafael Pereira
# you can fund my contacts at https://sites.google.com/site/rafaelhenriquemoraespereira/
# 17-June-2016, Oxford, UK
# R version:  RRO 3.2.2 (64 bits)


############################################################################
## ATTENTION: This is the only modification you have to do in this script, I hope ;)
  setwd("R:/Bases-de-Dados/Censo Demografico/Censo 2010") # set working Directory
############################################################################




##################### Load packages ----------------------------------------

# install devel version 1.9.7 of data.table
# GUIDELINES here : https://github.com/Rdatatable/data.table/wiki/Installation
install.packages("data.table", type = "source", repos = "http://Rdatatable.github.io/data.table")

library(data.table) # to manipulate data frames (fread and fwrite are ultrafast for reading and writing CSV files)
library(readr) #fast read of fixed witdh files
library(readxl) # read excel spreadsheets
library(beepr)    # Beeps at the end of the command
options(scipen=999) # disable scientific notation


_____________________________________________________________________________________
######## Download Census DATA -----------------------------------------------------

# create subdirectories where we'll save files
  dir.create(file.path(".", "dados_txt2010"))
  dir.create(file.path(".", "dados_csv2010"))
  

  destfolder <- "./dados_txt2010/"
  UFlist <- c("AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RJ","RN","RO","RR","RS","SC","SE","SP1","SP2_RM","TO")
  ftppath <- "ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2010/Resultados_Gerais_da_Amostra/Microdados/"
  tf <- tempfile()
  td <- tempdir()
  
  for (i in UFlist){
                    tf <- paste0(ftppath, i, ".zip")
                    td <- paste0("./dados_txt2010/", i, ".zip")
                    print(i)
                    download.file(tf, td, mode="wb")
                    }

# unzip all Files
  filenames <- list.files("./dados_txt2010", pattern=".zip", full.names=TRUE)
  lapply(filenames,unzip, exdir = "./dados_txt2010")

_____________________________________________________________________________________
######## Download Census Documentation -----------------------------------------------------
  
  file_url <- "ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2010/Resultados_Gerais_da_Amostra/Microdados/Documentacao.zip"
  download.file(file_url,"Documentacao.zip", mode="wb")
  unzip("Documentacao.zip", exdir="documentacao2010", junkpaths=T)



_____________________________________________________________________________________
######## Prepare Documentation files to read .txt -----------------------------------------------------
  
  # Open variables layout from Excel file
    dic_dom <- read_excel("./documentacao2010/Layout_microdados_Amostra.xls", sheet =1, skip = 1)
    dic_pes <- read_excel("./documentacao2010/Layout_microdados_Amostra.xls", sheet =2, skip = 1)
    dic_mor <- read_excel("./documentacao2010/Layout_microdados_Amostra.xls", sheet =4, skip = 1)
    
  
  # convert to data table
    setDT(dic_dom)
    setDT(dic_pes)
    setDT(dic_mor)
  
# compute width of each variable
  
  # Create function to compute width
    computeWidth <- function(dataset){dataset[is.na(DEC), DEC := 0] # Convert NA to 0
      dataset[, width := INT + DEC]      # create width variable 
      setnames(dataset,colnames(dataset)[which(colnames(dataset) == "POSIÇÃO INICIAL")],"pos.ini") # change name of variable initial position
      setnames(dataset,colnames(dataset)[which(colnames(dataset) == "POSIÇÃO FINAL")],"pos.fin") # change name of variable final position
      }
  
  # Apply function
    lapply(list(dic_dom,dic_pes,dic_mor), computeWidth)
  

### In case you need to work with a smaller subset of the data (e.g. because of memory limits),   
### I would suggest you read from the .txt file only those variables you want
    # myvariblesPES <- c("V0001", "V6400", "V0011", "V0300", "V0601", "V6036", "V0606", "V0010") # list of variables you want
    # dic_pes <- dic_pes[VAR %in% myvariblesPES] # filter documentation, continue the code 

### Alternatively, you could save the whole data set file as .csv and load only the variables you want
     # individuals <- fread("pesBrasil.csv", select= myvariblesPES)

_____________________________________________________________________________________
### MORTALITY Files (5 seconds) -----------------------------------------------------
    # Append ALL .txt files
    # Readr national .txt file


ptm <- proc.time()  # Start the clock!

# list with all Household files
  data_files  <- list.files(path="./dados_txt2010",
                            recursive=T,
                            pattern="Mor",
                            full.names=T)


# Create function to readem Household files
  readMOR <- function(f) {cat(f)
                          read_fwf(f,
                                   fwf_positions(dput(dic_mor[,pos.ini]),
                                                 dput(dic_mor[,pos.fin]),
                                                 col_names = dput(dic_mor[,VAR])),
                                   progress = interactive())
                          }


# apply function to read national data into 'temp'
  temp <- rbindlist(lapply(data_files, readMOR))
  setDT(temp)

# Update decimals in the data
  var.decimals <- dic_mor[DEC > 0, ] # identify variables with decimals to update
  var.decimals <- var.decimals[, c("VAR","DEC"), with = FALSE]
  var <-  dput(var.decimals$VAR) # list of variables to update decimals

# Update decimals in the data
  for(j in seq_along(var)){
    set(temp, i=NULL, j=var[j], value=as.numeric(temp[[var[j]]])/10^var.decimals[, DEC][j])
    }

# Save national data set as a '.csv' file
  fwrite(temp, file.path="./dados_csv2010/censo2010_BRmor.csv")
  rm(temp,readMOR); gc()
  
  proc.time() - ptm   # Stop the clock



_____________________________________________________________________________________
### HOUSEHOLD Files  (13 minutes) ----------------------------------------------------
    # readr and bind ALL .txt files one by one
    # still quite fast
    # memory intensive for big data sets

ptm <- proc.time()  # Start the clock!

# list with all Household files
  data_files  <- list.files(path="./dados_txt2010",
                            recursive=T,
                            pattern="Dom",
                            full.names=T)


# Create function to readem Household files
  readDOM <- function(f) {cat(f)
                          read_fwf(f,
                                   fwf_positions(dput(dic_dom[,pos.ini]),
                                                 dput(dic_dom[,pos.fin]),
                                                 col_names = dput(dic_dom[,VAR])),
                                                 progress = interactive())
                                                 }


# apply function to read national data into 'temp'
  temp <- rbindlist(lapply(data_files, readDOM))
  setDT(temp)

# Update decimals in the data
  var.decimals <- dic_dom[DEC > 0, ] # identify variables with decimals to update
  var.decimals <- var.decimals[, c("VAR","DEC"), with = FALSE]
  var <-  dput(var.decimals$VAR) # list of variables to update decimals

# Update decimals in the data
  for(j in seq_along(var)){
    set(temp, i=NULL, j=var[j], value=as.numeric(temp[[var[j]]])/10^var.decimals[, DEC][j])
    }

# Save national data set as a '.csv' file
  fwrite(temp, file.path="./dados_csv2010/censo2010_BRdom.csv")
  rm(temp,readDOM); gc()

proc.time() - ptm   # Stop the clock



_____________________________________________________________________________________
### INDIVIDUALS Files  (41 minutes) ----------------------------------------------------
    # readr each .txt files and save it appending to one single data set
    # not as fast
    # not memory intensive for big data sets

data_files  <- list.files(path="./dados_txt2010",
                          recursive=T,
                          pattern="Pes",
                          full.names=T)


# Prepare documentation to Update decimals in the data
  var.decimals <- dic_pes[DEC > 0, ] # identify variables with decimals to update
  var.decimals <- var.decimals[, c("VAR","DEC"), with = FALSE]
  var <-  dput(var.decimals$VAR) # list of variables to update decimals
  
ptm <- proc.time()  # Start the clock!
for (i in 1:length(data_files)){
  
  # select state file
    file <- data_files[i]
  
  # read data into temp
  temp <-   read_fwf(file,
                     fwf_positions(dput(dic_pes[,pos.ini]),
                                   dput(dic_pes[,pos.fin]),
                                   col_names = dput(dic_pes[,VAR])),
                     progress = interactive())
  setDT(temp) # set as Data Table 
  
  
  
  # Update decimals in the data
  for(j in seq_along(var)){
    set(temp, i=NULL, j=var[j], value=as.numeric(temp[[var[j]]])/10^var.decimals[, DEC][j])
  }
  
  cat("saving", i, "out of", length(data_files), file) # update status of the loop
  
  # Save national data set as a '.csv' file
  fwrite(temp, file.path="./dados_csv2010/censo2010_BRpes.csv", append = T)
  rm(temp); gc()
}
proc.time() - ptm   # Stop the clock

beep()

