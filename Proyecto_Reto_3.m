%% ---------------------------------------------------------
% Nombre del estudiante: Jonathan Sanchez
% Grupo: Grupo – 184
% Programa: Ingeniería de Telecomunicaciones
% Código Fuente: Autoría Propia
% ---------------------------------------------------------

% Limpieza completa del espacio de trabajo, variables previas y consola
clear; clc; close all;

% Declaración de la capacidad nominal total del banco de baterías en kWh
Capacidad_bat = 100;

% Inicialización del Estado de Carga (SOC) del sistema de almacenamiento al 50 por ciento
SOC_actual = 50;

% Creación del vector de generación solar hipotética de 24 horas en kWh
E_solar = [0, 0, 0, 0, 0, 5, 20, 45, 70, 90, 100, 110, 105, 95, 75, 50, 25, 5, 0, 0, 0, 0, 0, 0];

% Creación del vector de generación eólica hipotética de 24 horas en kWh
E_eolica = [15, 20, 25, 20, 15, 10, 10, 15, 20, 25, 30, 25, 20, 15, 10, 15, 20, 25, 30, 35, 30, 25, 20, 15];

% Creación del vector de demanda comunitaria total de 24 horas en kWh (Escuela + Bombeo + Alumbrado)
E_demanda = [30, 25, 20, 20, 25, 40, 60, 80, 90, 85, 80, 75, 75, 80, 85, 90, 100, 110, 95, 70, 50, 40, 35, 30];

% Preasignación de vectores históricos para almacenar el rendimiento operativo por hora
SOC_historial = zeros(1, 24); % Vector para guardar la evolución del SOC
Estado_Escuela = cell(1, 24); % Celda para registrar el estado de la escuela
Estado_Bombeo = cell(1, 24);  % Celda para registrar el estado del bombeo agrícola
Estado_Alumbrado = cell(1, 24); % Celda para registrar el estado del alumbrado público
E_excedente_hist = zeros(1, 24); % Excedente no utilizado por hora
E_faltante_hist = zeros(1, 24); % Déficit no cubierto por hora

% Vector de horas para reportes y gráficas
horas = 1:24;

% Inicio del bucle iterativo for para simular de forma secuencial las 24 horas del día
for hora = 1:24

    % Cálculo de la generación híbrida total sumando los aportes solar y eólico de la hora actual
    E_gen = E_solar(hora) + E_eolica(hora);

    % Extracción del valor de la demanda comunitaria correspondiente a la hora analizada
    E_dem = E_demanda(hora);

    % Inicialización por defecto de las cargas
    Escuela = 'Activa';
    Bombeo = 'Activo';
    Alumbrado = 'Activo';

    % Evaluación condicional primaria para determinar si existe superávit o déficit energético
    if E_gen >= E_dem

        % Cálculo numérico del excedente energético disponible tras abastecer la demanda total
        Excedente = E_gen - E_dem;

        % Energía disponible real para cargar la batería sin superar su capacidad máxima
        Energia_disponible_carga = ((100 - SOC_actual) / 100) * Capacidad_bat;

        % Energía efectivamente cargada en la batería
        Energia_cargada = min(Excedente, Energia_disponible_carga);

        % Actualización del Estado de Carga sumando la proporción de energía cargada
        SOC_actual = SOC_actual + (Energia_cargada / Capacidad_bat) * 100;

        % Validación del límite superior estricto para evitar sobrecargas físicas en el banco de baterías
        if SOC_actual > 100
            SOC_actual = 100;
        end

        % Registro del excedente no utilizado
        E_excedente_hist(hora) = Excedente - Energia_cargada;
        E_faltante_hist(hora) = 0;

        % Establecimiento operativo nominal de todas las cargas bajo régimen de superávit
        Escuela = 'Activa';
        Bombeo = 'Activo';
        Alumbrado = 'Activo';

    else

        % Cálculo numérico del déficit energético cuando la demanda supera la generación limpia
        Faltante = E_dem - E_gen;

        % Energía disponible real en la batería para cubrir el déficit
        Energia_disponible_descarga = (SOC_actual / 100) * Capacidad_bat;

        % Energía efectivamente entregada desde la batería
        Energia_entregada = min(Faltante, Energia_disponible_descarga);

        % Actualización del Estado de Carga restando la energía extraída del almacenamiento
        SOC_actual = SOC_actual - (Energia_entregada / Capacidad_bat) * 100;

        % Validación del límite inferior absoluto para prevenir el vaciamiento profundo de la batería
        if SOC_actual < 0
            SOC_actual = 0;
        end

        % Registro del faltante no cubierto
        E_excedente_hist(hora) = 0;
        E_faltante_hist(hora) = Faltante - Energia_entregada;

        % Evaluación condicional jerárquica para la desconexión inteligente de cargas (Load Shedding)
        if SOC_actual > 40

            % Ruta Segura: Capacidad de almacenamiento suficiente para mantener la operación nominal total
            Escuela = 'Activa';
            Bombeo = 'Activo';
            Alumbrado = 'Activo';

        elseif SOC_actual > 20

            % Ruta de Alerta: Suspensión preventiva de cargas de baja prioridad para mitigar el consumo
            Escuela = 'Activa';
            Bombeo = 'Activo';
            Alumbrado = 'Suspendido';

        else

            % Ruta de Emergencia: Desconexión de cargas de media prioridad para preservar la escuela rural
            Escuela = 'Activa';
            Bombeo = 'Suspendido';
            Alumbrado = 'Suspendido';

        end

    end

    % Almacenamiento de los datos de estado resultantes en los vectores históricos correspondientes
    SOC_historial(hora) = SOC_actual;
    Estado_Escuela{hora} = Escuela;
    Estado_Bombeo{hora} = Bombeo;
    Estado_Alumbrado{hora} = Alumbrado;

    % Generación de reporte formateado por consola con los parámetros operativos de la hora evaluada
    fprintf('Hora: %02d:00 | Gen: %5.1f kWh | Dem: %5.1f kWh | SOC: %5.1f%% | Esc: %-10s | Bomb: %-10s | Alum: %-10s\n', ...
        hora, E_gen, E_dem, SOC_actual, Escuela, Bombeo, Alumbrado);

end

% Resumen final en tabla para análisis o exportación
Resumen = table(horas.', E_solar.', E_eolica.', E_demanda.', (E_solar + E_eolica).', SOC_historial.', ...
    string(Estado_Escuela).', string(Estado_Bombeo).', string(Estado_Alumbrado).', ...
    'VariableNames', {'Hora', 'Solar_kWh', 'Eolica_kWh', 'Demanda_kWh', 'Generacion_kWh', 'SOC_porcentaje', ...
    'Estado_Escuela', 'Estado_Bombeo', 'Estado_Alumbrado'});

% Gráfica del balance energético y del SOC
figure('Name', 'Balance Energetico');
subplot(2, 1, 1);
plot(horas, E_solar + E_eolica, '-o', 'LineWidth', 1.5);
hold on;
plot(horas, E_demanda, '-s', 'LineWidth', 1.5);
grid on;
xlabel('Hora');
ylabel('Energia (kWh)');
legend('Generacion Hibrida', 'Demanda', 'Location', 'best');
title('Balance Energetico Diario');

subplot(2, 1, 2);
stairs(horas, SOC_historial, 'LineWidth', 1.5);
grid on;
xlabel('Hora');
ylabel('SOC (%)');
ylim([0 100]);
title('Estado de Carga de la Bateria');
