# ==========================================
# 02 - EXPLORATORY DATA ANALYSIS
# ==========================================

library(tidyverse)
library(scales)

# Load cleaned data

policies <- read_csv("Data/cleaned_data.csv")

claims <- read_csv("Data/cleaned_claims.csv")

policy_experience <- read_csv(
  "Data/policy_experience.csv"
)

# Overall portfolio metrics

total_exposure <- sum(policies$Exposure)

total_claims <- sum(policies$ClaimNb)

total_losses <- sum(claims$ClaimAmount)

overall_frequency <- total_claims / total_exposure

overall_severity <- mean(claims$ClaimAmount)

overall_pure_premium <- total_losses / total_exposure

# Display results

portfolio_summary <- tibble(
  
  Metric = c(
    "Number of Policies",
    "Total Exposure",
    "Total Claims (Frequency Dataset)",
    "Total Individual Claims (Severity Dataset)",
    "Total Incurred Losses",
    "Claim Frequency",
    "Average Claim Severity",
    "Pure Premium from Severity Data"
  ),
  
  Value = c(
    nrow(policies),
    total_exposure,
    total_claims,
    nrow(claims),
    total_losses,
    overall_frequency,
    overall_severity,
    overall_pure_premium
  )
  
)

print(portfolio_summary)

#Claim Frequency by Driver Age 
frequency_by_age <- policies %>%
  
  group_by(AgeGroup) %>%
  
  summarise(
    
    Policies = n(),
    
    Exposure = sum(Exposure),
    
    Claims = sum(ClaimNb),
    
    Frequency = Claims / Exposure,
    
    .groups = "drop"
    
  )

print(frequency_by_age)

p1 <- ggplot(
  frequency_by_age,
  aes(x = AgeGroup, y = Frequency)
) +
  
  geom_col(fill = "steelblue") +
  
  labs(
    title = "Claim Frequency by Driver Age",
    x = "Driver Age Group",
    y = "Claims per Exposure Year"
  ) +
  
  theme_minimal()

print(p1)

ggsave(
  "Outputs/Figures/frequency_by_age.png",
  plot = p1,
  width = 8,
  height = 5
)

#Claim Frequency by Geographic Area
frequency_by_area <- policies %>%
  
  group_by(Area) %>%
  
  summarise(
    
    Exposure = sum(Exposure),
    
    Claims = sum(ClaimNb),
    
    Frequency = Claims / Exposure,
    
    .groups = "drop"
    
  )

print(frequency_by_area)

p2 <- ggplot(
  frequency_by_area,
  aes(x = Area, y = Frequency)
) +
  
  geom_col(fill = "darkorange") +
  
  labs(
    title = "Claim Frequency by Geographic Area",
    x = "Area",
    y = "Claims per Exposure Year"
  ) +
  
  theme_minimal()

print(p2)

ggsave(
  "Outputs/Figures/frequency_by_area.png",
  plot = p2,
  width = 8,
  height = 5
)

#Claim Severity by Geographic Area
claims_with_policy <- claims %>%
  
  inner_join(
    policies %>%
      select(
        IDpol,
        Area,
        Region,
        DrivAge,
        VehAge,
        BonusMalus,
        Density
      ),
    by = "IDpol"
  )

severity_by_area <- claims_with_policy %>%
  
  group_by(Area) %>%
  
  summarise(
    
    NumberOfClaims = n(),
    
    TotalLosses = sum(ClaimAmount),
    
    AverageSeverity = mean(ClaimAmount),
    
    MedianSeverity = median(ClaimAmount),
    
    .groups = "drop"
    
  )

print(severity_by_area)

p3 <- ggplot(
  severity_by_area,
  aes(x = Area, y = AverageSeverity)
) +
  
  geom_col(fill = "seagreen") +
  
  scale_y_continuous(
    labels = dollar_format()
  ) +
  
  labs(
    title = "Average Claim Severity by Geographic Area",
    x = "Area",
    y = "Average Claim Amount"
  ) +
  
  theme_minimal()

print(p3)

ggsave(
  "Outputs/Figures/severity_by_area.png",
  plot = p3,
  width = 8,
  height = 5
)

#Pure Premium by Driver Age
pure_premium_by_age <- policy_experience %>%
  
  group_by(AgeGroup) %>%
  
  summarise(
    
    Exposure = sum(Exposure),
    
    TotalLosses = sum(TotalClaimAmount),
    
    PurePremium = TotalLosses / Exposure,
    
    .groups = "drop"
    
  )

print(pure_premium_by_age)

# Examine claim amount distribution
summary(claims$ClaimAmount)

# Calculate selected percentiles
quantile(
  claims$ClaimAmount,
  probs = c(0.50, 0.75, 0.90, 0.95, 0.99, 0.995, 0.999),
  na.rm = TRUE
)

# Identify the 10 largest claims
claims %>%
  dplyr::arrange(dplyr::desc(ClaimAmount)) %>%
  dplyr::select(IDpol, ClaimAmount) %>%
  head(10)

# Calculate 99th percentile
claim_limit <- quantile(
  claims$ClaimAmount,
  0.99,
  na.rm = TRUE
)

#Create a log-scale Histogram
p4 <- ggplot(claims, aes(x = ClaimAmount)) +
  geom_histogram(
    bins = 50,
    fill = "darkseagreen",
    color = "white"
  ) +
  scale_x_log10() +
  labs(
    title = "Log-Scale Distribution of Individual Claim Amounts",
    subtitle = "Claim amounts displayed on a logarithmic scale",
    x = "Claim Amount (Log Scale)",
    y = "Number of Claims"
  ) +
  theme_minimal()

ggsave(
  "Outputs/Figures/claim_distribution_log.png",
  plot = p4,
  width = 10,
  height = 6
)
