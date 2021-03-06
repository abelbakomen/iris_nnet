# we are going to train a neural network in to predict 
# species of plants in iris database

# libraries
library(neuralnet)
library(nnet)

# loading data
data(iris)
summary(iris)

# as reported in the summary, there is no na values
# and all attributes except Species are numerical and continuous
# but there are more than two species, so we'll make a multilable
# classification.

#######################################################
####               DATA PREPROCESSING              ####
#######################################################


##  Binarizing ##
# the first thing we have to do here is to binarize the attribute 
# species. It will lead us into three subattributes: 
# Speciescetosa, Speciesvirginica and Speciesversicolor 

species = class.ind(iris$Species)
name.species = paste("Species", colnames(species), sep="_")
name.species.old = colnames(species)
colnames(species) = name.species

data_set = cbind(iris[,-5],species)

# Normalizing
mins = apply(data_set, 2,min)
maxs = apply(data_set, 2,max)

scaled= as.data.frame(scale(data_set, center = mins,scale = maxs-mins))


# now we split the data set into a train set and a test set
index = sample(1:nrow(data_set), round(0.75*nrow(data_set)))

train_set = scaled[index,]
test_set= scaled[-index,]

# formula
n = names(train_set)
f = as.formula(paste(paste(n[n %in% name.species],collapse = "+"),"~", paste(n[!n %in% name.species], collapse = "+")))

#training neural network
nn = neuralnet(f,data = train_set, hidden = c(4,7,5), linear.output = F)

plot(nn,main="Iris multilayered perceptron for multilabel classification")


# Testing

Predict = compute(nn,test_set[, ! n %in% name.species])

Predict$net.result


species.original = apply(as.array(max.col(test_set[,name.species])),
                         1, function(x) name.species.old[x])

species.predict = apply(as.array(max.col(Predict$net.result)),
                         1, function(x) name.species.old[x])


cmp = cbind(species.original, species.predict )

tb = table(species.original,species.predict)

#plot(tb,col=c("green","blue","red"),main="Matrice de confusion")
tb

saveRDS(nn,file = "./results/nn.model")
nn = readRDS(file = "../iris/results/nn.model")
