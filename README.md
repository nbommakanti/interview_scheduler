# interview scheduler
This is a simple interview scheduler that attempts to find the arrangement of locations and dates which results in the most number of interviews attended.

It accepts one to three arguments.

1. A csv file of programs and dates (with labeled headers). This is a required argument.
2. The number of times to search for a match. This is an optional argument.
3. A comma-separated string of programs that must be included in the schedule. This is an optional argument


You can run it from the command line as follows:

```{r}
Rscript schedule_interviews.R program_list.csv 100 "my_favorite_program, another_great_one"
```
