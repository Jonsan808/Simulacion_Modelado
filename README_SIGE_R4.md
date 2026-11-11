# Reto 4 — Sistema Inteligente de Gestión Energética (SIGE)

## Descripción

`SIGE_R4.m` implementa una interfaz gráfica (HMI) en MATLAB para simular la gestión energética de una micro-red híbrida. El sistema permite ajustar la generación solar y eólica, la demanda comunitaria y el estado de carga (SOC) inicial de una batería.

Durante la simulación, el programa calcula la generación total y la demanda atendida, actualiza el SOC de la batería y ajusta la conexión de los servicios prioritarios según el nivel de energía disponible.

## Archivo principal

- `SIGE_R4.m` — aplicación interactiva del SIGE para el Reto 4.

## Funcionalidades

- Ajuste interactivo de generación solar, generación eólica y demanda mediante controles deslizantes.
- Configuración del SOC inicial de la batería.
- Simulación minuto a minuto durante un máximo de 60 minutos.
- Visualización del SOC en un medidor y del estado de los servicios mediante indicadores luminosos.
- Gráfica de generación total, demanda original y demanda atendida.
- Tres escenarios predefinidos para facilitar las pruebas.
- Botones para iniciar, detener y reiniciar la simulación.
- Gestión prioritaria de las cargas:
  1. Escuela Rural.
  2. Bombeo de Agua.
  3. Alumbrado Público.

## Niveles de operación

El SIGE modifica las cargas conectadas de acuerdo con el SOC de la batería:

- **Operación normal:** permanecen activos la Escuela Rural, el Bombeo de Agua y el Alumbrado Público.
- **Alerta:** se desconecta el Alumbrado Público.
- **Emergencia:** se desconectan el Alumbrado Público y el Bombeo de Agua; la Escuela Rural conserva la prioridad.

Los umbrales configurados son 40 % para alerta y 20 % para emergencia. Se aplica una banda de histéresis para reducir cambios repetidos entre niveles cuando el SOC está cerca de un umbral.

## Requisitos

- MATLAB R2023 o una versión posterior, según lo indicado en el encabezado del archivo.
- Componentes de interfaz gráfica de MATLAB, como `uifigure`, `uislider`, `uigauge` y `uiaxes`.
- No se declaran dependencias externas.

## Ejecución

1. Descarga o clona el repositorio y abre MATLAB.
2. En MATLAB, cambia la carpeta actual a la ubicación de `SIGE_R4.m`.
3. Ejecuta en la ventana de comandos:

```matlab
SIGE_R4
```

4. Ajusta los parámetros o selecciona uno de los escenarios y pulsa **INICIAR SIMULACIÓN**.

## Parámetros principales

- Capacidad nominal de batería: 100 kWh.
- Eficiencia de carga y descarga: 95 %.
- Duración máxima: 60 minutos simulados.
- Generación solar configurable: 0–150 kW.
- Generación eólica configurable: 0–100 kW.
- Demanda comunitaria configurable: 0–200 kW.

## Autores

Jonathan Sánchez, Cristian R. Sánchez Durán, Jean C. Silva Ariza y Manuel A. Silva Mendieta.

## Contexto académico

Software para Ingeniería — Reto 4, Sistema Inteligente de Gestión Energética (SIGE). Grupo 184.
