# Annotation of learner corpus data
# Master Language

# Set-up

#### Step 1. Update R
# Make sure you have an up-to-date version of R and R studio on your computer
# See here for instructions: https://rstudio-education.github.io/hopr/starting.html

#### Step 2. Install required packages####
# If you do not already have the following packages on your computer, please
# run the following lines to install them
install.packages("dplyr") # For easy data manipulation
install.packages("stringr") # A package for manipulating strings (character vectors)
install.packages ("spacyr") # A package for dependency annotation
install.packages ("caret") # A package for reliability testing

#### Step 3. Set up spaCy: First time ####
library(spacyr)
# In order to use the R Package 'spaCyr', you will also need to install a local version of the 
# python program 'spaCy' on your computer. You can do so using the following function:
spacy_install()
# Download the English language model (to be able to process English texts)
spacy_download_langmodel(model = "en_core_web_sm")
