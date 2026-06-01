### EDA and Brainstorming ###

## Brainstorming ##

## Final two possibilities...

# Qb
# scramble ability / pocket elusiveness
#   Xy possibly when defenders are close
# 
# Wr / te
# getoff
#   Speed out of a route conditioned on coverage
# separation
#   Speed / comparative xy

## Brief EDA

library(tidyverse)
library(dplyr)
library(ggplot2)
library(here)

# 2024

# games_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'games.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# players_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'players.csv'),
#                          header = TRUE, stringsAsFactors = FALSE)
# plays_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'plays.csv'),
#                          header = TRUE, stringsAsFactors = FALSE)
# tackles_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tackles.csv'),
#                          header = TRUE, stringsAsFactors = FALSE)
# 
# week1_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_1.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week2_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_2.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week3_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_3.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week4_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_4.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week5_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_5.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week6_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_6.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week7_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_7.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week8_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_8.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# week9_2024 <- read.csv(here('nfl-big-data-bowl-2024', 'tracking_week_9.csv'),
#                        header = TRUE, stringsAsFactors = FALSE)
# 
# head(week1_2024)
# 
# summary(week1_2024)

# 2025

games_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'games.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
players_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'players.csv'),
                         header = TRUE, stringsAsFactors = FALSE)
plays_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'plays.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
player_play_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'player_play.csv'),
                         header = TRUE, stringsAsFactors = FALSE)

week1_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_1.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week2_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_2.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week3_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_3.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week4_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_4.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week5_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_5.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week6_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_6.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week7_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_7.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week8_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_8.csv'),
                       header = TRUE, stringsAsFactors = FALSE)
week9_2025 <- read.csv(here('nfl-big-data-bowl-2025', 'tracking_week_9.csv'),
                       header = TRUE, stringsAsFactors = FALSE)

head(week1_2025)

summary(week1_2025)

table(week1_2025$frameType)

### 2025 Data aligns well with WR/TE separation -> will go with that
