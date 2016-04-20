#-----ANIMAL SHELTER DATA-----
#load libraries
library(ggplot2) #data viz
library(dplyr) #data manipulation
library(randomForest) #for classification
library(stringr)#for dates

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

#This code block is forked from Megan Risdal 
outcome <- train[1:26729, ] %>%
  group_by(AnimalType, OutcomeType) %>%
  

#Summary of outcomes (This code block is forked from Megan Risdal & edited by myself)
ggplot(outcome, aes(x = AnimalType, y = num_animals, fill = OutcomeType)) +
  geom_bar(stat = 'identity', position = 'fill', colour = 'white') +
  coord_flip() +
  labs(y = '% of Animals', 
       x = 'Animal',
       title = 'Outcomes: Cats & Dogs') + theme_bw()

#so test & train sets match
names(train)[1]="ID"

#Format Date
split<-str_split_fixed(train$DateTime," ", 2)
train$DateTime <- mdy(split[,1]) #lubridate
names(train)[3] <- "date"
train$time <- hm(split[,2])

#This code block is forked from Megan Risdal 
sex <- train[1:26729, ] %>%
  group_by(AnimalType, SexuponOutcome, OutcomeType) %>%
  summarise(num_animals = n())

#Summary of outcomes (This code block is forked from Megan Risdal & edited by myself)

ggplot(subset(sex,SexuponOutcome %in% c("Intact Female","Intact Male","Neutered Male","Spayed Female")), 
       aes(x = SexuponOutcome, y = num_animals, fill = OutcomeType)) +
  geom_bar(stat = 'identity', position = 'fill', colour = 'white') +
  facet_wrap(~AnimalType) +
  coord_flip() +
  labs(y = 'Proportion of Animals', 
       x = 'Animal',
       title = 'Outcomes by Sex: Cats & Dogs') + theme_bw() 
#Names
train$Name[4574]<-"No Name" # miscoded name causes error
train$Name[6553] <-"No Name"
train$Name[8306] <-"No Name"
train$Name[11693] <-"No Name"
train$Name[20444] <-"No Name"
train$Name[24755] <-"No Name"
train$Name<-ifelse(nchar(train$Name)== 0, "No Name", train$Name) #Assign "No Name" to animals with no name. 

#Animal Age
split<-str_split_fixed(train$AgeuponOutcome," ", 2) # split value and unit of time
split[,2]<-gsub("s","",split[,2]) #remove tailing "s"

#create a vector to multiply
multiplier <- ifelse(split[,2] == 'day', 1,
                     ifelse(split[,2] == 'week', 7,
                            ifelse(split[,2] == 'month', 30,  
                                   ifelse(split[,2] == 'year', 365, NA))))

train$days_old <- as.numeric(split[,1]) * multiplier #apply the multiplier
train$days_old[1:5] #compare, looks good
train$AgeuponOutcome[1:5]

str(train)

#Animal Breed
(unique(train$Breed)) #1379 unique breeds, let's narrow that down a bit

breed1<-str_split_fixed(train$Breed,"/",2) # split on "\" and keep first group
breed.simple<- gsub(" Mix","",breed1[,1]) # split on "Mix" and keep first breed
unique(breed.simple) # down to 220 breeds
train$breed.simple<-breed.simple

#Distribution of Age(in days) of the animals
age <- train[1:26729, ] %>%
  group_by(AnimalType,days_old, OutcomeType) %>%
  summarise(num_animals = n())


ggplot(age, aes(x= days_old, y = num_animals, fill=OutcomeType)) +
  geom_bar(stat = 'identity',position = 'fill', width=350)+ 
  facet_wrap(~AnimalType)+ 
  labs(y = 'Age (in days)', 
     x = 'Animal',
     title = 'Outcomes by Age: Cats & Dogs') + theme_bw() 

#Univariate Analysis
dim(train) #the dataset contains 26,729 observations and was given to us by the Austin Animal Shelter
str(train) #we have 9 predictor variables
levels(train$OutcomeType)

#Exploring the variables
names(train)
