################################### CURSO DE ECONOMETRÍA DE SERIES DE TIEMPO 2025 ##################################################

#################### AUTOCORRELACIÓN Y MODELOS ARMA ###############################################################################

## Definimos nuestro directorio de trabajo
setwd("C:/Users/mnavarro/Desktop/Pedidos_Varios/Clases/IBCP Series de tiempo/Clase practica")

## Cargamos librerías necesarias
library(tseries)   # Para tests de raíz unitaria
library(dyn)       # Para modelos con rezagos dinámicos
library(forecast)  # Para modelos ARIMA y pronósticos

## ------------------ Simulación de un proceso AR(2) ------------------

# Queremos simular una serie con la siguiente dinámica:
# x_t = 0.4*x_{t-1} + 0.2*x_{t-2} + e_t
# Esta es una serie autoregresiva de orden 2 (AR(2))

set.seed(14)  # Semilla para reproducibilidad
e <- rnorm(800, sd=0.5)  # Simulamos ruido blanco con desviación estándar 0.5
x1 <- ts(vector("double",800), start = 1, frequency = 1)  # Creamos la estructura vacía

# Generamos la serie a partir de la fórmula AR(2)
for (i in 3:800) {                                        
  x1[1] = e[1]
  x1[2] = 0.4*x1[1] + e[2] 
  x1[i] = 0.4*x1[i-1] + 0.2*x1[i-2] + e[i]
}

plot(x1, main="Serie simulada AR(2)", col="blue")

# Verificamos si la serie es estacionaria con el test ADF
adf.test(x1)

# Graficamos la función de autocorrelación (ACF) y autocorrelación parcial (PACF)
acf(x1, lag.max = 20, main="ACF de AR(2)")   # Decrecimiento gradual
pacf(x1, lag.max = 20, main="PACF de AR(2)") # Corte en el rezago 2 → típico de AR(2)

# Estimamos el modelo AR(2) con rezagos explícitos
modelo_x1 <- dyn$lm(x1 ~ stats::lag(x1, -1) + stats::lag(x1, -2))
summary(modelo_x1)  # Verificamos significancia de los coeficientes

# ¿Qué ocurre si aumentamos el número de observaciones a 500?
# → Mejora la precisión de las estimaciones. (Puede probarse duplicando el tamaño)

## ------------------ Simulación de un proceso MA(2) ------------------

# Ahora simulamos una serie MA(2): z_t = 0.5*e_{t-1} + 0.4*e_{t-2} + e_t
# Los modelos MA son siempre estacionarios (no necesitan test de raíz unitaria)

set.seed(14)
e <- rnorm(800)  # Nuevo ruido blanco

z1 <- ts(vector("double",800), start = 1, frequency = 1)
for (i in 3:800) {
  z1[1] = e[1]
  z1[2] = 0.5*e[1] + e[2]
  z1[i] = 0.5*e[i-1] + 0.4*e[i-2] + e[i]
}

plot(z1, col = "green", main="Serie simulada MA(2)")

# Verificamos estacionariedad (aunque por construcción ya lo es)
adf.test(z1)

# ACF y PACF de un MA(2)
acf(z1, lag.max = 20, main="ACF de MA(2)")   # Corte en lag 2
pacf(z1, lag.max = 20, main="PACF de MA(2)") # Decrecimiento gradual

# Estimamos un modelo MA(2) usando Arima() con orden (0,0,2)
modelo_z1 <- Arima(z1, order = c(0,0,2))
summary(modelo_z1)

## ------------------ Selección de modelo con auto.arima ------------------

# Cuando no sabemos el modelo correcto, usamos auto.arima
# auto.arima selecciona el mejor modelo según criterios de información

fit_x1_1 <- auto.arima(x1, ic = "aic")  # Criterio AIC
summary(fit_x1_1)

fit_x1_2 <- auto.arima(x1, ic = "bic")  # Criterio BIC (penaliza más la complejidad)
summary(fit_x1_2)

fit_z1_1 <- auto.arima(z1, ic = "aic")
summary(fit_z1_1)

fit_z1_2 <- auto.arima(z1, ic = "bic")
summary(fit_z1_2)

## ------------------ Pronóstico in-sample e out-of-sample ------------------

# In-sample: Ajuste del modelo a los datos usados en la estimación
f_static <- fitted(fit_x1_2)
plot(x1, main="In-sample fit sobre x1")
lines(f_static, col="green")  # Línea ajustada

# Out-of-sample: Predicción futura
forecast_x1_2 <- forecast(fit_x1_2, h = 12)  # Pronóstico a 12 períodos

plot(x1, xlim=c(0,820), main="Out-of-sample forecast de x1")
lines(forecast_x1_2$mean, col = "red")  # Pronóstico futuro



#################### VAR PRODUCTIVIDAD Y HORAS TRABAJADAS ###########################################################################

## TECHNOLOGY, EMPLOYMENT, AND THEBUSINESSCYCLE: DO TECHNOLOGY SHOCKS EXPLAIN AGGREGATE FLUCTUATIONS?. Jordi Galí(1999)

# Cargamos de vuelta nuestros datos usando la API de FRED

library(fredr)
library(zoo)

api_key <- "a1fec3b5e1704ae36b05ea3298b4e3b5"
fredr_set_key(api_key)


# Obtener los datos de productividad y horas trabajadas desde la base de datos FRED
data_productivity <- fredr_series_observations("OPHNFB", observation_start = as.Date("1999-01-01"), observation_end = as.Date("2019-01-01"))
data_hours <- fredr_series_observations("HOANBS", observation_start = as.Date("1999-01-01"), observation_end = as.Date("2019-01-01"))

# Convertir las series temporales a objetos 'zoo', que permiten trabajar con datos temporales
y1 <- zoo(data_productivity$value, order.by = as.Date(data_productivity$date))
y2 <- zoo(data_hours$value, order.by = as.Date(data_hours$date))

# Aplicar la transformación logarítmica a las series, en porcentaje
log_y1 <- 100 * log(y1)
log_y2 <- 100 * log(y2)

# Calcular las primeras diferencias (tasa de crecimiento) de las series logarítmicas
first_diff_y1 <- diff(log_y1, differences = 1)
first_diff_y2 <- diff(log_y2, differences = 1)

# Combinar las dos series diferenciadas en una sola matriz para el análisis VAR
y <- cbind(first_diff_y1, first_diff_y2)

# Restar la media de cada serie (centrar las series en torno a cero) para asegurar la estacionariedad
y <- sweep(y, 2, apply(y, 2, mean))

# Estimación del modelo VAR usando el criterio AIC para la selección de rezagos
myVAR <- VAR(y, ic = "AIC", lag.max = 8)

# Estimación del modelo SVAR usando la identificación estructural de Blanchard y Quah
mySVAR <- BQ(myVAR)

# Calcular las Funciones de Respuesta a Impulsos (IRF) para los siguientes 24 períodos
# Intervalo de confianza del 90% y respuestas acumulativas
myIRF.c <- irf(mySVAR, n.ahead = 24, ci = .9, cumulative = TRUE)

# Graficar las Funciones de Respuesta a Impulsos (IRF)
plot(myIRF.c)





