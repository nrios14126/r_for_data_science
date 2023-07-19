
#### Chapter 7: Tibbles with tibble ###############################################################

library(tidyverse)

### Creating Tibbles ##############################################################################

# Almost all of the functions in the tidyverse produce tibbles. Most other R packages use regular 
# data frames. To coerce a data frame to a tibble:
as_tibble(iris)

# You can create a new tibble from individual vectors with tibble(), and will automatically recycle 
# inputs of length 1:
tibble(
  x = 1:5,
  y = 1,
  z = x ^ 2 + y
)

# Note that tibble does much less than data.frame; it never changes the type of the inputs, it 
# never changes the names of variables, and it never creates row names.

# Another way to create a tibble is with tribble(), short for transposed tribble. It's customized 
# for data entry in code: column headings are defined by formulas and entries are separated by 
# commas: 
tribble(
  ~x, ~y, ~z,
  'a', 2, 3.6,
  'b', 1, 8.5
)

### Tibbles Versus data.frame #####################################################################

# There are two main differences in the usage of a tibble versus a data.frame: printing and 
# subsetting

## Printing ***************************************************************************************

# Tibbles have a refined print method that shows only the first 10 rows, and all the columns that 
# fit on screen. In addition to its name, each column reports its type:
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = T)
)

# Sometimes you need more output than the default display. First, you can explicitly print() the 
# data frame and control the number of rows (n) and the width of the display (width = Inf will 
# display all columns):
nycflights13::flights %>% 
  print(n = 10, width = Inf)

# Another option is to use RStudio's built-in data viewer to get a scrollable view of the complete 
# dataset.
nycflights13::flights %>% 
  View()

## Subsetting *************************************************************************************

# Given the following tibble:
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

# Extract by name with dollar sign
df$x

# Extract by name with brackets
df[['x']]

# Extract by position (column number) with brackets
df[[1]]

# To use these in a pipe, you'll need to use the dot character:
df %>% .$x

df %>% .[['x']]
