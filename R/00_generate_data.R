# Install dependencies
install.packages(c("xts", "zoo"))

# Install CASdatasets
install.packages(
  "CASdatasets",
  repos = "https://cas.uqam.ca/pub/",
  type = "source"
)

# Load package
library(CASdatasets)
library(tidyverse)

# Load frequency data
data("freMTPL2freq")

# Load severity data
data("freMTPL2sev")

# Convert to data frames
policies <- as_tibble(freMTPL2freq)

claims <- as_tibble(freMTPL2sev)

# Examine datasets
glimpse(policies)

glimpse(claims)

# Check dimensions
dim(policies)

dim(claims)

# Save original datasets
write_csv(
  policies,
  "Data/raw_data.csv"
)

write_csv(
  claims,
  "Data/claims_data.csv"
)