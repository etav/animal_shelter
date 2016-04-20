# Animal_shelter
### The Dataset  
Some R code for a kaggle competition I entered. The goal was to create a classifier to predict the outcome of a sheltered animal using features provided for us. The training dataset contains 26,729 observations, 9 predictor variables and was given to us by the Austin Animal Shelter.

###Exploratory Analysis
Before I dive into creating a classifier, I typically performa exploratory analysis moving from observing one univariate statistics to bivariate statistics and finally model building.

However, I broke from my normal process as curiosity got the best of me. I was interested in learning about what the typical outcomes are for sheltered animals (check out the graph below).

![Image of Outcomes]
(https://github.com/etav/animal_shelter/blob/master/img/outcomes.png)

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
