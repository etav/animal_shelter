# Animal_shelter
### The Dataset  
Some R code for a kaggle competition I entered. The goal was to create a classifier to predict the outcome of a sheltered animal using features provided for us. The training dataset contains 26,729 observations, 9 predictor variables and was given to us by the Austin Animal Shelter.

###Exploratory Analysis
Before I dive into creating a classifier, I typically performa exploratory analysis moving from observing one univariate statistics to bivariate statistics and finally model building.

However, I broke from my normal process as curiosity got the best of me. I was interested in learning about what the typical outcomes are for sheltered animals (check out the graph below).

![Image of Outcomes]
(https://github.com/etav/animal_shelter/blob/master/img/outcomes_by_animal.png)

Luckily, as we see above, many animals are either adopted, transferred or in the case of dogs frequently returned to their owners.  

###The Variables

Variable Name | Description
------------ | -------------
ID | The animal's unique ID.
Name | The animal's name, if known (many are not).
DateTime | The date and time the animal entered the shelter (ranges from 1/1/14 - 9/9/15).
OutcomeType | A five factor variable detailing the outcome for the animal (ie: adopted,transferred, died).
OutcomeSubtype | 17 factor variable containing Further details related to the outcome of the animal, such as whether or not they were aggressive.
AnimalType | Whether the animal is a cat or dog.
SexuponOutcome | The sex of the animal at the time the outcome was recorded.
AgeuponOutcome| The age of the animal when the outcome was recorded.
Breed | The breed of the animal (contains mixed breed).
Color | A Description of the coloring on the animal.

###Transforming Variables

The first thing I did was transform the date variable by separating time and date so that I can analyze them independently, I'd like to be able to compare time of day and any seasonality effects on adoption. I then moved on to address missing name values (there were a few mis-codings which caused errors). After that I moved onto transforming the "AgeuponOutcome" variable so that the reported age of animals would all be in the same units, I chose days. This took some chaining of ifelse statements, check it out here:

####Animal's Age
```R
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
```

After this transformation, we're able to create a visualization which tells us the outcome of each animal type as a function of its age (in days).

![Image of Age&Outcomes]
(https://github.com/etav/animal_shelter/blob/master/img/age&outcome.png)

Interestingly the likelihood of being adopted for cats varies with age whereas for dogs there appears to be a slight negative correlation between a dog's age and the probability it will be adopted.

For dogs, it seems older animals tend to have a higher likelihood of being returned to their owner (I assume this is has to do with the proliferation of chips for animals)
