
################################### CURSO DE ECONOMETRÍA DE SERIES DE TIEMPO 2025 ##################################################

#################### DEFINICION DE DIRECTORIO, CARGA DE ARCHIVOS Y PAQUETES ########################################################

## Establecemos el directorio de trabajo donde se encuentran nuestros archivos /

  # Verificamos que el directorio se haya definido correctamente

## Cargamos los paquetes necesarios para manipular datos y leer archivos Excel
library(tidyverse)
library(readxl)

## Importamos los datos desde un archivo Excel. Usamos "skip = 9" para omitir las primeras filas con títulos y notas.
inf <- read_excel("Anexo_Estadístico_del_Informe_Económico_07_05_2025 (1).xlsx", 
                  sheet = "CUADRO 9", skip = 9) 

inf <- inf[-1]  # Eliminamos la primera columna vacía (típico en Excel exportado desde PDFs u otras fuentes)
names(inf)[1] <- "mes"  # Renombramos la primera columna a "mes"
inf$mes <- seq(from = as.Date("1994-01-01"), by = "month", length.out = nrow(inf)) # Creamos una secuencia de fechas mensuales iniciando en enero de 1994, tantas como filas tenga el dataset
inf <- inf[1:(nrow(inf) - 3), ]  # Eliminamos las últimas 3 filas que pueden contener totales, notas o NA

## Cargamos datos de productividad y horas trabajadas desde la API de FRED (Federal Reserve Economic Data)
library(fredr)
library(zoo)  # Para series temporales indexadas por fecha

api_key <- ""  # Aquí debes ingresar tu clave personal de la API de FRED
fredr_set_key(api_key)

metadata_productivity <- fredr_series("OPHNFB")  # Metadatos de productividad no agrícola por hora trabajada

data_productivity <- fredr_series_observations("OPHNFB")  # Datos de la serie

data_hours <- fredr_series_observations("HOANBS")  # Horas trabajadas en el sector no agrícola

# Creamos objetos tipo zoo, útiles para trabajar con fechas
y1 <- zoo(data_productivity$value, order.by = as.Date(data_productivity$date))
y2 <- zoo(data_hours$value, order.by = as.Date(data_hours$date))

# Visualizamos ambas series
plot(y1)
plot(y2)

#################### PRUEBAS DE ESTACIONARIEDAD ########################################################

# Simulamos ruido blanco (serie estacionaria por definición)
norm_1 <- rnorm(100, mean = 0, sd = 1)
ruido_1 <- ts(norm_1, start = 1900, frequency = 1)
plot.ts(ruido_1)

# Ruido blanco con mayor varianza
norm_2 <- rnorm(100, mean = 0, sd = 3)
ruido_2 <- ts(norm_2, start = 1900, frequency = 1)
plot.ts(ruido_2)

# Simulamos una caminata aleatoria sin deriva (no estacionaria)
ruido_blanco <- c(0, rnorm(99, mean = 0, sd = 1))
caminata_aleatoria <- cumsum(ruido_blanco)  # Suma acumulada

df_sin_deriva <- data.frame(Valor_anterior = c(0, caminata_aleatoria[-100]),
                            Ruido_blanco = ruido_blanco,
                            Random_walk = caminata_aleatoria)

random_walk_sin_drift <- ts(df_sin_deriva$Random_walk , start = 1, frequency = 1)

# Ahora con deriva: cada paso incluye un incremento constante
deriva <- rep(0.4, 99)  # Constante positiva en cada paso
ruido_blanco <- rnorm(99, mean = 0, sd = 1)
caminata_aleatoria_con_deriva <- cumsum(ruido_blanco + deriva)

df_con_deriva <- data.frame(Valor_anterior = c(0, 0, caminata_aleatoria_con_deriva[-99]),
                            Ruido_blanco = c(0, ruido_blanco),
                            Deriva = c(0, deriva),
                            Random_Walk_with_Drift = c(0, caminata_aleatoria_con_deriva))

random_walk_con_drift <- ts(df_con_deriva$Random_Walk_with_Drift , start = 1, frequency = 1)

# Prueba ADF (Augmented Dickey-Fuller) para detectar raíces unitarias
# H0: No estacionaria | H1: Estacionaria
library(tseries)

adf.test(ruido_1)  # Esperamos rechazar H0 (es ruido blanco)
adf.test(ruido_2)

adf.test(random_walk_sin_drift)  # Esperamos no rechazar H0 (caminata aleatoria)
adf.test(random_walk_con_drift)

# Prueba KPSS (Kwiatkowski-Phillips-Schmidt-Shin)
# H0: Estacionaria | H1: No estacionaria
kpss.test(ruido_1)  # Esperamos no rechazar H0 (es estacionaria)
kpss.test(ruido_2)

kpss.test(random_walk_sin_drift)  # Esperamos rechazar H0 (no estacionaria)
kpss.test(random_walk_con_drift)

# Log-transformamos productividad y horas trabajadas para interpretar cambios como tasas de crecimiento
log_y1 <- 100 * log(y1)  # Multiplicamos por 100 para que los cambios se interpreten en %
log_y2 <- 100 * log(y2)

# Pruebas de estacionariedad sobre niveles
adf.test(y1)
adf.test(log_y1)
plot(y1)
plot(log_y1)

adf.test(y2)
adf.test(log_y2)

# Aplicamos primeras diferencias a las series logarítmicas para obtener tasas de crecimiento
first_diff_y1 <- diff(log_y1, differences = 1)
first_diff_y2 <- diff(log_y2, differences = 1)

plot(first_diff_y1)  # Estas deberían lucir más estacionarias visualmente
plot(first_diff_y2)

# Pruebas ADF sobre primeras diferencias: esperamos rechazar H0
adf.test(first_diff_y1)
adf.test(first_diff_y2)

print(first_diff_y1)  # Imprimimos para ver valores de las tasas de crecimiento









