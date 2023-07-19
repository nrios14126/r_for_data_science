
#### Chapter 5: Exploratory Data Analysis #########################################################

# EDA: explore your data in a systematic way.
#   1. Generate questions about your data
#   2. Search for answers by visualizing, transforming, and modeling your data
#   3. Use what you learn to refine your questions and generate new questions

# Data cleaning is just one application of EDA: you ask questions about whether or not your data 
# meets your expectations. To do data cleaning, you'll need to deploy all the tools of EDA: 
# visualization, transformation, and modeling.

library(tidyverse)

# Your goal during EDA is to develop an understanding of your data. The easiest way to do this is 
# to use questions as tools to guide your investigation. The key to asking quality questions is to 
# generate a large quantity of questions. 

# Two types of questions will always be useful for making discoveries within your data:
#   1. What type of variation occurs within my variables?
#   2. What type of co-variation occurs between my variables?

# A variable is a quantity, quality, or property that you can measure.

# A value is the state of a variable when you measure it.

# An observation (or data point) is a set of measurements made under similar conditions (you 
# usually make all of the measurements in an observation at the same time and on the same object). 
# An observation will contain several values, each associated with a different variable. 

# Tabular data is a set of values, each associated with a variable and an observation. Tabular data 
# is tidy if each value is placed in its own cell, each variable in its own column, and each 
# observation in its own row. 

### Variation #################################################################

# Variation is the tendency of the values of a variable to change from measurement to measurement. 
# Each of your measurements will include a small amount of error that varies from measurement to 
# measurement. 

# Categorical variables can also vary if you measure across different subjects, or different times. 
# Every variable has its own pattern of variation, and the best way to understand that pattern is 
# to visualize the distribution of the variable's values.

## Visualizing Distributions **************************************************

# How you visualize the distribution of a variable will depend on whether the variable is 
# categorical or continuous. 

# A variable is categorical if it can only take one of a small set of values. In R, categorical 
# variables are usually saved as factors or character vectors. To examine the distribution of a 
# categorical variable, use a bar chart:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

# You can compute the frequency of the values with:
diamonds %>% 
  count(cut)

# A variable is continuous if it can take any of an infinite set of ordered values. To examine the 
# distribution of a continuous variable, use a histogram:
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

# You can compute the frequency of the values with:
diamonds %>% 
  count(cut_width(carat, 0.5))

# You can set the width of the intervals in a histogram with the bin width argument, which is 
# measured in the units of the x variable.

# If you wish to overlay multiple histograms in the same plot, it's recommended to use 
# geom_freqpoly() instead, which performs the same calculation as geom_histogram() but uses lines:
smaller <- diamonds %>% 
  filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat, color = cut)) + 
  geom_freqpoly(binwidth = 0.1)

## Typical Values *************************************************************

# To turn this information into useful questions, look for anything unexpected:
#   1. Which values are the most common? Why?
#   2. Which values are rare? Why?
#   3. Can you see any unusual patterns? What might explain them?

ggplot(data = smaller, mapping = aes(x = carat)) + 
  geom_histogram(binwidth = 0.01)

# For the above plot, think about:
#   1. Why are there more diamonds at whole and common fractions of carats?
#   2. Why are there more diamonds slightly to the right of each peak?
#   3. Why are there no diamonds bigger than 3 carats?

# In general, clusters of similar values suggest that subgroups exits in your data. To understand 
# the subgroups:
#   1. How are the observations within each cluster similar to each other?
#   2. How are the observations in separate clusters different from 
#      each other? 
#   3. How can you explain/describe the clusters?
#   4. Why might the appearance of clusters be misleading?

ggplot(data = faithful, mapping = aes(x = eruptions)) + 
  geom_histogram(binwidth = 0.25)

## Unusual Values *************************************************************

# Outliers are observations that are unusual; data points that don't seem to fit the pattern. 
# Sometimes they're data entry errors; other times they suggest important new science. 

# When you have a lot of data, outliers are sometimes hard to see in a histogram:
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

# To make it easier to see the outliers, we need to zoom in:
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  # Also has an xlim argument
  coord_cartesian(ylim = c(0, 50))

# We can now pluck out the values:
unusual <- diamonds %>% 
  filter(y < 3 | y > 20) %>% 
  arrange(y)

head(unusual)

# It's good practice to repeat your analysis with and without the outliers. If they have minimal 
# effect on the results, and you can't figure out why they're there, it's reasonable to replace 
# them with missing values. However, if they have a substantial effect on your results, you 
# shouldn't drop them without justification. You'll need to figure out what caused them and 
# disclose that you removed them in your write-up.

### Missing Values ################################################################################

# If you've encountered outliers and simply want to move on, you can:

# 1. Drop the entire row with the outliers (not recommended)
diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))

# 2. Replace the outliers with missing values (recommended)
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

# ggplot does not include NA in its plots but does shoot a warning:
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point()

# To suppress the warning:
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point(na.rm = TRUE)

# Other times you want to understand what makes observations with missing values different from 
# observations with recorded values:
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time)) +
  geom_freqpoly(
    mapping = aes(color = cancelled),
    binwidth = 0.25
  )

# The above plot isn't great because there are many more non-cancelled flights than cancelled 
# flights. There are better techniques for this situation.

### Co-variation ##################################################################################

# If variation describes the behavior within a variable, co-variation describes the behavior 
# between variables. Co-variation is the tendency for the values of two or more variables to vary 
# together in a related way. The best way to spot co-variation is to visualize the relationship 
# between two or more variables. 

## Categorical and Continuous *********************************************************************

# It's common to want to explore the distribution of a continuous variable broken down by a 
# categorical variable. 

# The default appearance of geom_freqpoly() is not that useful for that sort of comparison because 
# the height is the count, which means if one of the groups is much smaller than the others, it's 
# hard to see the difference in shape.

# Example, let's see how the price of a diamond varies with its quality:
ggplot(data = diamonds, mapping = aes(x = price)) + 
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# It's hard to see the difference in distribution because of the counts:
ggplot(diamonds) + 
  geom_bar(mapping = aes(x = cut))

# To make the comparison easier we need to swap what is displayed on the y-axis. Instead of 
# displaying count, we'll display density, which is the count standardized so that the area under 
# each frequency polygon is 1.
ggplot(
  data = diamonds,
  mapping = aes(x = price, y = after_stat(density))
) + 
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# Another alternative to show relationship between a continuous and categorical variable is the 
# box-plot. The cut is an ordered factor: fair is worse than good, which is worse than very good. 
# It makes sense to display the boxplots in this order:
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) + 
  geom_boxplot()

# Many categorical variables don't have such an ordinal nature, so you may want to reorder (sort) 
# them to make a more intuitive display:

# Default ordering:
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()

# To make the trend easier to see:
ggplot(data = mpg) + 
  geom_boxplot(
    mapping = aes(
      # Reorder on class based on median value of hwy
      x = reorder(class, hwy, FUN = median),
      y = hwy
    )
  )

# If you have long variable names, the box-plot will work better if you rotate the plot 90 degrees:
ggplot(data = mpg) + 
  geom_boxplot(
    mapping = aes(
      x = reorder(class, hwy, FUN = median),
      y = hwy
    )
  ) + 
  coord_flip()

## Two Categorical Variables **********************************************************************

# To visualize co-variation between categorical variables, you'll need to count the number of 
# observations for each combination. 
ggplot(data = diamonds) + 
  geom_count(mapping = aes(x = cut, y = color))

# Co-variation will appear as a strong correlation between specific x values and specific y values.

# Another approach is to compute the count:
diamonds %>% 
  count(color, cut)

# Then visualize geom_tile() and fill aesthetic:
diamonds %>% 
  count(color, cut) %>% 
  ggplot(mapping = aes(x = color, y = cut)) + 
  geom_tile(mapping = aes(fill = n))

# If the categorical variables are unordered, you might want to use the "seriation" package to 
# simultaneously reorder the rows and columns in order to more clearly reveal interesting patterns. 
# For larger plot, try the "d3heatmap" or "heatmaply" packages.

## Two Continuous Variables ***********************************************************************

# A great way to visualize the covariation between two  continuous variables is to make a 
# scatterplot where you can see the the covariation as a pattern in the points.

# For example, you can see the exponential relationship between the carat size and price of the 
# diamond:
ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = carat, y = price))

# Scatterplots become less useful as the size of your dataset grows, because points begin to 
# overplot and pile up into areas of uniform black. One way to fix this problem is to add 
# transparency to the points:
ggplot(data = diamonds) + 
  geom_point(
    mapping = aes(x = carat, y = price),
    alpha = 0.05
  )

# But using transparency can be challenging for very large datasets. Another solution is to use 
# bin, namely in two dimensions. geom_bind2d() and geom_hex() divide the coordinate plane into 2D 
# bins and then use a fill color to display how many points fall into each bin. 

# For rectangular bins:
ggplot(data = smaller) + 
  geom_bin2d(mapping = aes(x = carat, y = price))

library('hexbin')

# For hexagonal bins: 
ggplot(data = smaller) + 
  geom_hex(mapping = aes(x = carat, y = price))

# Another option is to bin one continuous variable so it acts like a categorical variable. This way 
# you can use the techniques discussed regarding the covariation of a categorical and continuous 
# variable. 

# You could bin carat and then for each group display a boxplot. Here, cut_width() divides x into 
# bins of specified width. 
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.10)))

# To make the boxplots proportional to the number of points they represent:
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.10)), varwidth = TRUE)

# Another approach is to display approximately the same number of points in each bin:
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

# Two-dimensional plots reveal outliers that are not visible in one-dimensional plots. Some points 
# may have unusual combinations of x and y values, making them outliers even though their x and y 
# values appear normal separately:
ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = x, y = y)) + 
  coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))

### Pattern and Models ############################################################################

# Patterns in your data provide clues about relationships between variables:
#  1. Could this pattern be due to coincidence?
#  2. How can you describe the relationship implied by the pattern?
#  3. How strong is the relationship implied by the pattern?
#  4. What other variables might affect the relationship?
#  5. Does the relationship change if you look at individual subgroups of the data?

# Patterns provide a useful tool for data scientists because they reveal covariation. If you think 
# of variation as a phenomenon that creates uncertainty, covariation is a phenomenon that reduces 
# it; if two variables covary, you can use the values of one variable to make better predictions
# about the values of the second. If the covariation is due to a causal relationship (a special 
# case), then you can use the value of one variable to control the value of the other. 

# Models are a tool for extracting patterns out of data. It's possible to use a model to remove the 
# strong relationship between two variables so we can explore the subtleties that remain. 

# The following code fits a model that predicts price and carat and then computes the residuals 
# (the difference between the predicted values and the actual value). The residuals give us a view 
# of the price of the diamond once the effect of carat is removed:
library(modelr)

model <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>%
  add_residuals(model) %>% 
  mutate(resid = exp(resid))   # Residual values greater than 1 are positive

# Clearly not normally distributed white noise
ggplot(data = diamonds2) + 
  geom_point(mapping = aes(x = carat, y = resid))

# Once you've removed the strong relationship between carat and price, you can see what you expect 
# in the relationship between cut and price; relative to their size, better quality diamonds are 
# more expensive:
ggplot(data = diamonds2) + 
  geom_boxplot(mapping = aes(x = cut, y = resid))
