library(sf)
library(readr)
library(mapvotr)
library(future)
library(furrr)
library(stringr)
library(dplyr)
library(purrr)
library(glue)

departements = st_read("data/DEPARTEMENT.shp") |>
  st_drop_geometry() |>
  select(codeDepartement = INSEE_DEP, nomDepartement = NOM)

communes = st_read("data/COMMUNE.shp") |>
  select(
    codeCommune = INSEE_COM,
    nomCommune = NOM,
    codeDepartement = INSEE_DEP
  ) |>
  left_join(departements)


addresses = read.csv("data/table-adresses-reu.csv")

prep_adr <- prepare_address(
  address = addresses,
  contours_com = communes,
  var_cog1 = "code_commune_ref",
  var_cog2 = "codeCommune",
  var_bv1 = "id_brut_bv_reu",
  path_log = NULL
)

rm(addresses)
gc()

bureaux_vote = read_csv("data/table-bv-reu.csv") |>
  select(code_commune, id_brut_bv_reu = id_brut_reu, id_brut_miom)

MIN_POINT_COM = 50
MIN_ADDRESS_BV = 15
MIN_ADDRESS_SHOOT = 5


options(future.globals.maxSize = 3 * 1024 * 1024 * 1024)
plan(multicore, workers = 4)

departements = distinct(communes, codeDepartement)$codeDepartement
for (dept in departements) {
  path = glue("processed/contours_bv_{dept}.geojson")
  if (!file.exists(path)) {
    coms = communes |> filter(codeDepartement == dept)
    get_bv = function(n) {
      commune = coms[n, ]
      res = mapvotr::create_contours(
        prep_adr,
        commune$codeCommune,
        min_points_com = MIN_POINT_COM,
        min_address_bv = MIN_ADDRESS_BV,
        min_address_shoot = MIN_ADDRESS_SHOOT,
        var_cog1 = "code_commune_ref",
        var_cog2 = "codeCommune",
        var_bv1 = "id_brut_bv_reu",
        var_geo_score = "geo_score",
        var_nbaddress = "nb_adresses",
        path_log = glue("./logs/{commune$codeCommune}/")
      )$contours_simplified

      if (is.null(res)) {
        res = commune |>
          left_join(bureaux_vote, by = c("codeCommune" = "code_commune")) |>
          select(id_brut_miom)
      } else {
        res = res |>
          st_transform(4326) |>
          left_join(bureaux_vote) |>
          select(-code_commune, -id_brut_bv_reu)
      }

      res = res |>
        mutate(
          numeroBureauVote = str_pad(str_split_i(id_brut_miom, "_", 2), 4, "left", "0"),
          codeDepartement = commune$codeDepartement,
          nomDepartement = commune$nomDepartement,
          codeCommune = commune$codeCommune,
          nomCommune = commune$nomCommune
        ) |>
        rename(codeBureauVote = id_brut_miom)
    }

    all_contours = seq_len(nrow(coms)) %>%
      future_map(~ get_bv(.),
        .progress = TRUE,
        .options = furrr_options(seed = TRUE)
      )

    results = all_contours |>
      list_rbind() |>
      st_sf()

    st_write(results, path,
      layer_options = c("RFC7946=YES", "WRITE_NAME=NO"),
      delete_dsn = TRUE
    )
  }
}
