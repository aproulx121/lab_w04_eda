#' ---
#' title: "Data Science Methods, Lab for Week 99"
#' author: "Your Name"
#' email: Your Email
#' output:
#'   html_document:
#'     toc: true
#' ---

#' In this lab, we'll be looking at a set of housing sales data assembled by Dean De Cock of Truman State University in Missouri.  The dataset has been widely used for learning about predictive modeling or machine learning.  But we'll focus on using the techniques from today's notes to get a handle on a dataset with dozens of variables.  
#' 
#' De Cock's paper documenting the dataset is here:  <http://jse.amstat.org/v19n3/decock.pdf>.  The abstract notes notes some major features of the dataset:  
#' 
#' > This paper presents a data set describing the sale of individual residential property in Ames, Iowa from 2006 to 2010. The data set contains 2930 observations and a large number of explanatory variables (23 nominal, 23 ordinal, 14 discrete, and 20 continuous) involved in assessing home values. 
#' 
#' We'll be accessing the dataset using the `AmesHousing` package.  (Strictly speaking, we'll be using a CSV that I generated from one version in the `AmesHousing` package, because it gives us a chance to learn a few things about factors.)  It'll be useful to have the documentation for `AmesHousing::ames_raw` open, because it gives short descriptions of the many variables in the dataset:  <https://cran.r-project.org/web/packages/AmesHousing/AmesHousing.pdf>.  You can find a full codebook for the dataset at <http://jse.amstat.org/v19n3/decock/DataDocumentation.txt>. 
#' 

## Setup
## **IMPORTANT**: Add all dependencies to `DESCRIPTION`
install.packages("AmesHousing")
library(tidyverse)
library(skimr)
library(visdat)
library(AmesHousing)

dataf = read_csv(file.path('data', 'ames.csv'))

## To check your answers locally, run the following: 
## testthat::test_dir('tests')
testthat::test_dir('tests')

#' # Problem 1 #
#' We'll start with Peng and Matsui's step 1, "Formulate your question."  The Ames dataset is often used to teach predictive modeling tasks, where the goal is to predict the final selling price.  So our question will be *which variables in the dataset are mostly highly correlated with sale price?* 
#' *which variables in the dataset are mostly highly correlated with sale price?* 
#' 
#' 1. Look through the short descriptions in `?ames_raw` (or online, <https://cran.r-project.org/web/packages/AmesHousing/AmesHousing.pdf>).  Which variable reports the actual sale price? 
#' Sale_Price
#'
#' 
#' 
skimr::skim(dataf)
vis_dat(dataf)
?ames_raw
#' 2. As you were looking through the variable descriptions, you probably noticed a few variables that might be good predictors of sale price.  List two or three here. 
#' overall_cond
#' Utilities
#' Pool_area


#' # Problem 2 #
#' We've already loaded the data, so let's jump to step 3, "Check the packaging," and 5, "Check your 'n's." Use `skimr::skim()` and `vis_dat` functions to answer the following questions.  To report the values that you find, replace the value assigned to the `problem` variable.  
#' 
#' 1. The paper abstract (see above) reports 2930 rows.  How many observations (rows) are in our version of the dataset?  
#' 2930
skimr::skim(dataf)


#' 2. The abstract also reports 80 "explanatory variables (23 nominal, 23 ordinal, 14 discrete, and 20 continuous)."  In R, factors are used for both nominal and ordinal; and numerics are used for both discrete and continuous. How many of each are in our version?
#'character = 46
#'numeric = 35


#' 3. Explain any discrepancies here. 
#' there are 34 discrete and continuous variables while it is 35 for R numeric.
#' 
#' 

#' 4. How many variables have missing values?  
#' 0



#' # Problem 3 #
#' `summarize()` is a tidyverse function that collapses multiple rows of data into a single row.  Like `mutate()` and `count()`, it respects groups constructed by `group_by()`.  Here's an example: 
#' 
dataf %>% 
  group_by(MS_Zoning) %>% 
  summarize(Sale_Price = mean(Sale_Price)) %>% 
  ungroup()

#' 1. Examine the full codebook, at <http://jse.amstat.org/v19n3/decock/DataDocumentation.txt>.  What do the values of MS_Zoning represent? 
#' Identifies the general zoning classification of the sale
#' 
#' 

#' 2. Run the following two expressions.  Why do they give different results? 
#' The first is a filters then summarizes and the second summarizes then filters.
#' 
#' 
dataf %>% 
  group_by(MS_Zoning) %>% 
  filter(Sale_Price > 100000) %>% 
  summarize(Sale_Price = mean(Sale_Price)) %>% 
  ungroup()

dataf %>% 
  group_by(MS_Zoning) %>% 
  summarize(Sale_Price = mean(Sale_Price)) %>% 
  filter(Sale_Price > 100000) %>% 
  ungroup()


#' # Problem 4 #
#' Now we'll take a look at some of the items on the checklist from Huebner et al. 
#' 
#' *Duplicate records*: The `distinct()` function takes a dataframe and returns a version with excess copies of duplicate rows removed.  Here's an example: 

dup_demo = tribble(
  ~x, ~y, 
  1,  5, 
  1,  5, 
  2,  4
)
dup_demo
distinct(dup_demo)

#' Use this function to create a dataframe `dataf_nodup` with the duplicate rows removed.  Do `dataf` and `dataf_nodup` have the same number of rows?  What does this tell you about duplicate entries in our dataset?  
#' same number of rows, there are no dublicate rows in our dataset.
#' 
#' 
# dataf_nodup = distinct (dataf)
dataf
distinct(dataf)
dataf_nodup = distinct(dataf)
dataf_nodup

#tribble(dataf_nodup)
#dataf_nodup = tribble(dataf)
#dataf_nodup
#distinct(dataf_nodup)



#' # Problem 5 #
#' *Coding ordinal variables*: R uses the class `factor` to represent categorical (also called "nominal") and ordinal variables.  Because the CSV format doesn't have a way to document the variable type for its columns, when we load a CSV into R the categorical and ordinal variables get parsed as characters rather than factors.  
#' 
#' 1. What's the class of the overall condition variable, `Overall_Cond`? 
#' 
#' Character
#' 

class(dataf$Overall_Cond)


#' 2. Tidyverse functions are generally pretty good about treating a character variable as a factor when it makes sense to do so.  Use `count()` to get a count of the number of houses by overall condition; assign this data frame to `cond_count`. 
#'  
cond_count = count(dataf, Overall_Cond)
cond_count 
# cond_count = ???

#' 3. However, notice that the possible values of the variable (called the *levels* of the factor) are in alphabetical order, not from "Very Poor" through "Average" to "Excellent" as intended.  We would see the same thing if we try to coerce `Overall_Cond` to a factor:  

bad_factor = factor(dataf$Overall_Cond)
bad_factor
levels(bad_factor)

#' To fix this, we need to set the order of the levels manually.  First, edit the next line, so that the levels correspond to the list in the documentation, with "Very Poor" as the lowest (first) value and "Very Excellent" as the highest (<http://jse.amstat.org/v19n3/decock/DataDocumentation.txt>, search for "Overall Cond").  

condition_levels = c('Very_Poor', 'Poor','Fair', 'Below_Average', 'Average', 'Above_Average', 'Good','Very_Good','Excellent', 'Very_Excellent')

#' 4. To fix the levels, we use the `levels = ` argument in `factor()`.  Modify the code for `bad_factor` above, assigning the result to `good_factor`.  Confirm that the levels are in the right order. 

good_factor = factor(dataf$Overall_Cond, levels = condition_levels)
good_factor
levels(good_factor)


# good_factor = ???

#' 5. Finally we want this factor to be in our analysis dataframe.  *Normally, to preserve immutability*, I would do this right after reading in the CSV (using a pipe).  We'll talk more about this when we work on cleaning data.  For this lab, just do it here.  
#' 
#' Using `mutate()`, add a variable `overall_cond_fct` to `dataf`, that represents overall condition as a factor with the levels in the correct order. 

mutate(dataf,overall_cond_fct = good_factor)
overall_cond_fct = good_factor
overall_cond_fct
# dataf = ???


#' # Problem 6 #
#' Recall that we're interested in finding variables that are highly correlated with sale price.  We can use the function `cor()` to construct a correlation matrix, with correlations between all pairs of variables in the dataframe.  But this creates two challenges.  First, `cor()` only works with numerical inputs.  If we try it with our current dataframe, it throws an error:  
# cor(dataf)
#' Second, the result will be a matrix — a 2D collection of numbers — rather than a dataframe.  We'll need to convert it back to a dataframe to use our familiar tidyverse tools.  
#' 
#' 1. We can use the tidyverse function `select()` to pull out a given set of columns from the dataframe.  

select(dataf, Sale_Price, Overall_Cond, Gr_Liv_Area)

#' But manually typing out all 34 numerical covariates would be tedious and prone to error.  Fortunately `select()` is much more powerful than this.  You can read more in `?select` or here: <https://tidyselect.r-lib.org/reference/language.html>.  
#' 
#' We will use `where()`, which allows us to use a predicate function (function that returns `TRUE` or `FALSE`) to select all of the columns that are factors or numerical. 
#' 
#' Fill in the blanks in the following code.  Hints: Use `?factor` and `?numeric` to bring up documentation for these classes.  Look for functions that start with `is`.  Check the documentation for `where()` to see examples. 
?factor
?numeric
dataf_smol = select(dataf, where(is.numeric), where(is.factor))
rlang::last_error()
dataf_smol

#' 2. `cor()` doesn't like factors.  `as.integer()` will coerce a factor into an integer representation; then `method = 'spearman'` will tell `cor()` to use Spearman correlation instead of Pearson correlation.  (Spearman correlation is based on the rank of the variable values, rather than the values directly.  This is a standard approach for dealing with correlations of ordinal variables.)
#' 
#' Fill in the blank: 

## cor_matrix = dataf_smol %>%
#     mutate(as.integer(factor(overall_cond_fct))) %>%
#    cor(method = 'spearman')
#cor_matrix = dataf_smol %>%
#mutate(as.integer(factor(overall_cond_fct))) %>%
#cor(method = 'spearman')

cor_matrix = dataf_smol %>%
  mutate(overall_cond_fct = as.integer(overall_cond_fct))%>%
  cor(method = 'spearman')
cor_matrix
rlang::last_error()
cor_matrix
#' 3. Now we convert the correlation matrix into a dataframe.  
#' a. Explain what the following line of code is doing.  Hint: Read the docs! 
#' as_tibble is converting the object (matrix) into a so called tibble and making the rownames be 'covar', and setting rows in the data frame.
#' 
#' 

cor_df = as_tibble(cor_matrix, rownames = 'covar')
cor_df
?tbl
#' b. What do the rows of `cor_df` represent?  The columns?  The values in each cell? 
#' - rows: variables
#' - columns: variables
#' - values: correlation between two different variables

#' 4. We've calculated the correlations for each pair of variables.  Now we want to construct a table with the top 10 most highly-correlated variables.  Write a pipe that does the following, in order:  
#' - Start with `cor_df`
#' - Select the columns with the name of each covariate and its correlation with sale price
#' - Arrange them in descending order, starting with the strongest positive correlation
#' - Keep the top 10 rows.  Hint: `?top_n`
#' - Assigns the result to the variable `top_10`
#' 
?top
top_10 = cor_df%>%
  select(covar, Sale_Price)%>%
  arrange(desc(Sale_Price))%>%
  top_n(10)
top_10

?slic
#' # Problem 7 #
#' In 1.2, you identified some variables that you thought might be good predictors of sale price.  How good were your expectations? 
#' I did terrible! none of my 3 were even in the top 10. I'm mostly surprised that overall condition did not have a strong correltion.
#' 
#'