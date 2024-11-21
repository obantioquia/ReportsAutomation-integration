#!/bin/bash
echo "Inicio de ejecución de instrucciones"

cd /Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back

# /usr/local/bin/Rscript Scripts/IDEAM_dataSelenium.R


run_selenium_script() {
  /usr/local/bin/Rscript Scripts/IDEAM_dataSelenium.R
}

try_run_script() {
  max_retries=5
  retry_count=0

  while [ $retry_count -lt $max_retries ]; do
    run_selenium_script
    if [ $? -eq 0 ]; then
      return 0  # Éxito
    else
      echo "Intento $((retry_count+1)) fallido. Reintentando en 5 segundos..."
      sleep 5
      retry_count=$((retry_count+1))
    fi
  done

  return 1  # Error después de reintentos
}

# Intentar ejecutar el script y manejar errores
if try_run_script; then
  echo "El script se ejecutó correctamente."
else
  echo "Fallo el script después de varios intentos."
  exit 1
fi


/usr/local/bin/Rscript Scripts/IDEAM_data_processing.R

/usr/local/bin/Rscript Scripts/GFW_data.R
/usr/local/bin/Rscript Scripts/GFW_data_matchIDEAM.R

/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto render Reporte_pdf_dash.qmd
/usr/local/bin/Rscript Scripts/html_to_pdf_report.R

cd /Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage

echo -e "\n" | /Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto publish quarto-pub

git add .
git commit -m "Actualización datos reporte back"
git push origin main


cd /Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back

/usr/local/bin/Rscript Scripts/EnvioCorreos.R

git add .
git commit -m "Actualización datos reporte back"
git push origin main
