
# Introduction ------------------------------------------------------------

# Author: Dylan Groves, dgroves@poverty-action.org
# Date: 6/28/2019
# Title: Randomization for Pangani FM 2

# Table of Contents -------------------------------------------------------

# Loads Sample Data (Generated in Sampling Folder)
# Randomization
# Plot Map
# Balance Tests

# Libraries ---------------------------------------------------------------

library(data.table)
library(dismo)
library(dplyr)
library(geojsonio)
library(ggmap)
library(ggrepel)
library(ggplot2)
library(lubridate)
library(rgeos)
library(rgdal)
library(RColorBrewer)
library(sf)
library(sp)
library(spData)
library(tidyverse)

# Clear -------------------------------------------------------------------
rm(list=ls())

#Set your API Key
ggmap::register_google(key = "AIzaSyAzh5EMvmLELIQXvFJhbmD9pCD4vM_XPXA")

# Load Data ---------------------------------------------------------------
df <- read.csv("X:/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (efm)/01 Data/pfm2_villagesample_surveydates.csv")

df_small <- df %>%
  filter(Letter == "A", Letter == "a")


# Map ---------------------------------------------------------------------

map <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2565),
                         zoom = 10, scale = 2,
                         maptype ='terrain',
                         color = "bw"))

map <- map + geom_text(colour = "black", aes(label= Letter, fontface="bold", x = villcent_long, y = villcent_lat), 
                 data = df, size = 4) +
        ylab("") +
        xlab(expression(atop("A: Treatment Village in Block A", paste("a: Placebo Village in Block A"))))


ggsave("X:/Dropbox/Apps/Overleaf/Tanzania - Audio Screening (efm)/Figures/pfm2_map.pdf", plot = map, 
       width = 12, height = 8, units = "in")


