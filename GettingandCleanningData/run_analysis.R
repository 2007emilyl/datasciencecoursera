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
    names(Total_Y)<- c("activityNo")
    
    dataSubject <- cbind(Total_S, Total_Y)
    dataAll <- cbind(dataSubject, Total_X)
    
    # set key to the data table
    
    setkey(dataAll, subject, activityNo)
    
    # Extract only the mean and standard deviation
    
    f <- data.table(read.table(file.path(path, "features.txt")))
    names(f) <- c("featNo","featName")
    
    # Extract the mean and std features only
    
    f1 <- f[grepl("mean\\(\\)|std\\(\\)", f$featName)]
    
    # Add col stored colname for mapping merged data set 
    
    f1$featCode <- f1[,paste0("V",f1$featNo)]
    
    # Subset these variables using variable names
    
    select <- c(key(dataAll), f1$featCode)
    dataAll <- dataAll[, select, with = FALSE]
    
    # Use descriptive activity names
    
    act_label <- data.table(read.table(file.path(path, "activity_labels.txt")))
    names(act_label) <- c("activityNo", "activityName")
    
    # Label with descriptive activity names
    
    dataAll <- merge(dataAll, act_label, by = "activityNo", all.x = TRUE)
    setkey(dataAll, subject, activityNo, activityName)
    
    # Melt the data table to reshape it from a short and wide format to a tall and narrow format

    dt <- data.table(melt(dataAll, key(dataAll), variable.name = "featCode"))
     
    # Merge features

    dt <- merge(dt, f1[, list(featNo, featCode, featName)], by = "featCode", all.x = TRUE)
    
    # Seperate features by abstract text from featName 
    
    absText <- function(t) {
            grepl(t, dt$featName)
    }

    ## Feature only with 1 category
    
    dt$featJerk <- factor(absText("Jerk"), labels = c(NA, "Jerk"))
    
    dt$featMagnitude <- factor(absText("Mag"), labels = c(NA, "Magnitude"))
    
    ## Feature with 2 categories
    
    n <- 2
    y <- matrix(seq(1, n), nrow = n)
    
    x <- matrix(c(absText("^t"), absText("^f")), ncol = nrow(y))
    dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
    
    x <- matrix(c(absText("Acc"), absText("Gyro")), ncol = nrow(y))
    dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
    
    x <- matrix(c(absText("BodyAcc"), absText("GravityAcc")), ncol = nrow(y))
    dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
    
    x <- matrix(c(absText("mean()"), absText("std()")), ncol = nrow(y))
    dt$featVariable <- factor(x %*% y, labels = c("Mean", "Std"))
    
    ## Feature with 3 categories
    n <- 3
    y <- matrix(seq(1, n), nrow = n)
    
    x <- matrix(c(absText("-X"), absText("-Y"), absText("-Z")), ncol = nrow(y))
    dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))

    # calculate average and assign to 2nd data set
    setkey(dt, subject, activityName, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
    dt1 <- dt[, list(count = .N, average = mean(value)), by = key(dt)]
    