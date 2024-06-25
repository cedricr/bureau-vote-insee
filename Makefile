.PHONY: all get-data clean

all: get-data processed/contours_bv_01.geojson export/contours_bureaux_vote.topojson
	
data/table-adresses-reu.csv:
	mkdir -p data
	curl https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-140445/table-adresses-reu.csv -o data/table-adresses-reu.csv

data/table-bv-reu.csv:
	mkdir -p data
	curl https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-135808/table-bv-reu.csv -o data/table-bv-reu.csv

data/ADMIN-EXPRESS.7z:
	mkdir -p data
	curl https://data.geopf.fr/telechargement/download/ADMIN-EXPRESS-COG-CARTO/ADMIN-EXPRESS-COG-CARTO_3-2__SHP_WGS84G_FRA_2024-02-22/ADMIN-EXPRESS-COG-CARTO_3-2__SHP_WGS84G_FRA_2024-02-22.7z -o data/ADMIN-EXPRESS.7z

data/COMMUNE.shp: data/ADMIN-EXPRESS.7z
	mkdir -p data
	7za e data/ADMIN-EXPRESS.7z -odata ADMIN-EXPRESS-COG-CARTO_3-2__SHP_WGS84G_FRA_2024-02-22/ADMIN-EXPRESS-COG-CARTO/1_DONNEES_LIVRAISON_2024-03-00171/ADECOGC_3-2_SHP_WGS84G_FRA-ED2024-02-22/
	touch data/COMMUNE.shp

get-data: data/table-adresses-reu.csv data/table-bv-reu.csv data/table-bv-reu.csv data/COMMUNE.shp

processed/contours_bv_01.geojson: 
	$(MAKE) get-data
	mkdir -p processed
	Rscript -e "renv::restore()"
	Rscript prepare_contours.R
	touch processed/contours_bv_01.geojson

export/contours_bureaux_vote.topojson: processed/contours_bv_01.geojson
	mkdir -p export
	npx mapshaper -i combine-files processed/contours_bv_* \
	-merge-layers \
	-o format=topojson export/contours_bureaux_vote.topojson

clean:
	rm -rf data export logs processed renv/library renv/staging .Rhistory
