# Brazilian Census 2010
##This script will help you Download the 2010 Brazilian Census data sets and save them as .csv files. 

**If you are familiar with SQL and Monetab**, you have probably heard about the [terrific job that Anthony Damico and Djalma Pessoa](http://www.asdfree.com/2014/05/analyze-censo-demografico-no-brasil.html) have put together to write a code to download and analyze the 2010 Brazilian Census data.


However, if you are looking for a pure `R` solution AND you want a fast solution, you might find this code useful.

- The script is written taking advantage of `readr` capabilities, a [new R package](http://blog.rstudio.org/2015/04/09/readr-0-1-0/) that is extremelly fast to read fixed width text files. 
- Once the text files are stored in your computer, it doesn't take long to save the national data sets. It took me respectively 13 minutes and 43 minutes to save the national data sets of households and individuals records. The most time-consuming part is actually saving the files.


**step-by-step. This scriptt:**
- Downloads 2010 Brazilian Census microdata from IBGE's website
- Unizip the microdata of all state files
- Creates a documentation file to read the fixed width text files
- Reads and binds text files into single data frame with records of the whole country
- Saves data sets as .csv files.

Apart from some typos you will find here and there, the code can be much improved. All feedback and colaboration is welcomed !

