## Data Manipulation ##

# combine tracking data across all weeks
tracking <- rbind(week1_2025, week2_2025, week3_2025,
                  week4_2025, week5_2025, week6_2025,
                  week7_2025, week8_2025, week9_2025)

rm(list = c("week1_2025", "week2_2025", "week3_2025", 
            "week4_2025", "week5_2025", "week6_2025", 
            "week7_2025", "week8_2025", "week9_2025"))

# join player datasets
players <- player_play_2025 |>
  left_join(players_2025, by = "nflId")

# join player data with plays for full supplemental dataset
supplemental <- players |>
  left_join(plays_2025, by = c("gameId", "playId"))

# subset for pass plays
pass_plays <- supplemental |>
  filter(isDropback == TRUE, wasRunningRoute == TRUE)

# man coverage
man_routes <- pass_plays |>
  filter(
    position %in% c("WR", "TE"),
    pff_manZone == "Man"
  )

# get data at snap
snap_tracking <- tracking |>
  filter(frameType == "SNAP")

# separate by offense
wr_snap <- snap_tracking |>
  inner_join(
    man_routes |>
      select(gameId, playId, nflId, position),
    by = c("gameId", "playId", "nflId")
  ) |>
  select(gameId, playId, wrId = nflId,
         wr_x = x, wr_y = y,
         wr_position = position)

# and defense
db_snap <- snap_tracking |>
  inner_join(
    players_2025 |>
      select(nflId, position),
    by = "nflId"
  ) |>
  filter(position %in% c("CB", "FS", "SS", "DB")) |>
  select(gameId, playId,
         dbId = nflId,
         db_x = x,
         db_y = y,
         db_position = position)

# distance matrix for coverage matchups
candidate_pairs <- wr_snap |>
  inner_join(
    db_snap,
    by = c("gameId", "playId"),
    relationship = "many-to-many"
  ) |>
  mutate(
    snap_distance =
      sqrt((wr_x - db_x)^2 +
             (wr_y - db_y)^2)
  )

# assign coverage pairs
assign_matchups <- function(df) {
  
  assignments <- list()
  
  while(nrow(df) > 0) {
    
    closest <- df |>
      slice_min(
        snap_distance,
        n = 1,
        with_ties = FALSE
      )
    
    assignments[[length(assignments)+1]] <- closest
    
    df <- df |>
      filter(
        wrId != closest$wrId,
        dbId != closest$dbId
      )
  }
  
  bind_rows(assignments)
}

wr_db_pairs <- candidate_pairs |>
  group_by(gameId, playId) |>
  group_modify(~assign_matchups(.x)) |>
  ungroup()

# get full receiver tracking data
wr_tracking <- tracking |>
  inner_join(
    wr_db_pairs |>
      select(gameId, playId, wrId, dbId),
    by = c(
      "gameId",
      "playId",
      "nflId" = "wrId"
    )
  )

# get full db tracking data
db_tracking <- tracking |>
  rename(
    dbId = nflId,
    db_x = x,
    db_y = y
  )

# join these 2 dfs
wr_db <- wr_tracking |>
  rename(
    wr_x = x,
    wr_y = y
  ) |>
  inner_join(
    db_tracking,
    by = c(
      "gameId",
      "playId",
      "frameId",
      "dbId"
    )
  )

# filter to during the play
wr_db <- wr_db |>
  filter(frameType.x == "AFTER_SNAP")

# get route progress
route_curves <- wr_db |>
  rename(
    wrId = nflId,
    wrName = displayName.x,
    dbName = displayName.y,
    wr_speed = s.x,
    db_speed = s.y
  ) |>
  group_by(gameId, playId, wrId) |>
  mutate(
    route_frame = row_number(),
    route_progress = route_frame / max(route_frame)
  ) |>
  ungroup()

# join route
route_curves <- route_curves |>
  left_join(
    supplemental |>
      select(gameId, playId, nflId, routeRan, position),
    by = c(
      "gameId",
      "playId",
      "wrId" = "nflId"
    )
  )

# create separation
route_curves <- route_curves |>
  mutate(
    separation = sqrt(
      (wr_x - db_x)^2 +
        (wr_y - db_y)^2
    )
  )

hist(route_curves$separation)

# cap at 20 yards for modeling
route_curves_model <- route_curves |>
  filter(separation <= 20)

# player metrics
player_profiles <- route_curves_model |>
  group_by(wrId, wrName, position) |>
  summarize(
    routes = n_distinct(
      paste(gameId, playId)
    ),
    
    release_sep =
      mean(
        separation[
          route_progress >= .10 &
            route_progress <= .25
        ],
        na.rm = TRUE
      ),
    
    mid_sep =
      mean(
        separation[
          route_progress >= .40 &
            route_progress <= .60
        ],
        na.rm = TRUE
      ),
    
    late_sep =
      mean(
        separation[
          route_progress >= .70 &
            route_progress <= .90
        ],
        na.rm = TRUE
      ),
    
    growth = late_sep - release_sep,
    
    avg_speed =
      mean(wr_speed, na.rm = TRUE)
  ) |>
  filter(routes >= 50) |>
  ungroup()

top_routes <- route_curves_model |>
  count(routeRan) |>
  slice_max(n, n = 6)

# plot of separation trends by route over time
ggplot(
  filter(route_curves_model,
         routeRan %in% top_routes$routeRan),
  aes(
    route_progress,
    separation,
    color = routeRan
  )
) +
  geom_smooth(
    se = FALSE,
    span = 0.2
  ) +
  labs(
    title = "Receiver Separation by Route Progression",
    subtitle = "Beyond initial distance from the defender at the snap,\nseparation typically builds steadily past the midway point of a route",
    x = "Route Progress",
    y = "Separation (yards)"
  )

## plot of player separation tendencies
library(ggrepel)
label_data <- bind_rows(
  slice_max(player_profiles, release_sep, n = 7),
  slice_min(player_profiles, release_sep, n = 7),
  slice_max(player_profiles, growth, n = 7),
  slice_min(player_profiles, growth, n = 7)
) |>
  distinct()

ggplot(
  player_profiles,
  aes(release_sep, growth)
) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    alpha = .5
  ) +
  geom_vline(
    xintercept = mean(player_profiles$release_sep),
    linetype = "dashed",
    alpha = .5
  ) +
  geom_point(
    alpha = .6,
    size = 2
  ) +
  geom_text_repel(
    data = label_data,
    aes(label = wrName),
    box.padding = .5,
    point.padding = .3,
    max.overlaps = Inf,
    seed = 123
  ) +
  labs(
    title = "Receiver Separation Profiles",
    subtitle = "Release separation vs. separation growth throughout the route",
    x = "Release Separation",
    y = "Separation Growth (Late - Early)"
  ) +
  theme_minimal()

## separation modeling

library(mgcv)

set.seed(123)

# convert route and position to factors
model_data <- route_curves_model |>
  filter(!is.na(routeRan)) |>
  mutate(
    routeRan = factor(routeRan),
    position = factor(position)
  )

# fit gam model
gam_sep <- gam(
  separation ~
    position +
    routeRan +
    s(route_progress) +
    wr_speed,
  data = model_data
)

summary(gam_sep)

# predict separation from the model and get separation over expected
route_curves_model <- route_curves_model |>
  mutate(
    expected_sep = predict(
      gam_sep,
      newdata = route_curves_model
    ),
    sep_over_exp = separation - expected_sep
  )

# get mean separation over expected
player_soe <- route_curves_model |>
  group_by(wrId, wrName, position) |>
  summarize(
    routes = n_distinct(
      paste(gameId, playId)
    ),
    sep_over_exp = mean(
      sep_over_exp,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) |>
  filter(routes >= 50) |>
  arrange(desc(sep_over_exp))

# overall leaderboard
head(player_soe, 20)

# wide receivers only
player_soe |>
  filter(position == "WR") |>
  head(15)

# tight ends only
player_soe |>
  filter(position == "TE") |>
  head(15)
