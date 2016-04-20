#-----ANIMAL SHELTER DATA-----
#load libraries
library(ggplot2) #data viz
library(dplyr) #data manipulation
library(randomForest) #for classification

#------GET & EXPLORE THE DATA------
dir= ("/Users/etavares/Documents/Data Science/Kaggle/Animal_Shelter/")
setwd(dir)

train = read.csv("train.csv", stringsAsFactors = F)
str(train)
train$OutcomeType<-as.factor(train$OutcomeType)
train$OutcomeSubtype<-as.factor(train$OutcomeSubtype)
train$AnimalType<-as.factor(train$AnimalType)
train$SexuponOutcome<-as.factor(train$SexuponOutcome)
train$SexuponOutcome<-as.factor(train$SexuponOutcome)
#train$AgeuponOutcome<-as.numeric(train$AgeuponOutcome)
head(train)

#so test & train sets match
names(train)[1]="ID"

#Univariate Analysis
dim(train) #the dataset contains 26,729 observations and was given to us by the Austin Animal Shelter
str(train) #we have 9 predictor variables
names(train)

#This code block is forked from Megan Risdal 
outcome <- train[1:26729, ] %>%
  group_by(AnimalType, OutcomeType) %>%
  summarise(num_animals = n())

#Summary of outcomes (#This code block is forked from Megan Risdal & edited)
ggplot(outcome, aes(x = AnimalType, y = num_animals, fill = OutcomeType)) +
  geom_bar(stat = 'identity', position = 'fill', colour = 'white') +
  coord_flip() +
  labs(y = '% of Animals', 
       x = 'Animal',
       title = 'Outcomes: Cats & Dogs') + theme_bw()

#Exploring the variables
names(train)
min(train$DateTime) 
max(train$DateTime)
str(train$OutcomeType)
summary(train$OutcomeType)
