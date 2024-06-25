all: init get-data processed/contours_bv_01.geojson export/contours_bureaux_vote.topojson

init:
	Rscript -e "renv::restore()"

clean:
	rm -rf data export logs processed renv/library renv/staging .Rhistory

get-data: data/table-adresses-reu.csv data/table-bv-reu.csv data/table-bv-reu.csv data/COMMUNE.shp

processed/contours_bv_01.geojson: get-data
	mkdir -p processed
	Rscript prepare_contours.R

data/table-adresses-reu.csv:
	mkdir -p data
	curl https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-140445/table-adresses-reu.csv -o data/table-adresses-reu.csv

data/table-bv-reu.csv:
	mkdir -p data
	curl https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-135808/table-bv-reu.csv -o data/table-bv-reu.csv

data/COMMUNE.shp: data/ADMIN-EXPRESS.7z
	mkdir -p data
	7za e data/ADMIN-EXPRESS.7z -odata/ ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2024-06-19/ADMIN-EXPRESS/1_DONNEES_LIVRAISON_2024-06-00166/ADE_3-2_SHP_WGS84G_FRA-ED2024-06-19/
	touch data/COMMUNE.shp

data/ADMIN-EXPRESS.7z:
	mkdir -p data
	curl https://data.geopf.fr/telechargement/download/ADMIN-EXPRESS/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2024-06-19/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2024-06-19.7z -o data/ADMIN-EXPRESS.7z

export/contours_bureaux_vote.topojson: processed/contours_bv_01.geojson
	mkdir -p export
	npx mapshaper -i combine-files processed/contours_bv_* \
	-merge-layers \
	-o format=topojson export/contours_bureaux_vote.topojson
