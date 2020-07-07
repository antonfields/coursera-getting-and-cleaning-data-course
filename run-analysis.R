library(tidyverse)

# set up file paths
filepath <- "data/UCI-HAR-Dataset"
filepath_test <- "data/UCI-HAR-Dataset/test"
filepath_train <- "data/UCI-HAR-Dataset/train"

## load the data files

# load x_test.txt file
filename_x_test <- "x_test.txt"
fullpath_x_test <- file.path(filepath_test, filename_x_test)
x_test <- read.table(fullpath_x_test)

# load y_test.txt file
filename_y_test <- "y_test.txt"
fullpath_y_test <- file.path(filepath_test, filename_y_test)
y_test <- read.table(fullpath_y_test)
y_test <- y_test %>% rename("activity_ref" = V1)

# load x_train.txt file
filename_x_train <- "x_train.txt"
fullpath_x_train <- file.path(filepath_train, filename_x_train)
x_train <- read.table(fullpath_x_train)

# load y_train.txt file
filename_y_train <- "y_train.txt"
fullpath_y_train <- file.path(filepath_train, filename_y_train)
y_train <- read.table(fullpath_y_train)
y_train <- y_train %>% rename("activity_ref" = V1)

# load the activity labels and add to y files
filename_activity_labels <- "activity_labels.txt"
fullpath_activity_labels <- file.path(filepath, filename_activity_labels)
activity_labels <- read.table(fullpath_activity_labels)
activity_labels <- activity_labels %>% rename("activity_ref" = V1, "activity" = V2)
y_test <- left_join(y_test, activity_labels, by = "activity_ref")
y_train <- left_join(y_train, activity_labels, by = "activity_ref")

# load the subject references
filename_subject_test <- "subject_test.txt"
fullpath_subject_test <- file.path(filepath_test, filename_subject_test)
subject_test <- read.table(fullpath_subject_test)

filename_subject_train <- "subject_train.txt"
fullpath_subject_train <- file.path(filepath_train, filename_subject_train)
subject_train <- read.table(fullpath_subject_train)


## Combine the datasets
test_data <- cbind(subject_test, y_test, x_test)
train_data <- cbind(subject_train, y_train, x_train)
data <- rbind(test_data, train_data)


## Sort out column headings
filename_features <- "features.txt"
fullpath_features <- file.path(filepath, filename_features)
features <- read.table(fullpath_features)
variables <- features %>%
        rename("ref" = 1, "variable_name" = 2) %>%
        select(variable_name)

variable_names <- t(variables)
variable_names <- cbind("subject", "act_ref", "activity", variable_names)
colnames(data) <- variable_names


## Crate first tidy dataset - select mean & std variables only
dataset1 <- data[,grep("subject|activity|*[Ss]td*|*[Mm]ean*", colnames(data))]


## create second tidy dataset
dataset2 <- dataset1 %>%
        group_by(activity, subject) %>%
        summarise_all(mean)
write.table(dataset2, file = "tidy_data_set.txt", row.names = FALSE)


