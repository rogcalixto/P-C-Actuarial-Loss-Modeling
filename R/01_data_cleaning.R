# ==========================================
# 01 - DATA CLEANING
# Personal Auto Insurance Pricing
# ==========================================

library(tidyverse)

# Set working directory
setwd("/Users/rogca/Downloads/Personal_Auto_Insurance_Pricing")

# Load original datasets
policies <- read_csv("Data/raw_data.csv")

claims <- read_csv("Data/claims_data.csv")

# Dataset dimensions
dim(policies)
dim(claims)

# Column names
names(policies)
names(claims)

# Structure
glimpse(policies)
glimpse(claims)

# Summary statistics
summary(policies)
summary(claims)

# ==========================================
# DATA QUALITY CHECKS
# ==========================================

# Missing values
colSums(is.na(policies))
colSums(is.na(claims))

# Duplicate policy records
sum(duplicated(policies$IDpol))

# Duplicate claim records
sum(duplicated(claims))

# Invalid exposure
sum(policies$Exposure <= 0, na.rm = TRUE)

# Invalid claim counts
sum(policies$ClaimNb < 0, na.rm = TRUE)

# Invalid claim amounts
sum(claims$ClaimAmount <= 0, na.rm = TRUE)

# Number of unique policies
n_distinct(policies$IDpol)

# Number of unique policies with claims
n_distinct(claims$IDpol)


# ==========================================
# CLEAN POLICY DATA
# ==========================================

policies_clean <- policies %>%
  
  distinct(IDpol, .keep_all = TRUE) %>%
  
  filter(
    !is.na(IDpol),
    !is.na(Exposure),
    Exposure > 0,
    !is.na(ClaimNb),
    ClaimNb >= 0,
    !is.na(DrivAge),
    !is.na(VehAge),
    !is.na(BonusMalus),
    !is.na(Area),
    !is.na(Density)
  ) %>%
  
  mutate(
    
    # Driver age classifications
    AgeGroup = case_when(
      DrivAge < 25 ~ "Young",
      DrivAge < 45 ~ "Adult",
      DrivAge < 65 ~ "Mature",
      TRUE ~ "Senior"
    ),
    
    # Vehicle age classifications
    VehicleAgeGroup = case_when(
      VehAge <= 2 ~ "New",
      VehAge <= 10 ~ "Intermediate",
      TRUE ~ "Old"
    ),
    
    AgeGroup = factor(
      AgeGroup,
      levels = c(
        "Adult",
        "Young",
        "Mature",
        "Senior"
      )
    ),
    
    VehicleAgeGroup = factor(
      VehicleAgeGroup,
      levels = c(
        "Intermediate",
        "New",
        "Old"
      )
    ),
    
    Area = factor(Area),
    VehBrand = factor(VehBrand),
    VehGas = factor(VehGas),
    Region = factor(Region)
    
  )

# ==========================================
# CLEAN CLAIM DATA
# ==========================================

claims_clean <- claims %>%
  
  filter(
    !is.na(IDpol),
    !is.na(ClaimAmount),
    ClaimAmount > 0
  )

# Aggregate claim information by policy

claims_by_policy <- claims_clean %>%
  
  group_by(IDpol) %>%
  
  summarise(
    
    ActualClaimCount = n(),
    
    TotalClaimAmount = sum(ClaimAmount),
    
    AverageSeverity = mean(ClaimAmount),
    
    .groups = "drop"
    
  )

# Combine policy and claims information

policy_experience <- policies_clean %>%
  
  left_join(
    claims_by_policy,
    by = "IDpol"
  ) %>%
  
  mutate(
    
    ActualClaimCount = replace_na(
      ActualClaimCount, 0L
    ),
    
    TotalClaimAmount = replace_na(
      TotalClaimAmount, 0
    )
    
  )

# Policies without matching claim records

unmatched_claims <- claims_clean %>%
  
  anti_join(
    policies_clean,
    by = "IDpol"
  )

nrow(unmatched_claims)

# Compare policy claim counts against
# claim records in the severity dataset

claim_comparison <- policy_experience %>%
  
  summarise(
    
    FrequencyDatasetClaims = sum(ClaimNb),
    
    SeverityDatasetClaims = sum(ActualClaimCount),
    
    Difference =
      FrequencyDatasetClaims - SeverityDatasetClaims
    
  )

print(claim_comparison)

# ==========================================
# SAVE CLEANED DATA
# ==========================================

write_csv(
  policies_clean,
  "Data/cleaned_data.csv"
)

write_csv(
  claims_clean,
  "Data/cleaned_claims.csv"
)

write_csv(
  policy_experience,
  "Data/policy_experience.csv"
)

cat("Data cleaning completed!\n")

cat("Policy records:", nrow(policies_clean), "\n")

cat("Individual claims:", nrow(claims_clean), "\n")

cat("Combined policy records:", nrow(policy_experience), "\n")