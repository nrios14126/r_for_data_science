
#### Chapter 3: Data Transformation with dplyr ####################################################

# Visualization is an important tool for insight generation, but it's rare that you'll get the data 
# in exactly the right form you need. Often, you'll need to create some new variables or summaries, 
# or you'll just want to rename the variables or reorder the observations. This can all be done via 
# dplyr.

library(nycflights13)
library(tidyverse)

# Take note that there are conflict messages when you load dplyr/tidyverse. It tells you that dplyr 
# overwrites some functions in base R. If you want to use the base versions of these functions, 
# you'll need to use their full names: stats::filter() and stats::lag().

# To explore the basic data manipulation of dplyr, we'll use the following data set:
nycflights13::flights

# To see the whole dataset, you can run View(flights), which will open the dataset in the RStudio 
# viewer: 
View(flights)

# The above prints differently because it's a tibble, which are data frames but slightly tweaked to 
# work better in the tidyverse. You may have also noticed the row of <letters> under the column 
# names. These describe the type of each variable:

# int: integers
# dbl: doubles, or real numbers
# chr: character vectors, or strings
# dttm: date-times
# lgl: logical vectors, or booleans
# fctr: factors, which R uses to represent categorical variables
# date: dates, no time

# There are five key dplyr functions that solve the vast majority of your data-manipulation 
# challenges:

# 1. Pick observations by their values: filter()
# 2. Reorder the rows: arrange()
# 3. Pick variables by their names: select()
# 4. Create new variables with functions of existing variables: mutate()
# 5. Collapse many values down to a single summary: summarize()

# These can be used in conjunction with group_by(), which changes the scope of each function from 
# operating on the entire dataset to operating on it group-by-group

# All functions work similarly:

# 1) The first argument is a dataframe (or tibble).
# 2) The subsequent arguments describe what to do with the dataframe, using the variable names 
#    (without quotes).
# 3) The result is a new dataframe (or tibble).

### Filtering Rows ################################################################################

# filter() allows you to subset observations based on their values. The first argument is the name 
# of the data-frame. The second and later arguments are the expressions that filter the data-frame.

# Select all flights on January 1st
filter(flights, month == 1, day == 1)

# Note that dplyr functions never modify their inputs, so if you want to save the result you'll 
# need to use the assignment operator (it returns a new data frame):
jan1 <- filter(flights, month == 1, day == 1)

# R either prints out the results or saves them to a variable. If you want to do both, you can
# wrap the assignment in parentheses:
(dec25 <- filter(flights, month == 12, day ==25))

## Comparisons ************************************************************************************

# R provides the standard suite of comparison operators: >, >=, <, <=, !=, and ==

# When using logical operators, remember that computers use finite precision arithmetic, so use 
# near() for comparisons with floats:
sqrt(2) ^ 2 == 2

near(sqrt(2) ^ 2, 2)

1/49 * 49 == 1

near(1/49 * 49, 1)

## Logical Operators ******************************************************************************

# The following code finds all flights that departed in November or December:
filter(flights, month == 11 | month == 12)

# A useful shorthand for this problem is x %in% y. This will select every row where x is one of the 
# values in y:
filter(flights, month %in% c(11, 12))

# Sometimes you can simplify complicated sub-setting by remembering De Morgan's law: !(A&B) = !A|!B 
# and !(A|B) = !A&!B. If you wanted to find flights that weren't delayed by more than two hours:

# Example using or
filter(flights, !(arr_delay > 120 | dep_delay > 120))

# Example using and
filter(flights, arr_delay <= 120 & dep_delay <= 120)

# Example using commas (defualts to and for each)
filter(flights, arr_delay <= 120, dep_delay <= 120)

## Missing Values *********************************************************************************

# NA represents an unknown value (not available). If you want to determine if a value is missing, 
# use is.na()
x <- NA
is.na(x)

# Note that filter() only includes rows where the condition is True, it excludes both FALSE and NA 
# values. If you want to preserve the NA values, you have to explicitly ask for them:
df <- tibble(x=c(1, NA, 3))

filter(df, x > 1)

filter(df, is.na(x) | x > 1)

### Arranging Rows ################################################################################

# arrange() changes the order of the rows. It takes a data-frame and a set of column names to order 
# by. If you provide more than one column name, each additional column will be used to break ties:
arrange(flights, year, month, day)

# Use desc() to reorder by a column in descending order:
arrange(flights, desc(arr_delay))

# Missing values are always sorted at the end:
df <- tibble(x=c(5, 2, NA))

arrange(df, x)

arrange(df, desc(x))

### Selecting Columns #############################################################################

# select() allows you to zoom in on a useful subset of columns based on their names.

# Select columns by name:
select(flights, year, month, day)

# Select all columns between year and day (inclusive):
select(flights, year:day)

# Select all columns except those from year to day (inclusive):
select(flights, -(year:day))

# There are a number of helper functions you can use within:

#   starts_with('string'): matches names that begin with 'string'
#   ends_with('string'): matches names that end with 'string'
#   contains('string'): matches names that contain 'string'
#   matches('string'): selects columns that match a regular expression
#   num_range('string', 1:3): matches string1, string2, and string3

# select() can be used to rename variables but it's not useful since it drops any columns not 
# mentioned. Instead, use rename(df, new_name=old_name):
rename(flights, tail_num=tailnum)

### Mutating Data ################################################################################

# It's often useful to add new columns that are functions of existing columns, which can be done
# with mutate().

# Note that mutate() always adds new columns at the end of your dataset, so we'll start by creating 
# a narrower dataset:
flights_sml <- select(flights,
                      year:day,
                      ends_with('delay'),
                      distance,
                      air_time)

mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60)

# Note that you can refer to columns that you're just created:
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours)

# If you only want to keep the new variables, use transmute():
transmute(flights,
          gain = arr_delay - dep_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours)

## Useful Creation Functions **********************************************************************

# There are many useful creation functions:
transmute(flights,
          air_time_hours = air_time / 60,            # arithmetic
          air_time_diff = air_time - mean(air_time), # aggregates
          hour = dep_time %/% 100,                   # integer division
          minute = dep_time %% 100)                  # modulo

# Logarithms are a useful transformation for dealing with data that ranges across multiple orders 
# of magnitude. They also convert multiplicative relationships to additive.

# All else being equal, it's recommended to use log base 2 because it's easier to interpret: a 
# difference of 1 on that log scale corresponds to doubling on the original scale: 
log2(c(4, 2, 8, 6, 10))

# lead() and lag() allow you to refer to leading or lagging values. This allows you to compute 
# running differences or find when values change in the data:
x <- 1:10
lag(x)
lead(x)

# R provides functions for running sums, products, mins, and maxes:
x <- c(5, 1, 6, 2, 6, 7, 3, 8, 10)
cumsum(x)
cumprod(x)
cummin(x)
cummax(x)
cummin(x)

# If you need rolling aggregates (computed over a window) try the RcppRoll package:

# min_rank() does the most usual type of ranking (e.g. first, second, third, fourth). The default 
# gives the smallest values the smallest ranks; use desc() to give the largest values the smallest 
# ranks:
y <- c(1, 2, 2, 3, 4)

# Rank smallest to largest
min_rank(y)

# Rank largest to smallest
min_rank(desc(y))

### Summarize Data ################################################################################

# summarize() collapses a data frame to a single row:
summarize(flights, delay=mean(dep_delay, na.rm=TRUE))

# Summarize isn't useful unless we pair it with a group by:
by_day <- group_by(flights, year, month, day)
summarize(by_day, delay=mean(dep_delay, na.rm=TRUE))

# Suppose you want to explore the relationship between distance and average delay for each 
# location:
by_dest <- group_by(flights, dest)
delay <- summarize(by_dest, 
                   count=n(),
                   dist=mean(distance, na.rm=TRUE),
                   delay=mean(arr_delay, na.rm=TRUE)
)
delay <- filter(delay, count > 20, dest != 'HNL')

ggplot(data=delay, mapping=aes(x=dist, y=delay)) + 
  geom_point(aes(size=count), alpha=1/3) + 
  geom_smooth(se=FALSE)

## Combining Operations with Piping ***************************************************************

# There are three steps to prepare this data:
#  1. Group flights by destination
#  2. Summarize to compute distance, average delay, and number of flights
#  3. Filter to remove noisy points and Honolulu airport

# All this can be done with piping:
delays <- flights %>%
  group_by(dest) %>%
  summarize(
    count=n(),
    dist=mean(distance, na.rm=TRUE),
    delay=mean(arr_delay, na.rm=TRUE)
  ) %>%
  filter(count > 20, dest != 'HNL')

# The above focuses on the transformations, not on what's being transformed. You can read it as a 
# series of statements. You can view the %>% character as 'then'.

## Missing Values *********************************************************************************

# Note that all aggregate functions have an na.rm argument, which removes the missing values prior 
# to computation:
flights %>% 
  group_by(year, month, day) %>%
  summarize(mean=mean(dep_delay, na.rm=TRUE))

# We could also first remove the null values:
not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>%
  summarize(mean=mean(dep_delay))

## Counts *****************************************************************************************

# Whenever you do any aggregation, it's always a good idea to include either a count or a count of 
# non-null values (that way you can check that you're not drawing conclusions based on very small 
# amounts of data).

# Let's look at the planes that have the highest average delays:
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay=mean(arr_delay)
  )

ggplot(data=delays, mapping=aes(x=delay)) + 
  geom_freqpoly(binwidth=10)

# We can get more insight if we draw a scatter plot:
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay=mean(arr_delay, na.rm=TRUE),
    n=n()
  )

ggplot(data=delays, mapping=aes(x=n, y=delay)) + 
  geom_point(alpha=1/10)

# When looking at this sort of plot, it's often useful to filter out the groups with the smallest 
# numbers of observations, so that you can see more of the pattern and less of the extreme
# variation in the smallest groups:
delays %>% 
  filter(n > 25) %>%                   # You can pipe output to ggplot
  ggplot(mapping=aes(x=n, y=delay)) +  # Go back to ggplot notation
  geom_point(alpha=0.10)

## Useful Summary Functions ***********************************************************************

# Median:
x <- c(5, 1, 6, 3, 7, 4, 8, 4, 8, 9)
median(x)

# Quantile is a generalization of the median:
quantile(x, 0.25)

# Minimum:
min(x)

# Maximum:
max(x)

# Standard deviation:
sd(x)

# Interquartile range:
IQR(x)

# Median absolute deviation:
mad(x)

# There are functions for position measures:

# First element
x[1]

first(x)

# N-th element
x[2]

nth(x, 2)

# Last element
x[length(x)]

last(x)

# We can find the first and last departure for each day:
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    first_dep=first(dep_time),
    last_dep=last(dep_time)
  )

# These functions are complementary to filtering on ranks. Filtering gives you all variables, with 
# each observation in a separate row:
not_cancelled %>%
  group_by(year, month, day) %>%
  mutate(r=min_rank(desc(dep_time))) %>%
  filter(r %in% range(r))

# n() takes no arguments and returns the size of the current group. To count the number of 
# non-missing values:
sum(!is.na(c(1, 2, 3, NA, 5)))

# To count the number of distinct values:
n_distinct(c(1, 2, 2, 3, 4, 4, 5))

# Which destinations have the most carriers?
not_cancelled %>%
  group_by(dest) %>%
  summarize(carriers=n_distinct(carrier)) %>%
  arrange(desc(carriers))

# There is also a simple helper function:
not_cancelled %>%
  count(dest)

# You can also provide a weight variable to sum over another column instead of just counting:

# Calculate total distance flown for each plane
not_cancelled %>%
  count(tailnum, wt=distance)

# Since TRUE translate to 1 and FALSE translates to 0, this makes sum() and mean() useful for 
# counting the number of TRUE values and the proportion of TRUE values, respectively.

# How many flights left before 5am?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(n_early=sum(dep_time < 500))

# What proportion of fights are delayed by more than an hour?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(hour_perc=mean(arr_delay > 60))

## Grouping by Multiple Variables *****************************************************************

# When you group by multiple variables, each summary peels off one level of the grouping. This 
# makes it easy to progressively roll up a data set:
daily <- group_by(flights, year, month, day)

per_day <- summarize(daily, flights=n())

per_month <- summarize(per_day, flights=sum(flights))

per_year <- summarize(per_month, flights=sum(flights))

# Be careful when progressively rolling up summaries: it's okay for sums and counts, but you need 
# to think about weighting means and variances, and it's not possible to do it exactly for 
# rank-based statistics like the median (group-wise median is not the same as overall median). 

## Un-grouping ************************************************************************************

# If you need to remove grouping and return to operations on un-grouped data, use:
daily %>%
  ungroup() %>%           # no longer grouped by date
  summarize(flights=n())  # all flights

### Grouped Mutates ###############################################################################

# Grouping is most useful with summarize(), but can also be used with mutate and filter().

# Find the worst members of each group:
flights_sml %>% 
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)

# Find all groups bigger than a threshold:
popular_dests <- flights %>%
  group_by(dest) %>%
  filter(n() > 365)

# Standardize to compute per group metrics:
popular_dests %>%
  filter(arr_delay > 0) %>%
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>%
  select(year:day, dest, arr_delay, prop_delay)

# Functions that work most naturally in grouped mutates and filters are known as window functions, 
# rather than summary functions for summaries. A window function is a variation on an aggregation, 
# which takes n inputs and returns n values (each dependent on the previous/future value(s)).
# 
# Examples: cumsum(), cummean(), rank(), lead(), lag()
