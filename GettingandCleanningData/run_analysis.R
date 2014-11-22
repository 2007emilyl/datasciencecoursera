## run_analysis.R does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set.
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject

run_analysis <- function(){

    # Read the files
      
    path <- getwd()
    
    TestX <- data.table(read.table(file.path(path, "test", "X_test.txt")))
    TestY <- data.table(read.table(file.path(path, "test", "y_test.txt")))
    TestS <- data.table(read.table(file.path(path, "test", "subject_test.txt")))
    
    TrainX <- data.table(read.table(file.path(path, "train", "X_train.txt")))
    TrainY <- data.table(read.table(file.path(path, "train", "y_train.txt")))
    TrainS <- data.table(read.table(file.path(path, "train", "subject_train.txt")))
    
    # Merge the training and the test sets to one data set
    
    Total_S <- rbind(TrainS, TestS)
    Total_Y <- rbind(TrainY, TestY)
    Total_X <- rbind(TrainX, TestX)
    
    names(Total_S)<- c("subject")
    names(Total_Y)<- c("activityNum")
    
    dataSubject <- cbind(Total_S, Total_Y)
    dataAll <- cbind(dataSubject, Total_X)
    
    
    
    
}