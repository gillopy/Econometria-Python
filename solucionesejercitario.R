# Ejercicios

# Ej 1

a <- 1
b <- -4
c <- 3

solucion_1 <- (-b + sqrt(b^2-4*a*c))/(2*a)
solucion_2 <- (-b - sqrt(b^2-4*a*c))/(2*a)


# Ej 2

ls()


# Ej 3

r <- 3
pi*r^2


# Ej 4

n <- 100
n*(n+1)/2

v <- seq(1, 100)
sum(v)


# Ej 5

A <- 7+(2*3)^2
B <- 7+2*3^2

A_mayor_B <- A > B

# Ej 6

C <- (1+2/7) * (-2/3)^2 + (2-1/2)^3 

# Ej 7

D <- floor(runif(20, min = 0, max = 100))

D

# Ej 8

ls()

# Ej 9

v <- seq(1, 100)

# Ej 10

install.packages("tidyverse")
library(tidyverse)


# Ej 11

mpg <- mpg


# Ej 12

class(mpg)
dim(mpg)
str(mpg)


# Ej 13

install.packages("openxlsx")
library(openxlsx)
write.xlsx(mpg, "mpg.xlsx")