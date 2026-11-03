# ==========================================
# 05 - Pure Premium 
# ==========================================

library(tidyverse)
library(MASS)

# Load frequency and severity models
source("R/03_frequency_model.R")
source("R/04_severity_model.R")

# Load policy-level data
policies <- read_csv("Data/cleaned_data.csv")

# Calculate predicted frequency and severity 

# Prepare Policy-level data for predictions 
pure_premium_data <- policies %>%
  filter(
    Exposure > 0, 
    Density > 0
  ) %>%
  drop_na(
    AgeGroup, VehicleAgeGroup, BonusMalus,
    VehPower, Area, Density, VehBrand, 
    VehGas, Region
  )

# Match factor levels to fitted model 
pure_premium_data <- pure_premium_data %>%
  mutate(
    AgeGroup = factor(AgeGroup, levels = levels(frequency_data$AgeGroup)),
    VehicleAgeGroup = factor(VehicleAgeGroup, levels = levels(frequency_data$VehicleAgeGroup)),
    VehPower = factor(VehPower, levels = levels(frequency_data$VehPower)),
    Area = factor(Area, levels = levels(frequency_data$Area)),
    VehBrand = factor(VehBrand, levels = levels(frequency_data$VehBrand)),
    VehGas = factor(VehGas, levels = levels(frequency_data$VehGas)),
    Region = factor(Region, levels = levels(frequency_data$Region))
  )

#Predict expected claim counts per policy 
pure_premium_data$PredictedClaims <- predict(
  negative_binomial_model, 
  newdata = pure_premium_data, 
  type = "response"
)

# Convert expected claim counts into annual frequency 
pure_premium_data$PredictedFrequency <-
  pure_premium_data$PredictedClaims / 
  pure_premium_data$Exposure

# Predict average claim severity 
pure_premium_data$PredictedSeverity <- predict(
  severity_model, 
  newdata = pure_premium_data, 
  type = "response"
)

# Calculate expected pure premium per policy year 

pure_premium_data <- pure_premium_data %>%
  mutate(
    PurePremium = PredictedFrequency * PredictedSeverity
  )

# Review Results 
summary(pure_premium_data$PurePremium)

# Calculate portfolio average pure premium 
portfolio_pure_premium <- weighted.mean(
  pure_premium_data$PurePremium,
  w = pure_premium_data$Exposure
)

print(portfolio_pure_premium)

# Save policy-level predictions

write_csv(
  pure_premium_data,
  "Outputs/Tables/policy_pure_premium.csv"
)

# Portfolio Summary 
portfolio_summary <- pure_premium_data %>%
  summarise(
    Total_Policies = n(),
    Total_Exposure = sum(Exposure),
    Observed_Claims = sum(ClaimNb),
    Observed_Frequency = sum(ClaimNb) / sum(Exposure),
    Average_Predicted_Frequency = weighted.mean(
      PredictedFrequency, Exposure
    ),
    Average_Predicted_Severity = weighted.mean(
      PredictedSeverity, Exposure
    ),
    Portfolio_Pure_Premium = weighted.mean(
      PurePremium, Exposure
    )
  )

# Display summary
print(portfolio_summary)

# Save summary
write_csv(
  portfolio_summary,
  "Outputs/Tables/portfolio_pricing_summary.csv"
)
