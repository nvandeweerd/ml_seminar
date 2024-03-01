

source("https://git.io/xaringan2pdf")

file <- "Slides/2023-24_B03/lecture_01_introduction"

rmarkdown::render(paste0(file, ".Rmd"), output_file = paste0(stringr::str_remove(file, "[^/]+/"), ".html"))


xaringan_to_pdf(paste0(file, ".html"), include_partial_slides = FALSE)

pagedown::chrome_print(paste0(file, ".html"), output = paste0(file, ".pdf"), timeout = 60)

