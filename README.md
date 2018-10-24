# Interview scheduler

## Approach
This is a simple interview scheduler that attempts to find the arrangement of locations and dates which results in the most number of interviews attended.

This (naive) approach is based on random sampling without replacement. Namely:

1. Randomly select an interview date
2. Randomly select a location for that date
3. Drop this date and this program from the set of options
4. Continue until all the dates are exhausted
5. Do steps 1-4 however many times the user desires
6. Look through all of the results and only keep the runs which have the desired programs
7. Return the remaining runs which have the most interviews

## Requirements

This program accepts one to three arguments:

1. A csv file of programs and dates (with labeled headers). This is a required argument.
2. The number of times to search for a match. This is an optional argument.
3. A comma-separated string of programs (case-insensitive) that must be included in the schedule. This is an optional argument

## Running the program

You can run it from the command line as follows:

```{r}
Rscript schedule_interviews.R program_list.csv 100 "my_favorite_program, another_great_one"
```

The top schedules will be displayed in the console and saved as csv files. By default these files are saved in the current working directory.
