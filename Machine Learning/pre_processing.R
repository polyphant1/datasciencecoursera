## preprocessing

library(caret)
library(kernlab)
data(spam)

inTrain <- createDataPartition(y=spam$type,p=0.75,list=FALSE)

training <- spam[inTrain,]
testing[-inTrain,]

hist(training$capitalAve,
     #main="",
     xlab="ave.capital run length")
# example of a very skewed variable
# difficult to predict with model based predictors

mean(training$capitalAve)
sd(training$capitalAve)
# standard deviation is much higher than the mean, indicating a much more varied variable

## Standardization
# this example demonstartes z-score normalisation
trainCapAve <- training$capitalAve
trainCapAveS <- (trainCapAve - mean(trainCapAve))/sd(trainCapAve)

mean(trainCapAveS)
sd(trainCapAveS)

## Standardixing the test set
# must use the mean and standard deviation from the training set to standardize the test set
testCapAve <- testing$capitalAve
testCapAveS <- (testCapAve - mean(trainCapAve))/sd(trainCapAve)

mean(testCapAveS)
sd(testCapAveS)

# can also use preProcess function to perform standardization
preObj <- preProcess(training[,-58],method=c("center","scale"))
trainCapAveS <- predict(preObj,training[,-58])$capitalAve

mean(trainCapAveS)
sd(trainCapAveS)

# ...and apply to test set
testCapAveS <- predict(preObj,testing[,-58])$capitalAve
mean(testCapAveS)

# can also apply preProcessing within the train command call
set.seed(32343)
modelFit <- train(type ~.,data=training,preProcess=c("center","scale"),method="glm")
modelFit

## there are also other approaches to preProcessing than centering and scaling
## BoxCox transformations take continous data and try to approximate it to a normal distribution
## they achive this by estimating a specific set of parameters using maximum likelihood
preObj <- preProcess(training[,-58],method=c("BoxCox"))
trainCapAveS <- predict(preObj,training[,-58])$capitalAve
par(mfrow=c(1,2))
hist(trainCapAveS)
# looks a lot more like a normal distribution than previously
# still doesn't take care of all the problems, still a stack at zero
qqnorm(trainCapAveS)
# chunk of values horizontal below -2 thoretical quantile
# this is due to the continuous distribution not taking care of repeat values very well

## Imputing data
#prediction algorithms are often not built to compute missing data
set.seed(13343)

# make some values NA
training$capAve <- training$capitalAve
selectNA <- rbinom(dim(training)[1],size=1,prob=0.05)==1
training$capAve[selectNA] <- NA

# Impute and standardize
preObj <- preProcess(training[,-58],method="knnImpute")
# performs K nearest neighbours imputation
# fills in missing values by looking at K nearest vectors that look most like the vector with the missing value
# and averages them to produce a predictor for the missing value
capAve <- predict(preObj,training[,-58])$capAve
# can now predict, as missing values substituted

capAveTruth <- training$capitalAve
capAveTruth <- (capAveTruth-mean(capAveTruth))/sd(capAveTruth)

# can compare imputed values to those there before substituting for NAs
quantile(capAve-capAveTruth)
# quite close correlation; imputation worked relatively well

# can look just at values imputed
quantile((capAve-capAveTruth)[selectNA])

# can look at non imputed values - difference between the two not that great
quantile((capAve-capAveTruth)[!selectNA])


## NOTES

# traing and test sets must be processed in the same way
# parameters created during testing must be used on the test set; you can't create parameters on the test set.











