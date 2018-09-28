# Simple interview scheduler
# Nikhil Bommakanti
# 9/28/18
# 
# This is a naive approach to finding an arrangement which maximizes the number of interviews.
# 
# The approach is based on random sampling without replacement. Namely:
# 1. Randomly select an interview date
# 2. Randomly select a location for that date
# 3. Drop this date and this program from the set of options
# 4. Continue until all the dates are exhausted
# 5. Do steps 1-4 however many times the user desires
# 6. Look through all of the results and only keep the runs which have the desired programs
# 7. Return the remaining runs which have the most interviews
# ---------

# Load the data.table package
# Install it if the user does not have it on his or her system
if (!require(data.table)) {
    install.packages("data.table")
}
if (!require(stringr)) {
    install.packages("stringr")
}
library(data.table, quietly = TRUE)
library(stringr, quietly = TRUE)

# Read command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Simple error checking
if (length(args) < 1) {
    stop("You must supply at least one argument")
}

# Extract arguments
file_to_read <- args[1]
if (!is.na(args[2])) {
    times <- args[2]
    cat("\nWe will try", times, "times to make a calendar from", file_to_read, "\n\n")
} else {
    times <- 1
    cat("\nWe will try to make a calendar from", file_to_read, "\n\n")
}
must_visit <- unlist(strsplit(args[3], split = ", "))
print(must_visit)

# Read file
options <- fread(file_to_read)

# Make schedule
make_schedule <- function(options) {
    # Save copy to be used in the loop
    options_left <- copy(options)
   
    # Shuffle dates
    dates_shuffled <- unique(options$date)
    shuffled_indices <- sample.int(n = length(dates_shuffled), replace = FALSE)
    dates_shuffled <- dates_shuffled[shuffled_indices]
    
    # Shuffle options
    shuffled_indices <- sample.int(n = nrow(options_left), replace = FALSE)
    options_left <- options_left[shuffled_indices]     
   
    # Initialize then run loop
    schedule <- vector("list", length(dates_shuffled))
    for (i in seq_along(dates_shuffled)) {
        # Get the first observation for this date
        # (we have already shuffled these options so there
        #  is no need to resample them)
        current_date <- dates_shuffled[[i]]
        schedule[[i]] <- options_left[date %in% current_date, program][1]
        
        # Drop this program and this date from options_left if we have made a selection
        if (!is.na(schedule[[i]])) {
            options_left <- options_left[ !(program %in% schedule[[i]] | date %in% current_date) ]
        }
    }
    schedule <- data.table(program = unlist(schedule), date = dates_shuffled)
    schedule
}

# Run however many times was specified
schedules <- vector("list", times)
for (i in 1:times) {
    cat("Executing run", i, "...\n")
    schedules[[i]] <- make_schedule(options)
}

# Extract best lists
# We will do this by combining everything into table, then selecting those with the most matches
schedules <- rbindlist(schedules, idcol = TRUE)

# Only keep those with all of the `must_visit` programs
if (!all(is.na(must_visit))) {
    # grepl, str_detect, etc. don't seem to work well with vectors
    # We will loop over each possibility in our `must_visit` vector,
    #  check if they are present, then build our `keep` vector accordingly
    # There is likely a better way to do this
    determine_if_keep <- function(program) {
        has_must_visit <- vector("logical", length(must_visit))
        for (i in seq_along(must_visit)) {
            has_must_visit[[i]] <- any(grepl(must_visit[[i]], program, ignore.case = TRUE))
        }
        has_must_visit <- all(has_must_visit)
        has_must_visit
    }
    schedules[, keep := determine_if_keep(program), by = .id]
    schedules <- schedules[keep == TRUE, .(.id, program, date)]
}

# End here if this leaves us with an empty table
if (nrow(schedules) == 0) {
    cat("\nUnable to find a schedule that matches the input parameters\n")
    quit()
}

# Determine the number of programs each schedule has scheduled
schedules[, total := sum(!is.na(program )), by = ".id"]

# Keep the top remaining schedules
schedules <- schedules[total == max(total)]

# For display, set missing values (NA) to an empty string ("")
schedules[is.na(program), program := ""]

# Get total number of possible interviews
num_possible <- length(unique(options$program))

# Output results
# Print separate tables if there are more than one best options
ids <- unique(schedules$.id)
for ( i in 1:length(ids) ) {
    data <- schedules[.id %in% ids[[i]]][order(date)]
    cat("\n\nThis schedule fits", 
        unique(data$total), "of", 
        num_possible, "interviews and includes",
        paste(must_visit, collapse = ", "), "\n")
    print(data[, .(program, date, total)])
    cat("\n\n")
    
    # Write to disk
    fwrite(data[, .(program, date)], file = paste0("./schedule", i, ".csv"))
}


