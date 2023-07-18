
#### Preface ######################################################################################

### Data Science Model ############################################################################

# First you must import your data. This typically means that you take data stored in a file, 
# database, or web API, and load it into a data frame in R. 

# Next, it's a good idea to tidy the data, which means storing it in a consistent form that matches 
# the semantics of the dataset with the way it's stored. In short, when your data is tidy, each 
# column is a variable and each row is an observation. 

# Once data is tidy, a common first step is to transform the data. Transformation includes 
# narrowing in on observations of interest, creating new variables that are functions of existing 
# variables, and calculating a set of summary statistics.

# Together, tidying and transforming are called wrangling. Once you have tidy data, there are two 
# main engines of knowledge generation: visualization and modeling.

# A good visualization will show you things that you did not expect or raise new questions about 
# the data. It may also hint that you're asking the wrong question, or need to collect different 
# data. 

# Once you've made your questions sufficiently precise, you can use a model to answer them. Every 
# model makes assumptions, and by its nature a model cannot question its own assumptions. That 
# means that a model can't fundamentally surprise you. 

# The last step of a data science project is communication. It doesn't matter how well your models 
# and visualizations have led you to understand the data unless you can also communicate your 
# results to others. 

# Data exploration is the art of looking at your data, rapidly generating hypotheses, quickly 
# testing them, then repeating again and again. The goal is to generate many promising leads that 
# you can later explore in more depth.

#### Chapter 1: Data Visualization with ggplot2 ###################################################

library('ggplot2')
library('tidyverse')

# ggplot2 implements the grammar of graphics, a coherent system for describing and building graphs. 

# If we need to be explicit about where a function (or dataset) comes from, we'll use the special 
# form package::function()

### First Steps ###################################################################################

## The mpg Data Frame *****************************************************************************

# The mpg data set is a data frame found within ggplot2 (ggplot2::mpg). A data frame is a 
# rectangular collection of variables (in the columns) and observations (in the rows). mpg contains
# observations collected by the US EPA on 38 models of cars:

# Long-form
ggplot2::mpg

# Short-form
mpg

## Creating a ggplot ******************************************************************************

# With ggplot2, you begin a plot with the function ggplot(), which creates a coordinate system that 
# you can add layers to. The first argument of ggplot() is the data to use in the graph. So the 
# line ggplot(data=mpg) creates an empty graph. The function geom_point() adds a layer of points to 
# your plot, which creates a scatterplot. Each geom function in ggplot2 takes a mapping argument, 
# which defines how variables in your data are mapped to visual properties. The mapping argument is 
# always paired with aes(), and the x and y arguments specify which variables to map to the 
# respective axes:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

## Graphing Template ******************************************************************************

# ggplot(data = <DATA>) +
#   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS))

### Aesthetic Mappings ############################################################################

# You can add a third variable, like class, to a two-dimensional scatterplot by mapping it to an 
# aesthetic, which is a visual property of the objects in your plot. They can include things like 
# the size, shape, and color of your points. 

# You can convey information about your data by mapping the aesthetics in your plot to the 
# variables in your data:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# You can also set the aesthetic properties of your geom manually. To set an aesthetic manually, 
# set the property by name as an argument of your geom function, outside of the aes() argument: 
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = 'blue')

# One common problem when creating ggplot2 graphics is to put the + in the wrong place: it has to 
# be at the end of a line, not the beginning.

# It'll interpret the inputs as different classes, depending on what the inputs look like (in this 
# case it treats the booleans as two separate classes)

### Facets ########################################################################################

# Another way to add additional variables is to split your plot into facets, which are subplots 
# that each display one subset of the data. 

# To facet your plot by a single variable, use facet_wrap(), the first argument of which should be 
# a formula, which you create with a ~ followed by a variable name (here "formula" is the name of a 
# data structure in R, not an "equation"). The variable that you pass to facet_wrap() should be 
# discrete:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

# To facet your plot on the combination of two variables, add facet_grid() to your plot call. This 
# time the formula should contain two variable names separated by a ~ where the left variable will 
# be the y-axis and the right variable will be the x-axis:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

# If you prefer to not facet in the rows or columns dimension, use a '.' instead of a variable 
# name:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(. ~ cyl)

### Geometric Objects #############################################################################

# A geom is the geometrical object that a plot uses to represent data. To change the geom in your 
# plot, change the geom function that you add to ggplot():

# scatter
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# line
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

# You can set the linetype of line in geom_smooth(), where it'll draw a different line for each 
# unique value of the variable that you map to linetype:
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# Many geoms use a single geometric object to display multiple rows of data. For these geoms, you 
# can set the group aesthetic to a categorical variable to draw multiple objects. It'll draw a 
# separate object for each unique value of the grouping variable:

# In practice, it'll automatically group the data for these geoms whenever you map an aesthetic to 
# a discrete variable (as in the use of linetype). It's convenient to rely on this feature because 
# the group aesthetic by itself does not add a legend:
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

ggplot(data = mpg) + 
  geom_smooth(
    mapping = aes(x = displ, y = hwy, color = drv),
    show.legend = FALSE
  )

# To display multiple geoms in the same plot, add multiple geom functions to ggplot():
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

# To avoid duplication of code (and hence reduce the need to change things at multiple spots) you 
# may pass a set of mappings, which will be treated as global mappings to each geom in the graph:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

# If you pass mappings in a geom function, they'll be treated as local mappings for the layer. 
# It'll use these mappings to extend of overwrite the global mappings for that layer only:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()

# You can use the same idea to specify different data for each layer. Here, our smooth line 
# displays just a subset of the mpg data. The local data argument in geom_smooth overwrites the 
# global data argument: 
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) +
  geom_smooth(
    data = filter(mpg, class == 'subcompact'),
    se = FALSE
  )

### Statistical Transformations ###################################################################

# The following bar chart displays the total number of diamonds in the diamonds dataset, grouped 
# by cut:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

# Boxplots compute a robust summary of the distribution and display a specially formatted box. The 
# algorithm used to calculate new values for a graph is called a stat, or statistical 
# transformation. geom_bar() uses stat_count() by default.

# You can generally use geoms and stats interchangeably. This works because every geom has a 
# default stat, and every stat has a default geom:
ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

# There are three reasons you may need to use a stat explicitly:

# 1) You may want to override the default stat. In the following code, the stat of geom_bar() is 
#    changed from count to identity, which allows the mapping of the heigth of the bars to the raw 
#    values of y. 

demo <- tribble(
  ~a, ~b,
  'bar_1', 20,
  'bar_2', 30,
  'bar_3', 40
)

ggplot(data = demo) + 
  geom_bar(
    mapping = aes(x = a, y = b), stat = 'identity'
  )

# 2) You may want to override the default mapping from transformed variables to aesthetics. For 
#    example, you might want to display a bar chart of proportion instead of count.

ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, y = after_stat(prop), group = 1)
  )

# 3) You may want to draw greater attention to the statistical transformation. For example, you may 
#    use stat_summary(), which summarizes the y values for each unique x value.

ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )

### Position Adjustments ##########################################################################

# You can color a bar chart using either the color aesthetic or the fill aesthetic:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, color = cut))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))

# Note what happens if you map the fill aesthetic to another variable. The bars are automatically 
# stacked; each colored rectangle represents a combination of cut and clarity:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

# The stacking is performed automatically by the position adjustment specified by the position 
# argument. If you don't want a stacked bar chart, you can use 'identity', 'dodge', or 'fill'.

# Identity will place each object exactly where it falls in the context of the graph. This is not 
# very useful for bar charts:
ggplot(data = diamonds,
       mapping = aes(x = cut, fill = clarity)
) + 
  geom_bar(alpha = 0.20, position = 'identity')

ggplot(
  data = diamonds,
  mapping = aes(x = cut, color = clarity)
) + 
  geom_bar(fill = NA, position = 'identity')

# The identity position adjustment is more useful for 2D geoms, like points, where it is the 
# default.

# Fill works like stacking, but makes each set of stacked bars the same height. This makes it 
# easier to compare proportions across groups:
ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = 'fill'
  )

# Dodge places overlapping objects directly beside one another. This makes it easier to compare 
# individual values:
ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = 'dodge'
  )

# There's another type of adjustment that's not useful for bar charts, but it can be very useful 
# for scatterplots. Sometimes data is rounded, which leads to grid like plots (many points will
# overlap each other. This can be avoided by adding tiny random noise to each point to avoid the 
# overlapping nature:
ggplot(data = mpg) + 
  geom_point(
    mapping = aes(x = displ, y = hwy),
    position = 'jitter'
  )

### Coordinate Systems ###########################################################################

# The default coordinate system is the Cartesian coordinate system where the x and y positions act 
# independently to find the location of each point. There are other coordinate systems that are 
# occasionally helpful.

# coord_flip() switches the x and y axes. This is useful if you want horizontal boxplots. It's also 
# useful for long labels:
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() + 
  coord_flip()

# coord_quickmap() sets the aspect ratio correctly for maps. This is important if you're plotting 
# spatial data with ggplot2:
nz <- map_data('nz')

ggplot(data = nz, mapping = aes(x = long, y = lat, group = group)) + 
  geom_polygon(fill = 'white', color = 'black')

ggplot(data = nz, mapping = aes(x = long, y = lat, group = group)) + 
  geom_polygon(fill = 'white', color = 'black') + 
  coord_quickmap()

# coord_polar() uses polar coordinates, which reveal an interesting connection between a bar chart 
# and a Coxcomb chart:
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut),
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) + 
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()

# To save your plot (with better resolution):
ggsave(bar, file = "bar.png", dpi = 700) 

### Layered Grammar of Graphics ###################################################################

# Let's add position adjustments, stats, coordinate systems, and faceting to our code template:

# my_plot <- ggplot(data = <DATA>) + 
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>,
#     position = <POSTION>
#   ) + 
#   <COORDINATE_FUNCTION> + 
#   <FACET_FUNCTION>

# The grammar of graphics is based on the insight that you can uniquely describe any plot as a 
# combination of a dataset, a geometry, a set of mappings, a statistical transformation, a position 
# adjustment, a coordinate system, and a faceting scheme. 
