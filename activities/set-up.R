## Preparation for Master Language Seminar

#### Step 1. Install required packages and load them ####
# If you do not already have the following packages on your computer, please
# run the following lines to install them
install.packages("dplyr") # For easy data manipulation
install.packages("stringr") # A package for manipulating strings (character vectors)
install.packages ("spacyr") # A package for dependency annotation
install.packages ("caret") # A package for reliability testing


#### Step 2. Set up spaCy: First time ####
# If you have not used spaCy before, then you will need to install it on your computer
spacy_install()
# Note: you can also install spaCy in a virtual environment using `spacy_install_virtualenv()`
# Download the English language model
spacy_download_langmodel(model = "en_core_web_sm")