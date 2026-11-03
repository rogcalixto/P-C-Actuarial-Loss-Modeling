# ==========================================
# 03 - CLAIM FREQUENCY MODEL
# ==========================================

library(tidyverse)

#Load cleaned policy data
policies <- read_csv("Data/cleaned_data.csv")

#Prepare modeling dataset
frequency_data <- policies %>%
  filter(
    Exposure > 0, 
    ClaimNb >= 0, 
    Density > 0 
  ) %>% 
  drop_na(
    ClaimNb, 
    Exposure, 
    AgeGroup, 
    VehicleAgeGroup, 
    BonusMalus, 
    VehPower, 
    Area, 
    Density, 
    VehBrand, 
    VehGas, 
    Region
  ) %>%
  mutate(
    AgeGroup = factor(AgeGroup), 
    VehicleAgeGroup = factor(VehicleAgeGroup),
    VehPower = factor(VehPower),
    Area = factor(Area),
    VehBrand = factor(VehBrand),
    VehGas = factor(VehGas),
    Region = factor(Region)
  )

#Examine Modeling dataset 
dim(frequency_data)
summary(frequency_data$ClaimNb)
summary(frequency_data$Exposure)

#Observed Claim Frequency 
observed_frequency <- sum(frequency_data$ClaimNb) / 
  sum(frequency_data$Exposure)

print(observed_frequency)

#Fitting a Poisson GLM 
frequency_model <- glm(
  ClaimNb ~
    AgeGroup +
    VehicleAgeGroup +
    BonusMalus +
    VehPower +
    Area +
    log(Density) +
    VehBrand +
    VehGas +
    Region +
    offset(log(Exposure)), 
  family = poisson(link = "log"), 
  data = frequency_data
)
#Results 
summary(frequency_model)

#Check for overdispersion 
dispersion <- sum(
  residuals(frequency_model, type = "pearson")^2
) / df.residual(frequency_model)

print(dispersion)
#Value was 1.814033, indicating overdispersion in Model

#Attempting a Negative Binomial Model 
library(MASS)

negative_binomial_model <- glm.nb(
  ClaimNb ~ AgeGroup + VehicleAgeGroup + BonusMalus +
    VehPower + Area + log(Density) + VehBrand +
    VehGas + Region + offset(log(Exposure)),
  data = frequency_data
)

summary(negative_binomial_model)

#Compare both Models Using AIC 
AIC(frequency_model, negative_binomial_model)
# Poisson 215,462.7 vs. Neg. Binomial 214,819.4 
#Moving Forward we wil use the Neg. Binomial Model 

# Calculate Pearson residual dispersion
nb_dispersion <- sum(
  residuals(negative_binomial_model, type = "pearson")^2
) / df.residual(negative_binomial_model)

print(nb_dispersion)

# Compare observed and predicted claim frequency
frequency_data$PredictedClaims <- predict(
  negative_binomial_model,
  type = "response"
)

observed_frequency <- sum(frequency_data$ClaimNb) /
  sum(frequency_data$Exposure)

predicted_frequency <- sum(frequency_data$PredictedClaims) /
  sum(frequency_data$Exposure)

print(observed_frequency)
print(predicted_frequency)
#Approximated difference of 0.53% in claim frequency 


