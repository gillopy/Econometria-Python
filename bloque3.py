import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
from statsmodels.tsa.arima.model import ARIMA
import pmdarima as pm
from statsmodels.tsa.api import VAR
from fredapi import Fred

# ------------------ SIMULACIÓN DE UN PROCESO AR(2) ------------------
def simulate_ar2(n=800, phi1=0.4, phi2=0.2, sigma=0.5, seed=14):
    np.random.seed(seed)
    e = np.random.normal(scale=sigma, size=n)
    x = np.zeros(n)
    x[0] = e[0]
    x[1] = phi1 * x[0] + e[1]
    for t in range(2, n):
        x[t] = phi1 * x[t-1] + phi2 * x[t-2] + e[t]
    return pd.Series(x, index=range(1, n+1))

# Simular y graficar
x1 = simulate_ar2()
plt.figure()
plt.plot(x1)
plt.title("Serie simulada AR(2)")
plt.show()

# Test ADF
adf_res_x1 = adfuller(x1)
print("ADF Estadístico AR(2):", adf_res_x1[0], "p-valor:", adf_res_x1[1])

# ACF y PACF
plot_acf(x1, lags=20)
plt.title("ACF de AR(2)")
plt.show()
plot_pacf(x1, lags=20)
plt.title("PACF de AR(2)")
plt.show()

# Estimación AR(2)
df_x1 = x1.to_frame(name='x1')
df_x1['x1_lag1'] = df_x1['x1'].shift(1)
df_x1['x1_lag2'] = df_x1['x1'].shift(2)
df_x1 = df_x1.dropna()
model_x1 = ARIMA(df_x1['x1'], order=(2,0,0)).fit()
print(model_x1.summary())

# ------------------ SIMULACIÓN DE UN PROCESO MA(2) ------------------
def simulate_ma2(n=800, theta1=0.5, theta2=0.4, seed=14):
    np.random.seed(seed)
    e = np.random.normal(size=n)
    z = np.zeros(n)
    z[0] = e[0]
    z[1] = theta1 * e[0] + e[1]
    for t in range(2, n):
        z[t] = theta1 * e[t-1] + theta2 * e[t-2] + e[t]
    return pd.Series(z, index=range(1, n+1))

z1 = simulate_ma2()
plt.figure()
plt.plot(z1)
plt.title("Serie simulada MA(2)")
plt.show()

# ADF
adf_res_z1 = adfuller(z1)
print("ADF Estadístico MA(2):", adf_res_z1[0], "p-valor:", adf_res_z1[1])

# ACF y PACF
plot_acf(z1, lags=20)
plt.title("ACF de MA(2)")
plt.show()
plot_pacf(z1, lags=20)
plt.title("PACF de MA(2)")
plt.show()

# Estimar MA(2)
model_z1 = ARIMA(z1, order=(0,0,2)).fit()
print(model_z1.summary())

# ------------------ SELECCIÓN DE MODELO CON auto_arima ------------------
fit_x1_aic = pm.auto_arima(x1, information_criterion='aic', seasonal=False)
print(fit_x1_aic.summary())
fit_x1_bic = pm.auto_arima(x1, information_criterion='bic', seasonal=False)
print(fit_x1_bic.summary())
fit_z1_aic = pm.auto_arima(z1, information_criterion='aic', seasonal=False)
print(fit_z1_aic.summary())
fit_z1_bic = pm.auto_arima(z1, information_criterion='bic', seasonal=False)
print(fit_z1_bic.summary())

# Pronóstico in-sample y out-of-sample
fitted_vals = fit_x1_bic.predict_in_sample()
plt.figure()
plt.plot(x1, label='Original')
plt.plot(fitted_vals, label='Fitted')
plt.title('In-sample fit sobre x1')
plt.legend()
plt.show()
forecast_vals = fit_x1_bic.predict(n_periods=12)
plt.figure()
plt.plot(range(1, len(x1)+1), x1, label='Serie')
plt.plot(range(len(x1)+1, len(x1)+13), forecast_vals, label='Forecast')
plt.title('Out-of-sample forecast de x1')
plt.legend()
plt.show()

# ------------------ VAR PRODUCTIVIDAD Y HORAS TRABAJADAS ------------------
# FRED API key
def fetch_and_prepare_fred(api_key, series, start_date, end_date):
    fred = Fred(api_key=api_key)
    data = fred.get_series(series, observation_start=start_date, observation_end=end_date)
    return pd.Series(data)

api_key = 'b06e7c324f12d847979880eccc502a10'
prod = fetch_and_prepare_fred(api_key, 'OPHNFB', '1999-01-01', '2019-01-01')
hours = fetch_and_prepare_fred(api_key, 'HOANBS', '1999-01-01', '2019-01-01')

# Transformaciones
log_prod = 100 * np.log(prod)
log_hours = 100 * np.log(hours)
diff_prod = log_prod.diff().dropna()
diff_hours = log_hours.diff().dropna()
# Centrar
y = pd.concat([diff_prod, diff_hours], axis=1).dropna()
y = y - y.mean()
# Estimación VAR
model_var = VAR(y)
lag_order = model_var.select_order(maxlags=8)
best_lag = lag_order.aic
var_res = model_var.fit(best_lag)
print(var_res.summary())

# IRF acumulativa
irf = var_res.irf(24)
irf.plot(orth=False)
plt.show()

# Nota: Identificación estructural (Blanchard-Quah) no está implementada directamente en statsmodels
