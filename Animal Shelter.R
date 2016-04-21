#-----ANIMAL SHELTER DATA-----
#load libraries
library(ggplot2) #data viz
library(dplyr) #data manipulation
library(randomForest) #for classification
library(stringr)#for dates
library(ggthemes)
library(lubridate)


#------GET & EXPLORE THE DATA------
dir= ("/Users/etavares/Documents/Data Science/Kaggle/Animal_Shelter/")
setwd(dir)

train = read.csv("train.csv", stringsAsFactors = F)
#so test & train sets match
names(train)[1]="ID"
test = read.csv("test.csv", stringsAsFactors = F)
test$ID <- as.character(test$ID)

# Combine test & training data
train <- bind_rows(train, test)


train$OutcomeType<-as.factor(train$OutcomeType)
train$OutcomeSubtype<-as.factor(train$OutcomeSubtype)
train$AnimalType<-as.factor(train$AnimalType)
train$SexuponOutcome<-as.factor(train$SexuponOutcome)
train$SexuponOutcome<-as.factor(train$SexuponOutcome)

#This code block is forked from Megan Risdal 
outcome <- train[1:26729, ] %>%
  group_by(AnimalType, OutcomeType) %>%
  summarise(num_animals = n())
  

#Summary of outcomes (This code block is forked from Megan Risdal & edited by myself)
ggplot(outcome, aes(x = AnimalType, y = num_animals, fill = OutcomeType)) +
  geom_bar(stat = 'identity', position = 'fill', colour = 'white') +
  coord_flip() +
  labs(y = '% of Animals', 
       x = 'Animal',
       title = 'Outcomes: Cats & Dogs') + theme_bw()

#Format Date
split<-str_split_fixed(train$DateTime," ", 2)
train$DateTime <- mdy(split[,1]) #lubridate
names(train)[3] <- "date"
train$time <- hm(split[,2])

sex <- train[1:26729, ] %>%
  group_by(AnimalType, SexuponOutcome, OutcomeType) %>%
  summarise(num_animals = n())

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
train$Named<-ifelse(train$Name=="No Name",0,1) #Create a new variable detailing whether or not the animal was named. 


#Animal Age
split<-str_split_fixed(train$AgeuponOutcome," ", 2) # split value and unit of time
split[,2]<-gsub("s","",split[,2]) #remove tailing "s"

#create a vector to multiply
multiplier <- ifelse(split[,2] == 'day', 1,
                     ifelse(split[,2] == 'week', 7,
                            ifelse(split[,2] == 'month', 30,  
                                   ifelse(split[,2] == 'year', 365, NA))))

train$days_old <- as.numeric(split[,1]) * multiplier #apply the multiplier
sum(is.na(train$days_old)) #some missingness
train$days_old[is.na(train$days_old)] = mean(train$days_old, na.rm=TRUE) #impute missing values
train$days_old[1:5] #compare, looks good
train$AgeuponOutcome[1:5]

#Distribution of Age(in days) of the animals
age <- train[1:26729, ] %>%
  group_by(AnimalType,days_old, OutcomeType) %>%
  summarise(num_animals = n())

ggplot(age, aes(x= days_old, y = num_animals, fill=OutcomeType)) +
  geom_bar(stat = 'identity',position = 'fill', width=350)+ 
  facet_wrap(~AnimalType)+ 
  labs(y = '% of Animals', 
       x = 'Age (in days)',
       title = 'Outcomes by Age: Cats & Dogs') + theme_bw() 

#Puppy/Kitten Variable
hist(train$days_old)
train$young<-ifelse(train$days_old>=365,0,1) 
train
str(train)
#Animal Breed
(unique(train$Breed)) #1379 unique breeds, let's narrow that down a bit

breed1<-str_split_fixed(train$Breed,"/",2) # split on "\" and keep first group
breed.simple<- gsub(" Mix","",breed1[,1]) # split on "Mix" and keep first breed
unique(breed.simple) # down to 220 breeds but still too many for our algorithm (MAX factor levels for RF is 53

#Animal Color
color<-str_split_fixed(train$Color," ",2) # split on " " and keep first group
color<-color[,1] # split on " " and keep first color
color<-str_split_fixed(color,"/",2) #split on "/" 
color<-color[,1] # keep first group
train$color_simple<-as.factor(color) #treat color as factor

#Flagging Aggressive Breeds
breed <- train[1:26729, ] %>%
  group_by(AnimalType,breed_simple, OutcomeType, OutcomeSubtype) %>%
  summarise(num_animals = n())

ggplot(breed, aes(x= OutcomeType, y = num_animals, fill=OutcomeSubtype)) +
  geom_bar(stat = 'identity',position = 'fill')+ 
  facet_wrap(~AnimalType)+ 
  labs(y = '% of Animals', 
       x = 'Age (in days)',
       title = 'Outcomes by Age: Cats & Dogs') + theme_bw() 

#Univariate Analysis
dim(train) #the dataset contains 26,729 observations and was given to us by the Austin Animal Shelter
str(train) #we have 9 predictor variables
levels(train$OutcomeType)

#Exploring the variables
str(train)

#-----MODEL BUILDING-----

#Turn variables into factors
factorVars <- c('OutcomeType','OutcomeSubtype','AnimalType',
                'SexuponOutcome','AgeuponOutcome','breed_simple','color_simple','young')
train[factorVars] <- lapply(train[factorVars], function(x) as.factor(x))

#split training & testing
train <- train[1:26729, ]
test  <- train[26730:nrow(full), ]
str(train)
rf1<-randomForest(OutcomeType~AnimalType+days_old+color_simple+young+SexuponOutcome+Named,
                  data=train,importance=T, ntree=500, na.action=na.fail)
rf1
#reduction in error with forest size
plot(rf1, ylim=c(0,1))
legend('topright', colnames(rf1$err.rate), col=1:6, fill=1:6)

