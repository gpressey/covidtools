get_world_data <- function(){
  read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") %>%
    janitor::clean_names() %>%
    pivot_longer(cols = -province_state:-long) %>%
    rename(date = name) %>%
    mutate(date = str_remove(date, "^.") %>% lubridate::mdy())
}

get_canada_data <- function() {
  get_world_data() %>%
    filter(country_region == "Canada")
}

get_us_data <- function(){
  read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv") %>%
    janitor::clean_names() %>%
    select(-uid:-code3,-admin2, -combined_key) %>%
    pivot_longer(cols = -fips:-long) %>%
    rename(date = name) %>%
    mutate(date = str_remove(date, "^.") %>% lubridate::mdy())
}

get_us_county_population <- function(){
  read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv") %>%
    janitor::clean_names() %>%
    select(state,county,population =popestimate2019) %>%
    mutate(fips = paste0(state,county) %>% as.numeric()) %>%
    select(-state, -county)
}

get_canada_population <- function(){
  cancensus::list_census_regions(dataset = "CA16") %>%
    filter(level == "PR") %>%
    select(province_state = name, population = pop)
}

get_us_canada <- function(){
  df_us <- left_join(get_us_data(), get_us_county_population()) %>%
    group_by(province_state, country_region, date) %>%
    summarize(
      value = sum(value, na.rm = T),
      population = sum(population, na.rm = T)
    ) %>%
    filter(population != 0)

  df_canada <- left_join(get_canada_data(), get_canada_population()) %>%
    select(-lat, -long)

  bind_rows(df_us, df_canada) %>%
    na.omit()
}

clean_us_canada_covid_cases <- function(df){
  df %>%
    rename(total_cases = value) %>%
    group_by(province_state) %>%
    mutate(
      new_cases = total_cases - lag(total_cases, default = 0, order_by = date),
      total_confirmed_percent = total_cases / population,
      new_confirmed_percent = new_cases / population
    ) %>%
    ungroup()
}
