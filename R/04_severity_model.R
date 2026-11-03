# ==========================================
# 04 - Severity Modeling 
# ==========================================


# 04_severity_model.R
# Claim Severity Modeling - Gamma GLM

library(tidyverse)

# Load cleaned policy and claims data
policies <- read_csv("Data/cleaned_data.csv")
claims <- read_csv("Data/cleaned_claims.csv")

# Prepare severity modeling dataset
severity_data <- claims %>%
  filter(ClaimAmount > 0) %>%
  inner_join(
    policies,
    by = "IDpol"
  ) %>%
  drop_na(
    ClaimAmount,
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

# Inspect severity modeling data
dim(severity_data)
summary(severity_data$ClaimAmount)

#Fitting Gamma Model with log link
severity_model <- glm(
  ClaimAmount ~
    AgeGroup +
    VehicleAgeGroup +
    BonusMalus + 
    VehPower + 
    Area +
    log(Density) +
    VehBrand +
    VehGas +
    Region, 
  family = Gamma(link = "log"), 
  data = severity_data
)

#Review Model results 
summary(severity_model)

# Generate predicted claim severity
severity_data$PredictedSeverity <- predict(
  severity_model,
  type = "response"
)

# Calculate actual and predicted average severity
observed_severity <- mean(severity_data$ClaimAmount)

predicted_severity <- mean(severity_data$PredictedSeverity)

print(observed_severity)
print(predicted_severity)
#Relative Difference of 2.26% 

# Calculate model deviance
print(deviance(severity_model))
print(AIC(severity_model))

#Calculating Pearson Dispersion Stat
severity_residuals <- residuals(
  severity_model,
  type = "pearson"
)

severity_dispersion <- sum(severity_residuals^2) /
  df.residual(severity_model)

print(severity_dispersion)
#Value of 27.21 (very high) 

# Examine extreme claim amounts
severity_data %>%
  summarise(
    Total_Claims = n(),
    Mean_Claim = mean(ClaimAmount),
    Median_Claim = median(ClaimAmount),
    P95 = quantile(ClaimAmount, 0.95),
    P99 = quantile(ClaimAmount, 0.99),
    P999 = quantile(ClaimAmount, 0.999),
    Maximum = max(ClaimAmount)
  )

# Percentage of total losses from claims above the 99th percentile

p99 <- quantile(severity_data$ClaimAmount, 0.99)

extreme_claim_share <- severity_data %>%
  summarise(
    Percentage = sum(ClaimAmount[ClaimAmount > p99]) /
      sum(ClaimAmount) * 100
  )

print(extreme_claim_share)
# 38% of total losses come from the highest 1% of claims

# Model limitation:
# The Gamma severity model exhibits overdispersion,
# with a Pearson dispersion statistic of 27.21.
# Extreme claims contribute to substantial variability
# in claim amounts. All claims are retained to preserve
# the integrity of the original insurance experience.
