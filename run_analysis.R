library(plyr)


#*****************************************************************
#Download data
#*****************************************************************

if(!file.exists("./mydata")){dir.create("./mydata")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./mydata/mydataset.zip")

# Unzip dataSet in my directory
unzip(zipfile="./mydata/mydataset.zip",exdir="./mydata")


#*****************************************************************
# Step 1
# Merge the training and test sets to create one data set
#*****************************************************************

x_train <- read.table("./mydata/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./mydata/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./mydata/UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("./mydata/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./mydata/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./mydata/UCI HAR Dataset/test/subject_test.txt")

# prepare partial datasets
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

#*****************************************************************
# Step 2
# Extract only the measurements on the mean and standard deviation for each measurement
#*****************************************************************

features <- read.table("./mydata/UCI HAR Dataset/features.txt")

# get only columns with mean() or std() in their names
mean_and_std_features <- grep("-(mean|std)\\(\\)", features[, 2])

# subset the needed columns only
x_data <- x_data[, mean_and_std_features]

# Update column names
names(x_data) <- features[mean_and_std_features, 2]

#*****************************************************************
# Step 3
# Use descriptive activity names to name the activities in the data set
#*****************************************************************

activities <- read.table("./mydata/UCI HAR Dataset/activity_labels.txt")

# update values with  activity names
y_data[, 1] <- activities[y_data[, 1], 2]

# Update column names
names(y_data) <- "activity"

#*****************************************************************
# Step 4
# Appropriately label the data set with descriptive variable names
#*****************************************************************

# Update column names
names(subject_data) <- "subject"

# bind all the data in a dataset
alldata <- cbind(x_data, y_data, subject_data)

#*****************************************************************
# Step 5
# Create a second, independent tidy data set with the average of each variable
# for each activity and each subject
#*****************************************************************

# skip last two columns (activity & subject)
averages_data <- ddply(alldata, .(subject, activity), function(x) colMeans(x[, 1:66]))

write.table(averages_data, "tidy_dataset.txt", row.name=FALSE)