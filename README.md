*Update on July 2018 :*

My colleague at Ipea (Lucas Mation) has created an `R` package to download and access microdata from various surveys in Brazil, including the population census. The package is called [microdadosBrasil](https://github.com/lucasmation/microdadosBrasil/) and it incorporates all of the good parts this repository and it goes beyond it. Hence I've decided to stop updating this repository and I recommend people to use microdadosBrasil.


# Brazilian Census 2000 and 2010
##This script will help you Download the 2000 and 2010 Brazilian Census datasets and save them as .csv files. 

**If you are familiar with SQL and Monetab**, you have probably heard about the [terrific job that Anthony Damico and Djalma Pessoa](http://www.asdfree.com/2014/05/analyze-censo-demografico-no-brasil.html) have put together to write a code to download and analyze  Brazilian Census data.


However, if you are looking for a pure `R` solution AND you want a fast solution, you might find this code useful.

- The script harnesses the capabilities of `read_fwf{readr}` and `fwrite{data.table}`, which make the tasks of reading fixed width text files and saving .csv files extremely fast. 
- Once the text files are stored in your computer, it doesn't take long to save the national data sets in `.csv` format. It took me respectively 2 minutes and 12 minutes to save the national data sets of households and individuals records.


**step-by-step. These scripts:**
- Download 2000 / 2010 Brazilian Census microdata from IBGE's website
- Unizip the microdata of all state files
- Create a documentation file to read the fixed width text files
- Reads and binds text files into single data frame with records of the whole country
- Saves data sets as .csv files.

Apart from some typos you will find here and there, the code can be much improved. All feedback and colaboration is welcomed !


ps. This script uses `fwrite`, which is still in the [devel. version 1.9.7](https://github.com/Rdatatable/data.table/wiki) of `data.table` 
