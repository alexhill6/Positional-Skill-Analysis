## Data Manipulation ##

# combine tracking data across all weeks
tracking <- rbind(week1_2025, week2_2025, week3_2025,
                  week4_2025, week5_2025, week6_2025,
                  week7_2025, week8_2025, week9_2025)

# join player datasets
players <- player_play_2025 |>
  left_join(players_2025, by = "nflId")

# join player data with plays for full supplemental dataset
supplemental <- players |>
  left_join(plays_2025, by = c("gameId", "playId"))

# subset for pass plays
pass_plays <- supplemental |>
  filter(isDropback == TRUE, wasRunningRoute == TRUE)

# filter for only receivers and tight ends 
receivers <- pass_plays |>
  filter(position %in% c("WR", "TE")) |>
  distinct(gameId, playId, nflId, .keep_all = TRUE)

# filter for only defensive backs in primary coverage
defenders <- supplemental |>
  filter(!is.na(pff_primaryDefensiveCoverageMatchupNflId)) |>
  distinct(gameId, playId, nflId, .keep_all = TRUE)

# get receiver - defender coverage matchups
wr_db_pairs <- receivers |>
  inner_join(
    defenders |> 
      select(gameId, playId, dbId = nflId,
             pff_primaryDefensiveCoverageMatchupNflId),
    by = c("gameId", "playId",
           "nflId" = "pff_primaryDefensiveCoverageMatchupNflId")
  ) |>
  distinct(gameId, playId, nflId, dbId) |>
  group_by(gameId, playId, nflId) |>
  slice(1) |>
  ungroup()

# get receiver tracking data and join on receiver coverage matchups
wr_tracking <- tracking |>
  inner_join(
    wr_db_pairs |> select(gameId, playId, nflId),
    by = c("gameId", "playId", "nflId")
  )

# get defensive back tracking data and join on defensive back coverage matchups
db_tracking <- tracking |>
  inner_join(
    wr_db_pairs |> select(gameId, playId, dbId),
    by = c("gameId", "playId", "nflId" = "dbId")
  )

# combine these two dfs for separation modeling
wr_db <- wr_tracking |>
  rename(wr_x = x, wr_y = y) |>
  inner_join(
    db_tracking |> rename(db_x = x, db_y = y),
    by = c("gameId", "playId", "frameId")
  )

nrow(wr_db)
head(wr_db)
