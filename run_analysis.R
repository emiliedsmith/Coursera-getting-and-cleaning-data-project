## Create one R script called run_analysis.R that does the following:
## 1)Merges the training and the test sets to create one data set.
## 2)Extracts only the measurements on the mean and standard deviation for each measurement.
## 3)Uses descriptive activity names to name the activities in the data set
## 4)Appropriately labels the data set with descriptive variable names.
## 5)From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##1) Merges the training and the test sets to create one data set.
#Download the file and put it in the data folder:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "exercise_data.zip")

#Unzip the file and check what is in the file
unzip("exercise_data.zip", exdir = "./data/exercise_data")
list.files("./data/exercise_data")
#[1] "UCI HAR Dataset"
#The files of interest are located in the"UCI HAR Dataset"

#Read Activity data
activity <- read.table("./data/exercise_data/UCI HAR Dataset/activity_labels.txt", header = FALSE)

#Read Features data
features <- read.table("./data/exercise_data/UCI HAR Dataset/features.txt", header = FALSE)

#Read Test Data
X_test <- read.table("./data/exercise_data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
y_test <- read.table("./data/exercise_data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
subject_test <- read.table("./data/exercise_data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)

#Read Training Data
X_train <- read.table("./data/exercise_data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
y_train <- read.table("./data/exercise_data/UCI HAR Dataset/train/y_train.txt", header = FALSE)
subject_train <- read.table("./data/exercise_data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)

#Name the columns of test and train according to the features
names(X_train) <- features$V2
names(X_test) <- features$V2

#Name the subject and activity columns:
names(subject_train) <- c("Subject")
names(subject_test) <- c("Subject")
names(y_test) <- c("Activity")
names(y_train) <- c("Activity")

#Combine activity and subject IDs to the test measurements (X_test)
test_subject_activity <- cbind(subject_test, y_test)
datatest <- cbind(test_subject_activity, X_test)

#Do the same for the training data
train_subject_activity<- cbind(subject_train, y_train)
datatrain <- cbind(train_subject_activity, X_train)

#Combine training and test data
alldata <- rbind(datatest, datatrain)

##2) Extracts only the measurements on the mean and standard deviation for each measurement. 
#Select columns with only std and mean
subfeatures <- grep("mean\\(\\)|std\\(\\)", features$V2, value = TRUE) 

#Select the data according to subfeatures while keeping the first 2 columns
subdata <- cbind(alldata[, 1:2], alldata[, subfeatures])

#3) Uses descriptive activity names to name the activities in the data set
#Label activity column
subdata$Activity <- as.character(subdata$Activity)
for (i in 1:6) {
  subdata$Activity[subdata$Activity == i] <- as.character(activity[i, 2])
}

#4) Appropriately labels the data set with descriptive variable names. 
#prefix t is replaced by time
#Acc is replaced by Accelerometer
#Gyro is replaced by Gyroscope
#prefix f is replaced by frequency
#Mag is replaced by Magnitude
#BodyBody is replaced by Body

names(subdata) = gsub("^t", "time", names(subdata))
names(subdata) = gsub("Acc", "Accelerometer", names(subdata))
names(subdata) = gsub("Gyro", "Gyroscope", names(subdata))
names(subdata) = gsub("f", "frequency", names(subdata))
names(subdata) = gsub("Mag", "Magnitude", names(subdata))
names(subdata) = gsub("BodyBody", "Body", names(subdata))

#5)From the data set in step 4, creates a second, independent tidy data set with the average of each variable
#for each activity and each subject.
library(reshape2)
#Melt subdata 
datamelt <- melt(subdata, id=c("Subject", "Activity"))

#Calculate mean per person and activity and write the new dataset into a text file
tidydata <- dcast(datamelt, Subject+Activity ~ variable, mean)
write.table(tidydata, file = "Tidydata.txt", row.names = FALSE)


