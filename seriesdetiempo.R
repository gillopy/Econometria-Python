
## CURSO DE ECONOMETRÍA
## SERIES DE TIEMPO


# La función ts()

help(ts)


# Generación de 100 variables aleatorias normales estándar

set.seed(14)
norm <- rnorm(100, mean = 0, sd = 1)
y <- ts(norm, start = 1, frequency = 1)
plot.ts(y)
rm(norm)
rm(y)


# Importación de datos del IPC

setwd("G:/Mi unidad/Cursos (Profesor)/BCP/Curso de econometría/Curso de Econometria (R)/Clase practica")

install.packages("tidyverse")
library(tidyverse)
library(readxl)

inf <- read_excel("Anexo_Estadístico_del_Informe_Económico_11_05_2023.xlsx", 
                  sheet = "CUADRO 14", skip = 11) %>%
  select("Interanual") %>%
  na.omit()

inf <- ts(inf$Interanual, start = c(1994,12), frequency = 12)

print(inf)

plot.ts(inf)

plot.ts(window(inf, start = c(2011, 05))) # desde metas de inflación




# Autocorrelación en R

head(ts.union(inf, stats::lag(inf, -1))) # la función lag() del paquete dplyr sirve para
                                         # vectores numéricos, por eso hay que llamar
                                         # a la función lag() pero del paquete stats

lag <- stats::lag

head(ts.intersect(inf, lag(inf, -1)))
plot(lag(inf, -1), inf)
abline(0,1, col = "red")
cor(ts.intersect(inf, lag(inf, -1)))

#o
length(inf)                              # el objeto inf tiene 341 elementos
cor(inf[2:341], inf[1:340])



# Correlograma en R

acf(inf, lag.max = 20)
acf(inf, lag.max = 20, plot=FALSE)

pacf(inf, lag.max = 20)
pacf(inf, lag.max = 20, plot=FALSE)


# Simulaciones AR(1)

install.packages("dynlm")
library(dynlm)


#SERIE 1:  y_t = 1 + 0.8*y_{t-1} + e_t
set.seed(14)
e <- rnorm(200)
y1 <- ts(vector("double", 200), start = 1, frequency = 1) #output
for (i in 2:200) {                                        #sequence  
  y1[1] = e[1]                                        #body
  y1[i] = 1 + 0.8*y1[i-1] + e[i]
}
plot(y1)
acf(y1, lag.max = 20)
y1fit <- dynlm(y1 ~ lag(y1, -1))
summary(dynlm(y1 ~ lag(y1, -1)))
acf(resid(y1fit))


#SERIE 2: y_t = 1 - 0.8*y_{t-1} + e_t
set.seed(14)
e <- rnorm(200)
y2 <- ts(vector("double", 200), start = 1, frequency = 1) #output
for (i in 2:200) {                                        #sequence  
  y2[1] = e[1]                                            #body
  y2[i] = 1 - 0.8*y2[i-1] + e[i]
}
plot(y2)
acf(y2, lag.max = 20)
y2fit <- dynlm(y2 ~ lag(y2, -1))
summary(dynlm(y2 ~ lag(y2, -1)))
acf(resid(y1fit))


#SERIE 3: y_t = 0.1 + y_{t-1} + e_t
set.seed(14)
e <- rnorm(200)
y3 <- ts(vector("double", 200), start = 1, frequency = 1) #output
for (i in 2:200) {                                        #sequence  
  y3[1] = e[1]                                            #body
  y3[i] = 0.1 + y3[i-1] + e[i]
}
plot(y3)


#SERIE 4: y_t = 0 + 1.1*y_{t-1} + e_t
set.seed(14)
e <- rnorm(200)
y4 <- ts(vector("double", 200), start = 1, frequency = 1) #output
for (i in 2:200) {                                        #sequence  
  y4[1] = e[1]                                            #body
  y4[i] = 0 + 1.1*y4[i-1] + e[i]
}
plot(y4)




# Regresión lineal AR(1)

fit <- ar.ols(inf, order=1, demean=FALSE, intercept=TRUE)
print(fit)

#o
df = ts.intersect(inf, lag(inf,-1), dframe=TRUE) %>% rename("inf.1"="lag.inf...1.")
fit <- lm(inf ~ inf.1, data = df)
summary(fit)

#o
install.packages("dynlm")
library(dynlm)
fit <- dynlm(inf ~ lag(inf,-1))
summary(fit)

#o
fit <- arima(inf, order=c(1,0,0), method = "CSS")
print(fit)

#o
install.packages("forecast")
library(forecast)
fit <- Arima(inf, order = c(1,0,0), method = "CSS")
summary(fit)


# Static Forecast

f.static <- fitted(fit)

plot(inf)
lines(f.static, col="green")


# Dynamic Forecast

f.for <- forecast(inf, h=12)
f.dynamic <- f.for$mean

plot(inf)
lines(f.dynamic, col="green")

#o
install.packages("astsa")
library(astsa)
sarima.for(inf, 12, 1, 0, 0)
help(sarima.for)



# Test de raíz unitaria - ADF

#H0: La serie tiene raíz unitaria (es no estacionaria)
#H1: La serie no tiene raíz unitaria (es estacionaria)

install.packages("tseries")
library(tseries)

adf.test(inf)


# Test de estacionariedad - KPSS

#H0: La serie es estacionaria
#H1: La serie es no estacionaria

kpss.test(inf)


# El test ADF concluye que la serie es estacionaria mientras que el test
# KPSS concluye que la serie es no estacionaria, por lo tanto se procede a
# diferenciar la serie y volver a aplicar los tests.

adf.test(diff(inf)) # se rechaza H0. La serie es estacionaria.
kpss.test(diff(inf)) # no se rechaza H0. La serie es estacionaria.

rm(df,f.for,fit,f.dynamic,f.static)

# Modelos MA

# Los procesos MA son siempre estacionarios

set.seed(14)
e <- rnorm(200)

ma1 <- vector(mode = "double", length = 200)
for (i in 2:200) {
  ma1[1] = e[1]
  ma1[i] = 1 + 0.8*e[i-1] + e[i]
}
plot.ts(ma1, col = "green")

ma2 <- vector(mode = "double", length = 200)
for (i in 2:200) {
  ma2[1] = e[1]
  ma2[i] = 1 + 5*e[i-1] + e[i]
}

plot.ts(ma2)
lines(ma1, col = "green")


# Simulaciones MA(1)

set.seed(14)
e <- rnorm(200, mean = 0, sd = 2)
elag <- dplyr::lag(e, 1)

#SERIE 1: y_t = 2 - 0.9*e_{t-1} + e_t
y1 <- ts(vector(mode = "double", length = 200))
for (i in 2:200) {
  y1[1] = e[1]
  y1[i] = 2 - 0.9*e[i-1] + e[i]
}
plot.ts(y1)

acf(y1)
pacf(y1)

plot(lag(y1, -1), y1)
cor(y1[2:200], y1[1:199])


#SERIE 2: y_t = 2 + 0.9*e_{t-1} + e_t
y2 <- ts(vector(mode = "double", length = 200))
for (i in 2:200) {
  y2[1] = e[1]
  y2[i] = 2 + 0.9*e[i-1] + e[i]
}
plot.ts(y2)

acf(y2)
pacf(y2)

plot(lag(y2, -1), y2)
cor(y2[2:200], y2[1:199])


##Estimación MA

library(forecast)

fit1 <- Arima(y1, order = c(0,0,1), method = "CSS")
print(fit1)

fit2 <- Arima(y2, order = c(0, 0, 1), method = "CSS")
print(fit2)


rm(fit, fit1, fit2, e, elag, i, ma1, ma2, y1, y2)


# Auto.arima

library(forecast)
fit <- auto.arima(inf)
print(fit)
summary(fit)

rm(fit)


# VAR

# Para correr un VAR, descargamos los datos del IMAEP

imaep <- read_excel("Anexo_Estadístico_del_Informe_Económico_11_05_2023.xlsx", 
                    sheet = "CUADRO 9", skip = 9) %>%
  select("IMAEP Serie Original") %>%
  na.omit() %>% rename("imaep"="IMAEP Serie Original")

imaepts <- ts(imaep, start=c(1994,01), frequency=12)
imaepcr <- imaepts/lag(imaepts,-12)*100-100

rm(imaepts,imaep)



# Ahora, dejamos en la base de datos solo a las variables endógenas

data <- ts.intersect(inf, imaepcr)

install.packages("vars")
library(vars) # Cargamos el paquete

var.1 <- VAR(data, p = 1, type="const")
summary(var.1)

residuals <- as.data.frame(resid(var.1))


irf.1 <- irf(var.1, n.ahead = 20, impulse="imaepcr", response="inf", runs=1000)

irf.1
plot(irf.1)


irf.2 <- irf(var.1, n.ahead = 20, impulse="inf", response="imaepcr", runs=1000)
irf.2
plot(irf.2)


### Correlogramas de los errores

resid(var.1)
acf(resid(var.1))


### Pronósticos del VAR

# Dynamic
plot(predict(var.1, n.ahead = 10, ci = 0.95, dumvar = NULL))

# Static
plot.ts(fitted(var.1))