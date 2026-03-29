CodeBook
================

## Data

Downloaded through course link. Unzipped separately and contained folder
called ‘UCI HAR Dataset’ placed within R working directory.

## Code

### Libraries

dplyr and readr are both used

``` r
require(dplyr)
```

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
require(readr)
```

    ## Loading required package: readr

### Labels

First code chunk extracts the labels to be used.

x_labs is a list that uses the features.txt file to discern data names
for the X_test and X_train files

act_lab introduces the activity labels as a dataframe to be joined with
the Y_test and Y_train files later.

``` r
x_labs <- read_table('UCI HAR Dataset/features.txt', col_names = F)
```

    ## 
    ## ── Column specification ────────────────────────────────────────────────────────
    ## cols(
    ##   X1 = col_double(),
    ##   X2 = col_character()
    ## )

``` r
act_lab <- read_lines('UCI HAR Dataset/activity_labels.txt') |>
  strsplit(' ')
act_lab <- do.call(rbind, act_lab)
```

### Datasets

The main text tables are then read in. Given apppropriate column names
using the ‘x_labs’ list, and then only columns whose names contain the
strings ‘mean()’ or ‘std()’ are retained.

This is performed once for the testing set, then the training set.

``` r
sub_test <- read_lines('UCI HAR Dataset/test/subject_test.txt')
sub_test <- do.call(rbind, as.list(sub_test))
y_test <- read_lines('UCI HAR Dataset/test/Y_test.txt') |> parse_integer()
y_test <- do.call(rbind, as.list(y_test))
x_test <- read_table('UCI HAR Dataset/test/X_test.txt', col_names = F)
```

    ## 
    ## ── Column specification ────────────────────────────────────────────────────────
    ## cols(
    ##   .default = col_double()
    ## )
    ## ℹ Use `spec()` for the full column specifications.

``` r
colnames(x_test) <- x_labs$X2
x_test <- x_test |> select(contains('mean()') | contains('std()'))

test <- merge.data.frame(y_test, act_lab, by = 'V1')
test <- cbind(sub_test, test)
test <- test[c(1,3)] |> rename(subject = sub_test, activity = V2)
test <- cbind(test, x_test)

sub_train <- read_lines('UCI HAR Dataset/train/subject_train.txt')
sub_train <- do.call(rbind, as.list(sub_train))
y_train <- read_lines('UCI HAR Dataset/train/Y_train.txt') |> parse_integer()
y_train <- do.call(rbind, as.list(y_train))
x_train <- read_table('UCI HAR Dataset/train/X_train.txt', col_names = F)
```

    ## 
    ## ── Column specification ────────────────────────────────────────────────────────
    ## cols(
    ##   .default = col_double()
    ## )
    ## ℹ Use `spec()` for the full column specifications.

``` r
colnames(x_train) <- x_labs$X2
x_train <- x_train |> select(contains('mean()') | contains('std()'))

train <- merge.data.frame(y_train, act_lab, by = 'V1')
train <- cbind(sub_train, train)
train <- train[c(1,3)] |> rename(subject = sub_train, activity = V2)
train <- cbind(train, x_train)
```

### Final Set

The two dataframes above ‘test’ and ‘train’ are then combined into a
dataframe called ‘full’.

Special characters are then removed from the column names of ‘full’
using an intermediary list called ‘names’.

The ‘subject’ and ‘activity’ columns are then converted to factors,
allowing grouping, which then allows the dplyr summarise function to
work across these groups to provide the final means requested in
assignment.

``` r
full <- rbind(train, test)
names <- gsub('\\()','', colnames(full))
names <- gsub('\\-','.', names)
colnames(full) <- names
full$subject <- as.factor(full$subject)
full$activity <- as.factor(full$activity)
means <- full |>  summarise(across(everything(), mean), .by = c(subject, activity))
```
