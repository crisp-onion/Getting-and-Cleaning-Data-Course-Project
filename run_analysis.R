require(dplyr)
require(readr)

x_labs <- read_table('UCI HAR Dataset/features.txt', col_names = F)
act_lab <- read_lines('UCI HAR Dataset/activity_labels.txt') |>
  strsplit(' ')
act_lab <- do.call(rbind, act_lab)

sub_test <- read_lines('UCI HAR Dataset/test/subject_test.txt')
sub_test <- do.call(rbind, as.list(sub_test))
y_test <- read_lines('UCI HAR Dataset/test/Y_test.txt') |> parse_integer()
y_test <- do.call(rbind, as.list(y_test))
x_test <- read_table('UCI HAR Dataset/test/X_test.txt', col_names = F)
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
colnames(x_train) <- x_labs$X2
x_train <- x_train |> select(contains('mean()') | contains('std()'))

train <- merge.data.frame(y_train, act_lab, by = 'V1')
train <- cbind(sub_train, train)
train <- train[c(1,3)] |> rename(subject = sub_train, activity = V2)
train <- cbind(train, x_train)

full <- rbind(train, test)
names <- gsub('\\()','', colnames(full))
names <- gsub('\\-','.', names)
colnames(full) <- names
full$subject <- as.factor(full$subject)
full$activity <- as.factor(full$activity)
means <- full |>  summarise(across(everything(), mean), .by = c(subject, activity))

write.table(means, 'step 5', row.names = F)
