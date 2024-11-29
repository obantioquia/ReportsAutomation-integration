#!/bin/bash
echo "Inicio de ejecución de instrucciones"

# Navegación al repositorio DeforestationData-back
cd /Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back

# El siguiente ciclo evalua si la ejecución del script R que descarga la información
# del IDEAM se realiza sin problemas. No sale de ese programa hasta que todo
# se haga con éxito. 
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


# Ejecución del script que procesa los datos IDEAM
# /usr/local/bin/Rscript Scripts/IDEAM_data_processing.R

# Ejecución del script que consulta y procesa los datos de GFW, últimas dos
# semanas (GFW_data.R), y de las últimas dos semanas del IDEAM (GFW_data_matchIDEAM.R).
/usr/local/bin/Rscript Scripts/GFW_data.R
/usr/local/bin/Rscript Scripts/GFW_data_matchIDEAM.R

# Instrucción que renderiza el archivo quarto que genera html básico del reporte
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto render Reporte_pdf_dash.qmd

# Convierte el reporte html generado antes a un formato pdf
/usr/local/bin/Rscript Scripts/html_to_pdf_report.R

# Navegación al repositorio Dashboard-webpage 
cd /Users/investigadora/Desktop/OBA_REPORTES_GFW/Dashboard-webpage

# Publicación del dashboard-webpage en quarto
echo -e "\n" | /Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto publish quarto-pub

# Agregar cambios al repositorio remoto de Dashboard-webpage con git
git add .
git commit -m "Actualización datos reporte back"
git push origin main

# Navegación al repositorio DeforestationData-back
cd /Users/investigadora/Desktop/OBA_REPORTES_GFW/DeforestationData-back

# Ejecución de script EnvioCorreos.R
/usr/local/bin/Rscript Scripts/EnvioCorreos.R

# Agregar cambios al repositorio remoto de DeforestationData-back con git
git add .
git commit -m "Actualización datos reporte back"
git push origin main
