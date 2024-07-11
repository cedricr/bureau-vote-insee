library(sf)
library(readr)
library(stringr)
library(dplyr)
library(purrr)
library(janitor)
library(glue)

contours = st_read("processed/all.geojson") |>
  select(
    codeDepartement, nomDepartement, codeCommune, nomCommune,
    codeBureauVote = numeroBureauVote
  ) |>
  st_set_crs(4326)

results = read_csv2("data/legi_2022_t1_bv.csv", locale = locale(encoding = "latin1")) |>
  clean_names() |>
  mutate(
    codeDepartement = case_when(
      code_du_departement == "ZA" ~ "971",
      code_du_departement == "ZB" ~ "972",
      code_du_departement == "ZC" ~ "973",
      code_du_departement == "ZD" ~ "974",
      code_du_departement == "ZM" ~ "976",
      .default = code_du_departement
    ),
    codeCommune = if_else(
      str_starts(codeDepartement, "97"),
      str_c(codeDepartement, str_sub(code_de_la_commune, 2)),
      str_c(codeDepartement, code_de_la_commune)
    ),
  ) |>
  select(
    codeDepartement,
    codeCommune,
    codeCirco = code_de_la_circonscription,
    nomCirco = libelle_de_la_circonscription,
    codeBureauVote = code_du_b_vote,
  )

contours_circo = contours |>
  left_join(results)

st_write(contours_circo, "processed/enriched.geojson",
  layer_options = c("RFC7946=YES", "WRITE_NAME=NO"),
  delete_dsn = TRUE
)
