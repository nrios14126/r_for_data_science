
#### Chapter 8: Data Import with readr ############################################################

### Getting Started ###############################################################################

# Most of readr's functions are concerned with turning flat files into data frames. These functions 
# all have similar syntax. 

# The first argument to read_csv() is the path to the file:
heigths <- read_csv(
  'https://raw.githubusercontent.com/hadley/r4ds/main/data/heights.csv')

# By default, the function uses the first line of the data for the column names. There are some 
# cases where you may want to tweak this:
# 
# 1. Sometimes there a few lines of metadata at the top of the file. You can use skip = n to skip 
#    the first n lines; or use comment = '#' to drop all lines that start with '#'.

# To skip a certain number of lines from the start:
read_csv('The first lined of metadata
          The second line of metadata
          x,y,z
          1,2,3', skip = 2)

# To ignore lines beginning with a certain character:
read_csv('# A comment I want to skip
          x,y,z
          1,2,3', comment = '#')

# 2. The data may not have column names. You can specify to not use the first row as column 
#   headers. 

# By default, it'll name the columns 'X1', 'X2', ..., 'Xn'
read_csv('1,2,3\n4,5,6', col_names=FALSE)

# Or you can pass a character vector to provide names:
read_csv('1,2,3\n4,5,6', col_names = c('x', 'y', 'z'))

### Parsing a Vector ##############################################################################

# The parse functions take a character vector and return a more specialized vector like a logical, 
# integer, or date:

# Parse booleans
str(parse_logical(c('TRUE', 'FALSE', 'NA')))

# Parse integers
str(parse_integer(c('1', '2', '3')))

# Parse date-time
str(parse_date(c('2010-01-01', '1979-10-14')))

# The first argument is a character vector to parse, and the na argument specifies which strings 
# should be treated as missing:
parse_integer(c('1', '231', '.', '456'), na = '.')

# If parsing fails, you'll get a warning and the failures will be missing in the output:
x <- parse_integer(c('123', '345', 'abc', '123.45'))
x

# If there are many parsing failures, you'll need to use problems() to get the complete set. This 
# returns a tibble:
problems(x)

# Here are some notable parsers: 
#     1. parse_logical()
#     2. parse_integer()
#     3. parse_double()
#     4. parse_character()
#     5. parse_factor()
#     6. parse_datetime() 
#     7. parse_date()
#     8. parse_time()

## Numbers ****************************************************************************************

# There is a locale object that specifies parsing options that differ from place to place. For 
# example, you can override the default value of '.' for indicating decimal places:

# Default method
parse_number('1.23')

# Comma method
parse_number('1,23', locale = locale(decimal_mark = ','))

# You can also ignore non-numeric characters before and after the number, such as percentages or 
# currency symbols:

# Currency
parse_number('$100')

# Percent
parse_number('20%')

# Text
parse_number('It cost $123.45')

# To address different grouping symbols (i.e 1,000,000 vs 1.000.000), you can pass an additional 
# argument to the locale object:
parse_number('123.456.789,50', 
             locale = locale(grouping = '.', decimal_mark = ','))

## Strings ****************************************************************************************

# There are generally multiple ways to represent the same string. In R we can get at the underlying 
# representation of a string with:
charToRaw('Rios')

# Each hexadecimal number represents a byte of information, and this mapping is called ASCII. 
# However, today there is one standard that is support almost everywhere: UTF-8, which can encode 
# just about every character used.

# When using readr, it assumes your data is UTF-8 encoded when you read it, and always uses it when 
# writing. This default though will fail for data produced by older systems that don't understand 
# UTF-8:

# Spanish text with Latin1 encoding
x1 <- 'El Ni\xf1o was particularly bad this year'

# Japanese text with Shift-JIS encoding
x2 <- '\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd'

# Parsing with the locale object:
parse_character(x1, locale = locale(encoding = 'Latin1'))
parse_character(x2, locale = locale(encoding = 'Shift-JIS'))

## Factors ****************************************************************************************

# R uses factors to represent categorical variables that have a known set of possible values. Give 
# parse_factor() a vector of known levels to generate a warning whenever an unexpected value is 
# present:
fruit <- c('apple', 'banana')
parse_factor(c('apple', 'banana', 'apple', 'bananana'), levels = fruit)

## Dates, Date-Times, and Times ***********************************************

# You pick between three parsers depending on whether you want a date, a time, or a date-time. 

# parse_datetime() expects an ISO8601 date-time, which organizes the date from biggest component to 
# smallest: year, month, day, hour, minute, second
parse_datetime('2010-10-01T2010')

# If time is omitted, it will be set to midnight:
parse_datetime('20101010')

# parse_date() expects year, month, and day:
parse_date('2010-10-01')

# parse_time() expects hour, minutes, and seconds. Base R doesn't have a great built-in class for 
# time data, so we'll use 'hms' instead:
library(hms)
parse_time('01:10 am')
parse_time('20:10:01')

# If these defaults don't work for your data, you can supply your own format.

# The best way to figure out the correct format is to create a few examples in a character vector 
# and test one of the parsing functions:
parse_date('01/02/15', '%m/%d/%y')
parse_date('01/02/15', '%d/%m/%y')
parse_date('01/02/15', '%y/%m/%d')

# If you're using %b or %B with foreign names, you'll need to set the language argument within 
# locale():
parse_date('1 enero 2015', '%d %B %Y', locale = locale('es'))

### Parsing a File ################################################################################

## Strategy ***************************************************************************************

# readr uses a heuristic to figure out the type of each column: it reads the first 1000 rows and 
# uses some (moderately conservative) heuristics to figure out the type of each column. If none of 
# the heuristics apply, then the column will stay as a vector of strings.

## Problems ***************************************************************************************

# These defaults don't always work for larger files:
#
# 1. The first 1000 rows might be a special case, and readr guesses a type that is not sufficiently 
#    general (i.e., may have a column of doubles that is full of integers at the start)
# 
# 2. The column might contain a lot of missing values. If the first 1000 rows contain only NAs, 
#    readr will guess that it's a character vector. 

# A good strategy is to work column by column until there are no problems remaining, which you can 
# check with problems()
challenge_df <- read_csv(readr_example('challenge.csv'))
problems(challenge_df)

# To fix the call:
challenge_df <- read_csv(readr_example('challenge.csv'),
                         col_types = cols(
                           x = col_double(),
                           y = col_date()
                         ))

# Note that every parse_*() function has a corresponding col_*() function.

# Sometimes it's easier to diagnose problems if you just read in all the columns as character 
# vectors:
challenge2_df <- read_csv(readr_example('challenge.csv'),
                          col_types = cols(.default = col_character()))

# This is useful in conjunction with type_convert(), which applies the parsing heuristics to the 
# character columns in a data frame:
df <- tribble(
)
