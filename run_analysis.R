library(dplyr)

# Merge the training and test data sets
# Read common files
features <- read.table('features.txt')
activity <- read.table('activity_labels.txt')

# Read training sets and add column names for readabilty
x_train <- read.table("train/X_train.txt")
colnames(x_train) = features[,2]
y_train <- read.table("train/y_train.txt")
colnames(y_train) = "ActivityID"
subject_train <- read.table("train/subject_train.txt")
colnames(subject_train) = "SubID"

#read test sets and add column names for readabilty
x_test <- read.table("test/X_test.txt")
colnames(x_test) = features[,2]
y_test <- read.table("test/y_test.txt")
colnames(y_test) = "ActivityID"
subject_test <- read.table("test/subject_test.txt")
colnames(subject_test) = "SubID"

# create training data set
training_data <- cbind(subject_train, x_train, y_train)

# create test data set
test_data <- cbind(subject_test, x_test, y_test)

# Merged data set
merged_data = rbind(training_data,test_data);

# get only columns with mean() or std() in their names by seaching for mean or
# std in the names
mean_std_colnames <- features$V2[grep("mean\\(\\)|std\\(\\)", features$V2)]
subdata_cols = c(as.character(mean_std_colnames), 'SubID', 'ActivityID')
subdata = subset(merged_data, select = subdata_cols)

# Rename columns for activity
activity <- rename(activity, ActivityID = V1, Activity = V2)
final_data = merge(subdata, activity, by='ActivityID', all=TRUE)

# Rename the columns with descriptive names
names(final_data) <- gsub("^t", "Time", names(final_data))
names(final_data) <- gsub("^f", "Frequency", names(final_data))
names(final_data) <- gsub("Acc", "Accelerometer", names(final_data))
names(final_data) <- gsub("Gryo", "Gyroscope", names(final_data))
names(final_data) <- gsub("BodyBody", "Body", names(final_data))
names(final_data) <- gsub("Mag", "Magnitude", names(final_data))

# Create a tiny data set with means for each subject and activity and save it
# as tinydata.txt
tiny_data <- aggregate(. ~SubID + Activity, final_data, mean)
write.table(tiny_data, file = "tidydata.txt",row.name=FALSE)
