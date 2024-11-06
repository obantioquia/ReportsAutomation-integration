#!/bin/bash
echo "Inicio de ejecución de instrucciones"

cd ..
cd DeforestationData-back

# Rscript Scripts/IDEAM_dataSelenium.R
# Rscript Scripts/IDEAM_data_processing.R

# Rscript Scripts/GFW_data.R
# Rscript Scripts/GFW_data_matchIDEAM.R

# quarto render Reporte_pdf_dash.qmd
# Rscript Scripts/html_to_pdf_report.R

cd ..
cd Dashboard-webpage

# echo -e "\n" | quarto publish quarto-pub

git add .
git commit -m "Actualización datos reporte back"
git push origin main


cd ..
cd DeforestationData-back

# Rscript Scripts/EnvioCorreos.R

git add .
git commit -m "Actualización datos reporte back"
git push origin main
