# covidtools
Pulls and cleans CSSEGIS data for US, Canada, and world. Adds relevant population statistics.

# use

Requires tidyverse. Needs initialized `cancensus` to get Canadian population information (see mountainmath/cancensus).

## covid statistics

Pulls most recent CSSEGIS data.

* Worldwide data: `get_world_data()`. Does not include USA data. Includes subnational levels (e.g., provinces) where available.
* Canada data: `get_canada_data()`. Aggregated at provincial level.
* USA data: `get_us_data()`. At the FIPS level, unaggregated.

Use `get_us_canada()` to extract state- and province-level data by date. Population statistics are automatically appended (see below). To create a data_frame with helpful variables like new cases by day, population percentages, pass the results into `clean_us_canada_covid_cases(df)`.

## population statistics.

Use `get_canada_population()` (requires `cancensus`) and `get_us_county_population()` to get population statistics by province and FIPS.
