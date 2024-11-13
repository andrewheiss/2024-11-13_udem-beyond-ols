library(tidyverse)
library(countrycode)
library(WDI)
library(bayesrules)


# Equality for Poisson
data(equality_index, package = "bayesrules")

equality <- equality_index |> 
  # Omit California because it has so many laws already
  filter(state != "california")

saveRDS(equality, here::here("data", "data-processed", "equality.rds"))


# Maternal tetanus protection at birth (PAB) shots for Beta
# Data via the WHO via Kaggle
# https://www.kaggle.com/datasets/lsind18/who-immunization-coverage
indicators <- c(population = "SP.POP.TOTL",  # Population
  gdp_per_cap = "NY.GDP.PCAP.KD")  # GDP per capita

wdi_raw <- WDI(country = "all", indicators, extra = TRUE, 
  start = 1980, end = 2020)

tetanus_pab <- read_csv(here::here("data", "data-raw", "immunizations", "PAB.csv")) |> 
  pivot_longer(
    cols = -Country, 
    names_to = "year", values_to = "prop_pab", 
    names_transform = as.integer, values_transform = \(x) x / 100
  ) |> 
  mutate(iso3c = countrycode(Country, origin = "country.name", destination = "iso3c")) |> 
  left_join(wdi_raw, by = join_by(year, iso3c)) |> 
  mutate(region = case_when(country == "Viet Nam" ~ "East Asia & Pacific", .default = region))

saveRDS(tetanus_pab, here::here("data", "data-processed", "tetanus_pab.rds"))
