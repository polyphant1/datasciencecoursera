---
title: "Covariate Creation"
author: "Christopher Lovell"
date: "Sunday, October 26, 2014"
output: pdf_document
---


## Introduction
There are two levels of covariate creation: transforming raw data in to a covariate, and transforming tidy covariates in to alternative forms.

### Raw Data -> Covariates
The balancing act is summarisation vs. information loss. More knowledge of a system you have the better the job you will do. Whn in doubt, err on the side of more features.

Feature selection can be automated, but should be done with caution.

### Tidy Covariates -> new covariates
Features you've already created on the dataset, transformed to make them more useful. 

The original building of the covariates should only be performed on the training set (otherwise you're at risk of overfitting).

## Example
First load the libraries and data, then split the Wage dataset in to training and testing sets.


```r
library(ISLR)
library(caret)
```

```
## Loading required package: lattice
## Loading required package: ggplot2
```

```r
data(Wage)

inTrain <- createDataPartition(y=Wage$wage,p=0.7,list=FALSE)

training <- Wage[inTrain,]
testing <- Wage[-inTrain,]
```

If we take a look at the jobclass variable, it is split in to Industrial and Information classes:

```r
table(training$jobclass)
```

```
## 
##  1. Industrial 2. Information 
##           1097           1005
```

These are factor, or qualitative, variables, and a machine learning algorithm may find them difficult to interpret in their extended current form, therefore we may wish to convert them to quantitative, or indicator, variables:


```r
dummies <- dummyVars(wage ~ jobclass,data=training)
head(predict(dummies,newdata=training))
```

```
##        jobclass.1. Industrial jobclass.2. Information
## 231655                      1                       0
## 11443                       0                       1
## 160191                      1                       0
## 11141                       0                       1
## 448410                      1                       0
## 229379                      1                       0
```

### Removing Zero Covariates
If a covariate is almost always true, for example 'Does the email contain characters?', you can remove it using the following:


```r
nsv <- nearZeroVar(training,saveMetric=TRUE)
nsv
```

```
##            freqRatio percentUnique zeroVar   nzv
## year        1.022989    0.33301618   FALSE FALSE
## age         1.138889    2.85442436   FALSE FALSE
## sex         0.000000    0.04757374    TRUE  TRUE
## maritl      3.083333    0.23786870   FALSE FALSE
## race        9.411765    0.19029496   FALSE FALSE
## education   1.425263    0.23786870   FALSE FALSE
## region      0.000000    0.04757374    TRUE  TRUE
## jobclass    1.091542    0.09514748   FALSE FALSE
## health      2.462932    0.09514748   FALSE FALSE
## health_ins  2.253870    0.09514748   FALSE FALSE
## logwage     1.142857   19.07706946   FALSE FALSE
## wage        1.142857   19.07706946   FALSE FALSE
```

The sex variable is all Male, therefore it has no variability and can be thrown out. The same applies to the Region variable.

### Spline basis
Basis functions allow non-linear regression fitting. they are contained in the _splines_ package.


```r
library(splines)
bsBasis <- bs(training$age,df=3)
tail(bsBasis)
```

```
##                 1          2           3
## [2097,] 0.3601465 0.07767866 0.005584740
## [2098,] 0.3063341 0.42415495 0.195763821
## [2099,] 0.4430868 0.24369776 0.044677923
## [2100,] 0.2436978 0.44308684 0.268537478
## [2101,] 0.3625256 0.38669397 0.137491189
## [2102,] 0.3928997 0.10423870 0.009218388
```

This function allows fitting of a third degree polynomial to the age data in the training set. It produces a dataframe with 3 columns, containing the original age data, age squared and age cubed.

### Fitting curves with splines
You can then pass this _bsBasis_ object to a linear fitting function against another variable in your training set, in this case wage. The plot shows the relationship between age and wage, along with a third order polynomial fit for the relationship.


```r
lm1 <- lm(wage ~ bsBasis,data=training)
plot(training$age,training$wage,pch=19,cex=0.5)
points(training$age,predict(lm1,newdata=training),col="red",pch=19,cex=0.5)
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png) 

### Splines on the test set
Must create coivariates on the test set using the exact same procedure as the training.


```r
head(predict(bsBasis,age=testing$age))
```

```
##               1         2          3
## [1,] 0.00000000 0.0000000 0.00000000
## [2,] 0.36252559 0.3866940 0.13749119
## [3,] 0.44221829 0.1953988 0.02877966
## [4,] 0.44308684 0.2436978 0.04467792
## [5,] 0.01793746 0.2044871 0.77705095
## [6,] 0.43081384 0.2910904 0.06556091
```

