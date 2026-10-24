# Reto 3 - Control de Balance Energético

## Descripción
Este proyecto implementa un controlador horario para una microred híbrida solar-eólica.  
El algoritmo evalúa el balance energético cada hora y decide si la energía disponible se usa para alimentar cargas o para cargar el banco de baterías.

## Archivo principal
- `Proyecto_Reto_3.m`

## Funcionamiento
- Calcula la generación híbrida como la suma de energía solar y eólica.
- Compara la generación con la demanda total.
- Si hay excedente, carga la batería sin superar su capacidad máxima.
- Si hay déficit, usa la batería de forma controlada.
- Aplica priorización de cargas:
  - Escuela rural: activa siempre.
  - Bombeo agrícola: se desconecta en déficit severo.
  - Alumbrado público: se desconecta antes que el bombeo cuando el SOC es bajo.

## Salidas del programa
- Historial del SOC.
- Estado horario de cada carga.
- Tabla resumen de resultados.
- Gráficas del balance energético y del estado de carga.

## Requisitos
- MATLAB R2019b o superior.

## Ejecución
Abrir `Proyecto_Reto_3.m` en MATLAB y ejecutar el script.

## Autor
Jonathan Sanchez