# Annotation of learner corpus data
# Master Language

# Activity 1: POS-tagging

#### Step 1. Install required packages and load them ####
# If you do not already have the following packages on your computer, please
# run the following lines to install them
install.packages("dplyr") # For easy data manipulation
install.packages ("spacyr") # A package for dependency annotation
install.packages("stringr") # A package for manipulating strings (character vectors)
library(dplyr); library(spacyr); library(stringr)

#### Step 2. Set up spaCy: First time ####
# Install spaCy on your computer
spacy_install()
# Note: you can also install spaCy in a virtual environment using `spacy_install_virtualenv()`
# Download the English language model
spacy_download_langmodel(model = "en_core_web_sm")

#### Step 3. Initiate spaCy: At the beginning of a session ####
# Install spaCy on your computer
spacy_initialize(model = "en_core_web_sm")

#### Step 4. Pre-processing ####

##### Load in the ICLE corpus files as a data frame #####
icle_files <- list.files("data/icle_texts/", full.names = TRUE)
icle_corpus <- data.frame(
  # Set the first column of data frame as the file names
  file = sapply(icle_files, basename),
  # Read in each of the text files using the scan() function
  # Paste the separate paragraphs in each text file together using the paste0() function
  text = sapply(icle_files, function(x) paste0(scan(x, what = character(), sep = "\n"), collapse = " "))
)

##### Inspect the texts ####
# Check whether the data frame is okay 
# Note: the glimpse() function is similar to str() in base R but the output
# is easier to read 
glimpse(icle_corpus)

# Print the text for the file BRFF1065.txt. 
icle_corpus$text[icle_corpus$file == "BRFF1065.txt"]

# Print the text for the file BRFF1069.txt. 
icle_corpus$text[icle_corpus$file == "BRFF1069.txt"]

###### Question 1. What do you notice about these texts? #####
# What pre-processing steps (if any) might be necessary before 
# using automatic annotation tools?

# Get a list of all of the characters in the corpus to check if there are
# special characters that need to be dealt with
sort(unique(unlist(str_split(icle_corpus$text, pattern = ""))))

###### Question 2. What 'special characters' do you notice? #####

##### Clean the texts ####
# Write a function to clean the texts
clean_texts <- function(text){
  text %>%
    # Remove the file header
    str_remove_all("<ICLE-BR-FF-\\d{4}\\.\\d>\\s+") %>%
    # Remove all instances of <R
    str_remove_all("<R") %>%
    # Remove all instances of <* and *
    str_remove_all("<\\*\\s+(\\*\\s+)?") %>%
    # Only one space between words
    str_replace_all("\\s+", " ") %>%
    # Remove white space at beginning and end of the text
    trimws()
}
# Test the function on the file BRFF1065.txt
clean_texts(icle_corpus$text[icle_corpus$file == "BRFF1065.txt"])
# Test the function on the file BRFF1069.txt
clean_texts(icle_corpus$text[icle_corpus$file == "BRFF1069.txt"])
# Make a new column in your data frame and apply the cleaning function to all
# the texts
icle_corpus <- icle_corpus %>%
  mutate(text_clean = clean_texts(text))
# Save the icle_corpus file for later
write.csv(icle_corpus, file = "data/icle_corpus.csv", row.names = FALSE)

# Check whether any special characters remain 
sort(unique(unlist(str_split(icle_corpus$text_clean, pattern = ""))))

##### POS-tag and lemmatize the texts ####

# First test the tagger on a single file (BRFF1065.txt)
BRFF1065 <- icle_corpus$text_clean[icle_corpus$file == "BRFF1065.txt"]

BRFF1065_tagged <- spacy_parse(BRFF1065)


# Note: if you are not able to run spaCy for some reason, you can simply
# load the `BRFF1065_tagged.rds` object 
BRFF1065_tagged <- readRDS("data/BRFF1065_tagged.rds")


# Call head() and glimpse() to see the different things that are contained within the dataframe
head(BRFF1065_tagged)
glimpse(BRFF1065_tagged)

###### Question 3. How many 'words' and 'sentences' does this text contain? #####

# Now that the POS tags are stored in a dataframe, we can use functions from the 'dplyr' package to analyze it.  

# For example, we can can count the number of tokens and types
BRFF1065_tagged %>% 
  # We will use filter() to exclude punctuation, sentence boundaries and symbols from our count of tokens
  filter(! pos %in% c("PUNCT", "SENT", "SYM")) %>% 
  # We can then use summarize() count to count tokens (number of rows) and types (number of distinct values in under the column 'token')
  summarize(tokens = n(), 
            types = n_distinct(token))

# To count the number of sentences all you need to do is find out what the maximum sentence id is
max(BRFF1065_tagged$sentence_id)

###### Question 4. What is the average sentence length? #####

BRFF1065_tagged %>% 
  # Again, we will exclude punctuation, sentence boundaries and symbols from our count of tokens
  filter(! pos %in% c("PUNCT", "SENT", "SYM")) %>% 
  # Group the data frame by sentence
  group_by(sentence_id) %>%
  # Count how many tokens there are in each sentence 
  summarize(tokens = n()) %>% 
  # Average across all sentences
  summarize(asl = mean(tokens))


###### Question 5. How many adjectives (ADJ) are there?#####

BRFF1065_tagged %>% 
  # The count() function is a shortcut so that you don't need to call both group_by() and summarize(n = n())
  count(pos) %>% 
  # We can then sort the resulting data frame by descending frequencies
  arrange(desc(n))


###### Question 6. How many adjective + noun collocations are there? #####


# Note: if you want a 'horizontal' version, you can combine the tokens and tags with
# the paste function 
BRFF1065_tagged_horizontal <- paste(BRFF1065_tagged$token,BRFF1065_tagged$pos,  sep = "_", collapse = " ")
BRFF1065_tagged_horizontal

# This may be useful for searching for specific combinations.
# For example: We can extract all adjective + noun collocations in the following way
str_extract_all(BRFF1065_tagged_horizontal, "[^(_ )]+_ADJ [^_]+_NOUN?")



###### Question 7. What are the 20 most frequent verb lemmas in the entire corpus?#####

# Now we will apply spaCy to the entire corpus
icle_tagged <- icle_corpus %>% 
  # spaCy needs the data frame to follow the TIF standard 
  # (which means that the variables need to be named 'doc_id' and 'text')
  select(doc_id = file, text = text_clean) %>% 
  spacy_parse()

# Then it's just a matter of counting the verb lemmas
icle_tagged %>% 
  # filtering only verbs
  filter(pos == "VERB") %>% 
  # group each verb by its lemma
  group_by(lemma) %>% 
  # summarize the number of tokens per each lemma
  summarize(n = n(), 
            # we will also count how many texts each lemma occurs in to see the dispersion as well
            n_texts = n_distinct(doc_id)) %>% 
  # arrange in decreasing frequency
  arrange(desc(n)) %>% 
  # show only the top 20
  head(20)


# Note: if you are not able to run TreeTagger, you can simply
# load the `icle_tagged.rds` object 
icle_tagged <- readRDS("data/icle_tagged.rds")

# spaCy can use a lot of memory in the background, so it's a good idea to terminate 
# it when you are finished 
spacy_finalize()
