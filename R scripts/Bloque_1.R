################################### CURSO DE ECONOMETRÍA DE SERIES DE TIEMPO 2025 ##################################################

#################### INTRODUCCIÓN A R Y SIMULACIONES DE SERIES TEMPORALES ##########################################################

#################### OBJETOS #######################################################################################################

# En R, todo es un objeto. Comenzamos creando un objeto escalar: una sola cantidad numérica.
a <- 5

print(a)      # Imprimimos su valor
class(a)       # Consultamos su tipo (clase)

# También se puede asignar usando el signo igual (no es la forma recomendada por el estilo de R, pero funciona).

mi_primer_objeto = 2

# Ahora creamos vectores, que son secuencias de números. Son objetos muy comunes y versátiles.

vector_1 <- c(1,3,5,2)
vector_2 <- c(2,3,5,2)
vector_3 <- c(4,6,3,2)
vector_4 <- c(3,8,0,5,4,1,3,2)

print(vector_1)

# Podemos combinar vectores como columnas para formar una matriz.
matriz_1 <- cbind(vector_1, vector_2, vector_3)

print(matriz_1)
class(matriz_1)   # Verificamos que es una matriz

# Los objetos también pueden ser de texto (caracteres) o valores lógicos (TRUE/FALSE).

nombre <- c("Ana", "Juan", "María", "Pedro", "Laura", "Carlos", "Sofía", "Luis", "Elena", "Diego")
class(nombre)     # Vector de caracteres

empleo <- c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE)
class(empleo)     # Vector lógico

edad <- c(35,23,24,20,28,31,21,29,20,38)
hijos <- c(1,1,0,3,2,1,0,1,1,3)
class(hijos)      # Vector numérico

print(hijos)

mean(edad, na.rm = TRUE)
mean(hijos)
sd(hijos)
?mean

# Combinamos vectores en un data frame: una tabla con columnas de distinto tipo.

datos <- data.frame(nombre, empleo, edad, hijos)
class(datos)
# Podemos realizar operaciones matemáticas con objetos de manera sencilla.

print(a)
print(vector_1)
a+vector_1
suma_1 <- a+vector_1        # Suma escalar + vector
a*vector_1                 # Multiplicación escalar * vector
vector_1/a                   # División escalar/vector
 vector_1 + vector_2          # Suma entre vectores del mismo tamaño
vector_1 + vector_4            # ¿Qué pasa si tienen distinto tamaño? (R recicla valores)

library(dplyr)

#################### FUNCIONES #######################################################################################################

# R tiene funciones integradas para realizar cálculos rápidamente.

print(vector_1)                 # Imprimir el vector

mean(vector_1)                 # Media
sd(vector_1)                   # Desviación estándar

mean(datos$edad)
sum(datos$hijos)               # Suma de una columna del data frame

media_hijos <- mean(datos$hijos)  # Guardamos la media en un nuevo objeto
print(media_hijos)

# Vamos a seguir aprendiendo sobre funciones con ejemplos más avanzados a continuación.

#################### SIMULACIONES #######################################################################################################

# En esta sección simulamos series temporales: conjuntos de datos ordenados en el tiempo.

set.seed(123)  # Fijamos la semilla para que los resultados sean reproducibles

# Simulamos ruido blanco: valores aleatorios independientes con media cero y varianza constante.

norm_1 <- rnorm(100, mean=0, sd=1)
print(norm_1)             # Generamos 100 valores normales estándar
ruido_1 <- ts(norm_1, start= 1900, frequency=1)   # Lo convertimos en serie temporal

class(norm_1)
class(ruido_1)

plot.ts(ruido_1)    # Graficamos la serie temporal

# Repetimos la simulación pero con una desviación estándar más grande.

norm_2 <- rnorm(100, mean = 0, sd = 3)
ruido_2 <- ts(norm_2, start = 1900, frequency = 1)
plot.ts(ruido_2)

# Podemos guardar el ruido como un data frame si deseamos procesarlo más adelante.

ruido_1 <- data.frame(ruido_1)

# Ahora simulamos una caminata aleatoria SIN deriva.
# Cada nuevo valor es igual al anterior más un nuevo error aleatorio.

ruido_blanco <- c(0, rnorm(99, mean = 0, sd = 1))
caminata_aleatoria <- cumsum(ruido_blanco)   # cumsum acumula la suma

df_sin_deriva <- data.frame(
  Valor_anterior = c(0, caminata_aleatoria[-100]),
  Ruido_blanco = ruido_blanco,
  Random_walk = caminata_aleatoria
)

plot.ts(df_sin_deriva$Random_walk)

# Ahora una caminata aleatoria CON deriva.
# Esto incluye una "tendencia" sistemática (en este caso, positiva).

deriva <- rep(0.2, 99)                              # Agregamos una constante (la deriva)
ruido_blanco <- rnorm(99, mean = 0, sd = 1)         # Error aleatorio

caminata_aleatoria_con_deriva <- cumsum(ruido_blanco + deriva)

df_con_deriva <- data.frame(
  Valor_anterior = c(0, 0, caminata_aleatoria_con_deriva[-99]),
  Ruido_blanco = c(0, ruido_blanco),
  Deriva = c(0, deriva),
  Random_Walk_with_Drift = c(0, caminata_aleatoria_con_deriva)
)

plot.ts(df_con_deriva$Random_Walk_with_Drift)

#### Antes de cerrar, recordamos la importancia de guardar nuestro script (Archivo > Guardar como...)

### ¿A dónde recurrimos en caso de dudas?





























