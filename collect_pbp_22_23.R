### FUNCTIONS ###
library(tidyverse)
library(glue)
library(data.table)
library(jsonlite)
library(rvest)
library(reshape2)
library(zoo)

team_abbr <- c("ANA","ARI","ATL","BOS","BUF","CGY","CAR","CHI","COL","CBJ","DAL","DET","EDM","FLA","LAK","MIN","MTL","NSH","NJD","NYI","NYR","OTT","PHI","PIT","SJS","SEA","STL","TBL","TOR","UTA","UTA","VAN","VGK","WSH","WPG")
team_names <- c("Anaheim Ducks","Arizona Coyotes","Atlanta Thrashers","Boston Bruins","Buffalo Sabres","Calgary Flames","Carolina Hurricanes","Chicago Blackhawks","Colorado Avalanche","Columbus Blue Jackets","Dallas Stars","Detroit Red Wings","Edmonton Oilers","Florida Panthers","Los Angeles Kings","Minnesota Wild","Montreal Canadiens","Nashville Predators","New Jersey Devils","New York Islanders","New York Rangers","Ottawa Senators","Philadelphia Flyers","Pittsburgh Penguins","San Jose Sharks","Seattle Kraken","St. Louis Blues","Tampa Bay Lightning","Toronto Maple Leafs","Utah Hockey Club","Utah Mammoth","Vancouver Canucks","Vegas Golden Knights","Washington Capitals","Winnipeg Jets")
teamId <- c(24,53,11,6,7,20,12,16,21,29,25,17,22,13,26,30,8,18,1,2,3,9,4,5,28,55,19,14,10,59,68,23,54,15,52)
team_table <- data.frame(team_abbr,team_names,teamId)


`%not_in%` <- Negate(`%in%`)
#xg_model_5v5 <- readRDS("xg_model_5v5.rds")
#xg_model_st <- readRDS("xg_model_st.rds")
xg_prep <- function(x){
}
calculate_xg <- function(x){
}
game_scraper <- function(game_id){
}
game_scraper_html <- function(game_id){
}
schedule <- function(date){
}
league_schedule <- function(start,end){
}
player <- function(id){
}

### GET PBPs ###
schedule_22_23 <- league_schedule("2022-10-05","2023-04-17")
pbp <- game_scraper_html(2022020001)
completed_games <- schedule_22_23 %>% filter(home_score+away_score>0)
games_to_scrape <- setdiff(completed_games$game_id,unique(pbp$game_id))

if(length(games_to_scrape)>0){
  for(i in 1:length(games_to_scrape)){
    skip_to_next <- FALSE
    print(i)
    game <- games_to_scrape[i]
    game_data <- tryCatch(game_scraper_html(game), error = function(e) { skip_to_next <<- TRUE})
    if(skip_to_next) { next }
    if(sum(is.na(game_data$home_on_1)) < 40){pbp <- rbind(pbp,game_data)}
  }
  
  games_to_scrape <- setdiff(completed_games$game_id,unique(pbp$game_id))
  
  if(length(games_to_scrape)>0){
    for(i in 1:length(games_to_scrape)){
      skip_to_next <- FALSE
      print(i)
      game <- games_to_scrape[i]
      game_data <- tryCatch(game_scraper(game), error = function(e) { skip_to_next <<- TRUE})
      if(skip_to_next) { next }
      pbp <- rbind(pbp,game_data)
    }
  }
  
  pbp <- pbp %>% arrange(event_idx)
}
missing_22_23 <- setdiff(completed_games$game_id,unique(pbp$game_id))
pbp %>% saveRDS("data/pbp_22_23.rds")
rm(schedule_22_23,pbp,completed_games,games_to_scrape)
print(missing_22_23)
