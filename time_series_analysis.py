import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Basic objects
a = 5
print(a)
print(type(a))

my_first_object = 2

# Vectors
vector_1 = [1,3,5,2] 
vector_2 = [2,3,5,2]
vector_3 = [4,6,3,2]
vector_4 = [3,8,0,5,4,1,3,2]

print(vector_1)

# Matrix
matrix_1 = np.column_stack((vector_1, vector_2, vector_3))
print(matrix_1)
print(type(matrix_1))

# Different data types
nombres = ["Ana", "Juan", "María", "Pedro", "Laura", "Carlos", "Sofía", "Luis", "Elena", "Diego"]
empleo = [True, False, True, True, False, True, False, False, True, False]
edad = [35,23,24,20,28,31,21,29,20,38]
hijos = [1,1,0,3,2,1,0,1,1,3]

print(np.mean(edad))
print(np.mean(hijos))
print(np.std(hijos))

# DataFrame
datos = pd.DataFrame({
    'nombre': nombres,
    'empleo': empleo,
    'edad': edad,
    'hijos': hijos
})
print(type(datos))

# Math operations
print(a + np.array(vector_1))
print(a * np.array(vector_1))
print(np.array(vector_1) / a)
print(np.array(vector_1) + np.array(vector_2))

# Time series simulations
np.random.seed(123)

# White noise
norm_1 = np.random.normal(0, 1, 100)
ruido_1 = pd.Series(norm_1, index=pd.date_range('1900', periods=100, freq='Y'))
plt.plot(ruido_1)
plt.show()

# White noise with larger std
norm_2 = np.random.normal(0, 3, 100)
ruido_2 = pd.Series(norm_2, index=pd.date_range('1900', periods=100, freq='Y'))
plt.plot(ruido_2)
plt.show()

# Random walk without drift
ruido_blanco = np.concatenate(([0], np.random.normal(0, 1, 99)))
caminata_aleatoria = np.cumsum(ruido_blanco)

df_sin_deriva = pd.DataFrame({
    'Valor_anterior': np.concatenate(([0], caminata_aleatoria[:-1])),
    'Ruido_blanco': ruido_blanco,
    'Random_walk': caminata_aleatoria
})

plt.plot(df_sin_deriva['Random_walk'])
plt.show()

# Random walk with drift
deriva = np.repeat(0.2, 99)
ruido_blanco = np.random.normal(0, 1, 99)
caminata_aleatoria_con_deriva = np.cumsum(ruido_blanco + deriva)

df_con_deriva = pd.DataFrame({
    'Valor_anterior': np.concatenate(([0, 0], caminata_aleatoria_con_deriva[:-1])),
    'Ruido_blanco': np.concatenate(([0], ruido_blanco)),
    'Deriva': np.concatenate(([0], deriva)),
    'Random_Walk_with_Drift': np.concatenate(([0], caminata_aleatoria_con_deriva))
})

plt.plot(df_con_deriva['Random_Walk_with_Drift'])
plt.show()