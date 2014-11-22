run_analysis.R
===================

Instructions for project
------------------------
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

run_analysis.R will do the following:

> 1. Merges the training and the test sets to create one data set.
> 2. Extracts only the measurements on the mean and standard deviation for each measurement.
> 3. Uses descriptive activity names to name the activities in the data set.
> 4. Appropriately labels the data set with descriptive variable names.
> 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject


Get the data
------------
Download the file. Put it in the folder and unzip the file under folder "D:/MyCourse/.../Project/UCI HAR Dataset".

Read the files
--------------
read training and test data sets

	path <- getwd()
    
    TestX <- data.table(read.table(file.path(path, "test", "X_test.txt")))
    TestY <- data.table(read.table(file.path(path, "test", "y_test.txt")))
    TestS <- data.table(read.table(file.path(path, "test", "subject_test.txt")))
    
    TrainX <- data.table(read.table(file.path(path, "train", "X_train.txt")))
    TrainY <- data.table(read.table(file.path(path, "train", "y_train.txt")))
    TrainS <- data.table(read.table(file.path(path, "train", "subject_train.txt")))

Merge the training and the test sets to one data set
----------------------------------------------------
Concatenate the data tables
    
    Total_S <- rbind(TrainS, TestS)
    Total_Y <- rbind(TrainY, TestY)
    Total_X <- rbind(TrainX, TestX)
    
    names(Total_S)<- c("subject") 
    names(Total_Y)<- c("activity")
    
Merge columns

    dataSubject <- cbind(Total_S, Total_Y)
    dataAll <- cbind(dataSubject, Total_X)

Set key

    setkey(dataAll, subject, activity)


Extract only the mean and standard deviation
--------------------------------------------
Read the `features.txt` file. This tells which variables in `dataAll` are measurements for the mean and standard deviation.
    
    f <- data.table(read.table(file.path(path, "features.txt")))
    names(f) <- c("feaNo","feaName")
    
Extract the mean and std features only
    
    f <- f[grepl("mean\\(\\)|std\\(\\)", f$feaName]
    
Add col stored colname for mapping merged data set 
    
    f$feaCode <- f[,paste0("V",f$feaNo)]
    
Subset these variables using variable names.
    
    select <- c(key(dataAll), f$feaCode)
    dataAll <- dataAll[, select, with = FALSE]

    
Use descriptive activity names
------------------------------

Read `activity_labels.txt` file. This will be used to add descriptive names to the activities.
