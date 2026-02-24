$nb = Get-Content -Raw "Analisis_de_dataset.ipynb" | ConvertFrom-Json

$new_code = @"
import numpy as np
import pandas as pd
import heapq
import math

def simular_jornada(lambda_base: float, pesos: np.ndarray, mus: np.ndarray, 
                    paciencia_media: float = 1.0,  
                    fatiga_factor: float = 0.05,   
                    frustracion_umbral: float = 0.5, 
                    frustracion_penalizacion: float = 1.2) -> tuple:
    
    tiempos = []
    t = 0.0
    for hora, peso in enumerate(pesos):
        tasa = lambda_base * peso
        if tasa <= 0:
            t = float(hora + 1)
            continue
        if t < float(hora):
            t = float(hora)
            
        buffer = int(tasa * 4) + 20
        gaps = np.random.exponential(1 / tasa, size=buffer)
        ts = t + np.cumsum(gaps)
        mask = ts < hora + 1
        if mask.any():
            tiempos.append(ts[mask])
            t = ts[mask][-1]
        else:
            t = ts[0]

    if not tiempos:
        return np.array([]), 0, 0.0

    llegadas = np.concatenate(tiempos)
    n = len(llegadas)
    s = len(mus)
    
    paciencias = np.random.weibull(1.5, n) * paciencia_media
    
    servidores_disponibles = [(0.0, i) for i in range(s)]
    heapq.heapify(servidores_disponibles)
    
    esperas = []
    abandonos = 0
    tiempos_servicio_totales = 0.0
    sigma = 0.7  
    
    for i, llegada in enumerate(llegadas):
        libre_en, s_idx = servidores_disponibles[0]
        espera_potencial = max(0.0, libre_en - llegada)
        
        if espera_potencial > paciencias[i]:
            abandonos += 1
            continue
            
        esperas.append(espera_potencial)
        inicio_servicio = max(llegada, libre_en)
        libre_en, s_idx = heapq.heappop(servidores_disponibles)
        
        hora_actual = min(len(pesos) - 1, int(inicio_servicio))
        mu_actual = mus[s_idx] * (1.0 - (fatiga_factor * (hora_actual / max(1, len(pesos)))))
        
        multiplicador = frustracion_penalizacion if espera_potencial > frustracion_umbral else 1.0
        mu_efectivo = mu_actual / multiplicador
        
        media_deseada = 1.0 / mu_efectivo if mu_efectivo > 0 else 1.0
        m = math.log(media_deseada) - (sigma**2) / 2.0
        duracion_servicio = np.random.lognormal(mean=m, sigma=sigma)
        
        tiempos_servicio_totales += duracion_servicio
        fin_servicio = inicio_servicio + duracion_servicio
        heapq.heappush(servidores_disponibles, (fin_servicio, s_idx))

    return np.array(esperas), abandonos, tiempos_servicio_totales

def registrar_experimento(nombre: str, n_iter: int, lambda_base: float,
                           pesos: list, lista_asesores: list, coste_espera_h: float) -> pd.DataFrame:
    
    pesos_arr = np.array(pesos)
    mus       = np.array([a['mu']   for a in lista_asesores])
    costes    = np.array([a['coste'] for a in lista_asesores])
    s         = len(lista_asesores)

    HORAS_JORNADA      = len(pesos)
    coste_fijo_dia     = costes.sum() * HORAS_JORNADA
    mu_medio           = mus.mean() if s > 0 else 1.0
    lambda_efectiva    = lambda_base * pesos_arr.mean()
    rho                = lambda_efectiva / (s * mu_medio) if s > 0 else 0
    coste_wait_h_inv   = coste_espera_h  

    wq_iter        = np.empty(n_iter)
    cost_iter      = np.empty(n_iter)
    abandonos_iter = np.empty(n_iter)
    
    llegadas_esperadas = lambda_efectiva * HORAS_JORNADA

    for i in range(n_iter):
        esperas, abandonos, t_servicios = simular_jornada(lambda_base, pesos_arr, mus)
        abandonos_iter[i] = abandonos
        
        if esperas.size > 0:
            wq_iter[i]   = esperas.mean() * 60          
            cost_iter[i] = esperas.sum() * coste_wait_h_inv
        else:
            wq_iter[i]   = 0.0
            cost_iter[i] = 0.0

    coste_espera_medio = cost_iter.mean()
    tasa_abandono_media = (abandonos_iter.mean() / llegadas_esperadas) * 100 if llegadas_esperadas > 0 else 0.0

    return pd.DataFrame([{
        "Escenario":                  nombre,
        "Iteraciones":                n_iter,
        "Lambda Base":                lambda_base,
        "Num Asesores":               s,
        "Mu Promedio":                round(mu_medio, 2), 
        "Coste Espera (€/h)":         coste_wait_h_inv,
        "Tasa Abandono (%)":          round(tasa_abandono_media, 2), 
        "Configuración":              f"L={lambda_base}, S={s}, Mu={round(mu_medio,1)}",
        "Wq Medio (min)":             round(wq_iter.mean(), 2),
        "Incertidumbre (Std Dev min)": round(wq_iter.std(), 2),
        "Coste Salarios (€/día)":     coste_fijo_dia,
        "Coste Espera Medio (€/día)": round(coste_espera_medio, 2),
        "Coste Total Medio (€/día)":  round(coste_fijo_dia + coste_espera_medio, 2),
        "Factor de utilización medio": round(rho, 2) 
    }])
    
def crear_equipo(n_senior=0, n_semi_senior=0, n_junior=0, n_base=30,
             mu_senior=4, coste_senior=30,
             mu_semi=3.25, coste_semi=22,
             mu_junior=2.5, coste_junior=15,
             mu_base=3, coste_base=20):
    equipo = []
    equipo += [{'nombre': 'Senior', 'mu': mu_senior, 'coste': coste_senior}] * n_senior
    equipo += [{'nombre': 'semi-senior', 'mu': mu_semi, 'coste': coste_semi}] * n_semi_senior
    equipo += [{'nombre': 'Junior', 'mu': mu_junior, 'coste': coste_junior}] * n_junior
    return equipo
"@

$lines = $new_code -split "`r`n|`n"
$sourceArray = @()
for ($i=0; $i -lt $lines.Length; $i++) {
    if ($i -lt $lines.Length - 1) {
        $sourceArray += ($lines[$i] + "`n")
    } else {
        $sourceArray += $lines[$i]
    }
}

$found = $false
foreach ($cell in $nb.cells) {
    if ($cell.cell_type -eq 'code') {
        $source_text = $cell.source -join ''
        if ($source_text -match 'def simular_jornada' -and $source_text -match 'def registrar_experimento') {
            $cell.source = $sourceArray
            $found = $true
            break
        }
    }
}

if ($found) {
    # Convert back to JSON and force UTF8 without BOM
    $jsonOutput = $nb | ConvertTo-Json -Depth 50
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllText("Analisis_de_dataset.ipynb", $jsonOutput, $Utf8NoBomEncoding)
    Write-Output "Inyectado con éxito en PowerShell."
} else {
    Write-Output "No se encontró la celda."
}
