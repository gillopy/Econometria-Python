import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller, kpss
import yfinance as yf
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# Función helper para prueba ADF
def adf_test(series, title=''):
    print(f'Augmented Dickey-Fuller Test: {title}')
    result = adfuller(series)
    print('ADF Statistic:', result[0])
    print('p-value:', result[1])
    print('Critical values:')
    for key, value in result[4].items():
        print(f'\t{key}: {value}')
    print('\n')

# Función helper para prueba KPSS
def kpss_test(series, title=''):
    print(f'KPSS Test: {title}')
    result = kpss(series)
    print('KPSS Statistic:', result[0])
    print('p-value:', result[1])
    print('Critical values:')
    for key, value in result[3].items():
        print(f'\t{key}: {value}')
    print('\n')

# Simulación de series temporales
np.random.seed(123)

# Ruido blanco (serie estacionaria)
norm_1 = np.random.normal(0, 1, 100)
ruido_1 = pd.Series(norm_1)
plt.figure(figsize=(10, 6))
plt.title('Ruido Blanco (σ = 1)')
plt.plot(ruido_1)
plt.grid(True)
plt.show()

# Ruido blanco con mayor varianza
norm_2 = np.random.normal(0, 3, 100)
ruido_2 = pd.Series(norm_2)
plt.figure(figsize=(10, 6))
plt.title('Ruido Blanco (σ = 3)')
plt.plot(ruido_2)
plt.grid(True)
plt.show()

# Caminata aleatoria sin deriva
ruido_blanco = np.concatenate(([0], np.random.normal(0, 1, 99)))
random_walk_sin_drift = np.cumsum(ruido_blanco)

plt.figure(figsize=(10, 6))
plt.title('Caminata Aleatoria sin Deriva')
plt.plot(random_walk_sin_drift)
plt.grid(True)
plt.show()

# Caminata aleatoria con deriva
deriva = np.repeat(0.4, 99)
ruido_blanco = np.random.normal(0, 1, 99)
random_walk_con_drift = np.cumsum(ruido_blanco + deriva)
random_walk_con_drift = np.concatenate(([0], random_walk_con_drift))

plt.figure(figsize=(10, 6))
plt.title('Caminata Aleatoria con Deriva')
plt.plot(random_walk_con_drift)
plt.grid(True)
plt.show()

# Pruebas de estacionariedad
print("Pruebas de estacionariedad para ruido blanco:")
adf_test(ruido_1, "Ruido Blanco σ=1")
adf_test(ruido_2, "Ruido Blanco σ=3")

print("Pruebas de estacionariedad para caminatas aleatorias:")
adf_test(random_walk_sin_drift, "Caminata Aleatoria sin Deriva")
adf_test(random_walk_con_drift, "Caminata Aleatoria con Deriva")

print("\nPruebas KPSS:")
kpss_test(ruido_1, "Ruido Blanco σ=1")
kpss_test(ruido_2, "Ruido Blanco σ=3")
kpss_test(random_walk_sin_drift, "Caminata Aleatoria sin Deriva")
kpss_test(random_walk_con_drift, "Caminata Aleatoria con Deriva")

# Para los datos de FRED, usaremos yfinance como alternativa
# Descargamos datos de ejemplo (S&P 500 como proxy)
sp500 = yf.download('^GSPC', start='2000-01-01', end=datetime.now())
# Verificamos las columnas disponibles
print("Columnas disponibles:", sp500.columns)

# Usamos 'Close' en lugar de 'Adj Close'
y1 = sp500['Close']
y2 = sp500['Volume']

# Log-transformación
log_y1 = 100 * np.log(y1)
log_y2 = 100 * np.log(y2)

# Visualización de series originales y transformadas
plt.figure(figsize=(12, 8))
plt.subplot(2,1,1)
plt.title('Serie Original (Precio de Cierre S&P 500)')
plt.plot(y1, label='Precio')
plt.legend()
plt.grid(True)
plt.subplot(2,1,2)
plt.title('Serie Log-transformada')
plt.plot(log_y1, label='Log-Precio', color='orange')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

# Pruebas de estacionariedad sobre niveles
print("\nPruebas sobre niveles:")
adf_test(y1, "Serie Y1 Original")
adf_test(log_y1, "Serie Y1 Log-transformada")
adf_test(y2, "Serie Y2 Original")
adf_test(log_y2, "Serie Y2 Log-transformada")

# Primeras diferencias
first_diff_y1 = np.diff(log_y1)
first_diff_y2 = np.diff(log_y2)

# Visualización de primeras diferencias
plt.figure(figsize=(10, 6))
plt.title('Primera Diferencia de Serie Log-transformada (Y1)')
plt.plot(first_diff_y1)
plt.grid(True)
plt.show()

# Pruebas ADF sobre primeras diferencias
print("\nPruebas sobre primeras diferencias:")
adf_test(first_diff_y1, "Primera Diferencia Y1")
adf_test(first_diff_y2, "Primera Diferencia Y2")