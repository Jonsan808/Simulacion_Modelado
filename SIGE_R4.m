% SOFTWARE PARA INGENIERÍA - (203036A_2204)
% Reto 4 - Manual e Informe Técnico Final Sistema SIGE
% Título: Sistema Inteligente de Gestión Energética (SIGE) — Interfaz Visual (HMI)
% Integrantes: Jonathan Sánchez / Cristian R. Sánchez Durán / Jean C. Silva Ariza / Manuel A. Silva Mendieta
% Tutor: Juan Monrroy
% Grupo: 184
% Plataforma: MATLAB App Designer / Versión R2023 o superior
% Escuela de Ciencias Básicas Tecnología e Ingeniería (ECBTI)
% Fecha: 24 de noviembre de 2026

function SIGE_R4                                           % Define la función principal con el mismo nombre del archivo (guardar como SIGE_R4.m).
% HMI del SIGE - Reto 4 - Software para ingeniería (203036)  % Descripción general del programa.
% Ejecución: escribir SIGE_R4 en la ventana de comandos.   % Instrucción de uso.

clc;                                                         % Limpia la ventana de comandos.
close all;                                                   % Cierra figuras abiertas anteriormente.

%% PARÁMETROS DEL SISTEMA
capacidadBat = 100;                                          % Capacidad nominal de la batería en kWh.
eficienciaCarga = 0.95;                                      % Eficiencia de carga de la batería.
eficienciaDescarga = 0.95;                                   % Eficiencia de descarga de la batería.
tiempoPaso = 1/60;                                           % Paso de simulación de 1 minuto expresado en horas.
pesoEscuela = 0.40;                                          % Peso de prioridad para la Escuela Rural.
pesoBombeo = 0.35;                                           % Peso de prioridad para el Bombeo de Agua.
pesoAlumbrado = 0.25;                                        % Peso de prioridad para el Alumbrado Público.
pesos = [pesoEscuela pesoBombeo pesoAlumbrado];              % Agrupa los pesos en un vector fila (Escuela, Bombeo, Alumbrado).
duracion = 60;                                               % Duración máxima de la simulación en minutos (antes 15 min).
retardo = 0.15;                                              % Pausa real entre cada minuto simulado, en segundos.
umbralAlerta = 40;                                           % SOC por debajo del cual se suspende el Alumbrado Público.
umbralEmergencia = 20;                                       % SOC por debajo del cual se suspende también el Bombeo de Agua.
histeresis = 2;                                              % Banda de histéresis en puntos de SOC para evitar parpadeo de los LED.
tablaEstados = [1 1 1; ...                                   % Nivel 1 (segura): Escuela, Bombeo y Alumbrado activos.
                1 1 0; ...                                   % Nivel 2 (alerta): se desconecta el Alumbrado Público.
                1 0 0];                                      % Nivel 3 (emergencia): solo permanece la Escuela Rural.
colorActivo = [0 1 0];                                       % Color verde para relé cerrado (servicio activo).
colorSuspendido = [1 0 0];                                   % Color rojo para relé abierto (servicio suspendido).

%% VALORES INICIALES
valorInicialSolar = 100;                                     % Valor inicial de la generación solar.
valorInicialEolica = 50;                                     % Valor inicial de la generación eólica.
valorInicialDemanda = 60;                                    % Valor inicial de la demanda comunitaria.
valorInicialSOC = 50;                                        % Valor inicial del estado de carga.

%% VARIABLES DE ESTADO COMPARTIDAS CON LAS FUNCIONES ANIDADAS
ejecutando = false;                                          % Bandera que indica si la simulación está en marcha.
muestra = 0;                                                 % Contador de minutos simulados (muestras almacenadas).
socActual = valorInicialSOC;                                 % Estado de carga vigente de la batería.
nivel = 1;                                                   % Nivel de operación vigente (1 segura, 2 alerta, 3 emergencia).
tiempoHist = 0:duracion;                                     % Vector temporal del búfer de graficación en minutos.
genHist = nan(1,duracion+1);                                 % Búfer de generación total (NaN = sin dato aún).
demHist = nan(1,duracion+1);                                 % Búfer de demanda original.
atendidaHist = nan(1,duracion+1);                            % Búfer de demanda atendida tras la desconexión.

%% VENTANA PRINCIPAL
fig = uifigure('Name','Reto 4 SIGE', ...                     % Crea la ventana principal.
    'Position',[50 30 1200 740]);                            % Define posición y tamaño (740 px de alto para pantallas pequeñas).
fig.Color = [0.96 0.97 0.98];                                % Asigna un fondo claro a la interfaz.
fig.CloseRequestFcn = @(~,~) cerrarAplicacion();             % Detiene la simulación antes de cerrar la ventana.

uipanel(fig, ...                                             % Crea la barra decorativa superior (sin guardar variable).
    'Position',[20 690 1160 20], ...                         % Barra que está encima del título.
    'BackgroundColor',[0.00 0.50 0.00], ...                  % Color de la barra en RGB (rojo 0, verde 0.5, azul 0).
    'BorderType','none');                                    % Quita el borde del panel.

%% TÍTULO GENERAL
titulo = uilabel(fig,'Position',[300 650 600 35]);           % Crea la etiqueta del título general.
titulo.Text = 'RETO 4 - HMI DEL SIGE';                       % Define el título de la aplicación.
titulo.FontSize = 18;                                        % Ajusta el tamaño de fuente.
titulo.FontWeight = 'bold';                                  % Coloca el texto en negrita.
titulo.HorizontalAlignment = 'center';                       % Centra el texto horizontalmente.

%% PANEL DE ENTRADAS
panelEntradas = uipanel(fig,'Title','ENTRADAS DE ENERGÍA', ... % Crea el panel de entradas.
    'Position',[20 390 340 240]);                            % Define su ubicación y tamaño.

uilabel(panelEntradas,'Text','Generación solar (0 - 150 kW)', ... % Etiqueta de la generación solar con su rango.
    'Position',[15 180 220 22]);                             % Posiciona la etiqueta.
solarSlider = uislider(panelEntradas,'Limits',[0 150], ...   % Crea el deslizador solar (0 a 150 kW).
    'Value',valorInicialSolar,'Position',[20 170 290 3]);    % Asigna valor inicial y posición.
solarValor = uilabel(panelEntradas,'Position',[250 190 80 20]); % Crea el texto del valor solar.
solarValor.Text = sprintf('%.1f kW',valorInicialSolar);      % Muestra el valor inicial.
solarSlider.ValueChangingFcn = @(~,evento) actualizarValor(solarValor,evento.Value,'kW'); % Actualiza el texto mientras se arrastra.
solarSlider.ValueChangedFcn = @(fuente,~) actualizarValor(solarValor,fuente.Value,'kW');  % Actualiza el texto al soltar.

uilabel(panelEntradas,'Text','Generación eólica (0 - 100 kW)', ... % Etiqueta de la generación eólica con su rango.
    'Position',[15 120 220 22]);                             % Posiciona la etiqueta.
eolicaSlider = uislider(panelEntradas,'Limits',[0 100], ...  % Crea el deslizador eólico (0 a 100 kW).
    'Value',valorInicialEolica,'Position',[20 110 290 3]);   % Asigna valor inicial y posición.
eolicaValor = uilabel(panelEntradas,'Position',[250 130 80 20]); % Crea el texto del valor eólico.
eolicaValor.Text = sprintf('%.1f kW',valorInicialEolica);    % Muestra el valor inicial.
eolicaSlider.ValueChangingFcn = @(~,evento) actualizarValor(eolicaValor,evento.Value,'kW'); % Actualiza el texto mientras se arrastra.
eolicaSlider.ValueChangedFcn = @(fuente,~) actualizarValor(eolicaValor,fuente.Value,'kW');  % Actualiza el texto al soltar.

uilabel(panelEntradas,'Text','Demanda comunitaria (0 - 200 kW)', ... % Etiqueta de la demanda con su rango.
    'Position',[15 60 230 22]);                              % Posiciona la etiqueta.
demandaSlider = uislider(panelEntradas,'Limits',[0 200], ... % Crea el deslizador de demanda (0 a 200 kW).
    'Value',valorInicialDemanda,'Position',[20 50 290 3]);   % Asigna valor inicial y posición.
demandaValor = uilabel(panelEntradas,'Position',[250 70 80 20]); % Crea el texto de la demanda.
demandaValor.Text = sprintf('%.1f kW',valorInicialDemanda);  % Muestra el valor inicial.
demandaSlider.ValueChangingFcn = @(~,evento) actualizarValor(demandaValor,evento.Value,'kW'); % Actualiza el texto mientras se arrastra.
demandaSlider.ValueChangedFcn = @(fuente,~) actualizarValor(demandaValor,fuente.Value,'kW');  % Actualiza el texto al soltar.

%% PANEL DE SOC INICIAL
panelSOC = uipanel(fig,'Title','ESTADO DE CARGA INICIAL', ... % Crea el panel del SOC inicial.
    'Position',[20 300 340 75]);                             % Define su posición y tamaño.
socSlider = uislider(panelSOC,'Limits',[0 100], ...          % Crea el deslizador del SOC (0 a 100 %).
    'Value',valorInicialSOC,'Position',[20 35 290 3]);       % Asigna valor inicial y posición.
socTexto = uilabel(panelSOC,'Position',[250 45 80 20]);      % Crea el texto del SOC.
socTexto.Text = sprintf('%.0f %%',valorInicialSOC);          % Muestra el valor inicial.
socSlider.ValueChangingFcn = @(~,evento) actualizarValor(socTexto,evento.Value,'%'); % Actualiza el texto mientras se arrastra.
socSlider.ValueChangedFcn = @(fuente,~) actualizarValor(socTexto,fuente.Value,'%');  % Actualiza el texto al soltar.

%% PANEL DE BATERÍA
panelBateria = uipanel(fig,'Title','BATERÍA', ...            % Crea el panel de batería.
    'Position',[390 420 300 210]);                           % Define posición y tamaño.
uilabel(panelBateria,'Text','SOC de batería (%)', ...        % Crea el título del medidor.
    'Position',[70 185 180 20], ...                          % Posiciona el título.
    'HorizontalAlignment','center');                         % Centra el texto.
socGauge = uigauge(panelBateria,'semicircular', ...          % Crea el medidor semicircular.
    'Position',[45 25 210 155]);                             % Define su ubicación y tamaño.
socGauge.Limits = [0 100];                                   % Define los límites del medidor (0 % a 100 %).
socGauge.ScaleColors = [1 0.3 0.3; 1 0.8 0; 0.3 0.8 0.3];    % Zonas de color: rojo, amarillo y verde.
socGauge.ScaleColorLimits = [0 20; 20 40; 40 100];           % Rangos de cada zona según los umbrales del SIGE.
socGauge.Value = valorInicialSOC;                            % Asigna el valor inicial del SOC.

%% PANEL DE SERVICIOS PRIORITARIOS
panelServicios = uipanel(fig,'Title','ESTADO DE SERVICIOS', ... % Crea el panel de servicios.
    'Position',[720 420 350 210]);                           % Define posición y tamaño.
uilabel(panelServicios,'Text','Escuela Rural', ...           % Etiqueta del primer servicio.
    'Position',[25 145 150 25]);                             % Posiciona la etiqueta.
escuelaLamp = uilamp(panelServicios,'Position',[240 148 25 25]); % Crea la lámpara de la escuela.
escuelaLamp.Color = colorActivo;                             % Inicia en verde.
uilabel(panelServicios,'Text','Bombeo de Agua', ...          % Etiqueta del segundo servicio.
    'Position',[25 95 150 25]);                              % Posiciona la etiqueta.
bombeoLamp = uilamp(panelServicios,'Position',[240 98 25 25]); % Crea la lámpara del bombeo.
bombeoLamp.Color = colorActivo;                              % Inicia en verde.
uilabel(panelServicios,'Text','Alumbrado Público', ...       % Etiqueta del tercer servicio.
    'Position',[25 45 150 25]);                              % Posiciona la etiqueta.
alumbradoLamp = uilamp(panelServicios,'Position',[240 48 25 25]); % Crea la lámpara del alumbrado.
alumbradoLamp.Color = colorActivo;                           % Inicia en verde.

%% PANEL DE INFORMACIÓN
panelInfo = uipanel(fig,'Title','INFORMACIÓN DEL SISTEMA', ... % Crea el panel informativo.
    'Position',[720 300 350 100]);                           % Define posición y tamaño.
infoLabel = uilabel(panelInfo,'Position',[15 5 320 70]);     % Crea la etiqueta de información.
infoLabel.WordWrap = 'on';                                   % Permite varias líneas de texto.
infoLabel.Text = 'Sistema preparado para simulación';        % Mensaje inicial.
infoLabel.FontSize = 12;                                     % Ajusta el tamaño de fuente.

%% EJE DE GRAFICACIÓN
eje = uiaxes(fig,'Position',[40 15 1130 270]);               % Crea el eje para la gráfica (ampliado para ver mejor las curvas).
title(eje,'GENERACIÓN Y DEMANDA ENERGÉTICA');                % Define el título de la gráfica.
xlabel(eje,'Tiempo (minutos)');                              % Etiqueta del eje X.
ylabel(eje,'Potencia (kW)');                                 % Etiqueta del eje Y.
grid(eje,'on');                                              % Activa la cuadrícula.
hold(eje,'on');                                              % Permite superponer las tres curvas.
lineaGen = plot(eje,tiempoHist,genHist,'Color',[0 0.6 0],'LineWidth',2);        % Curva de generación total (verde).
lineaDem = plot(eje,tiempoHist,demHist,'r--','LineWidth',2);                    % Curva de demanda original (rojo discontinuo).
lineaAtend = plot(eje,tiempoHist,atendidaHist,'b','LineWidth',2);               % Curva de demanda atendida (azul).
hold(eje,'off');                                             % Desactiva la superposición.
xlim(eje,[0 duracion]);                                      % Fija el eje X a la duración de la simulación.
ylim(eje,[0 260]);                                           % Fija el eje Y para cubrir la generación máxima (250 kW).
legend(eje,'Generación total','Demanda original', ...        % Agrega la leyenda una sola vez.
    'Demanda atendida','Location','northeast');              % Ubica la leyenda en la esquina superior derecha.

%% BOTÓN DE EJECUCIÓN (CONMUTADOR)
conmutador = uibutton(fig,'state', ...                       % Crea el conmutador de inicio y parada de la simulación.
    'Text','INICIAR SIMULACIÓN', ...                         % Define el texto del conmutador.
    'Position',[380 345 160 40]);                            % Define posición (sin solaparse con el panel de información).
conmutador.BackgroundColor = [0.1 0.55 0.25];                % Asigna color de fondo verde.
conmutador.FontColor = [1 1 1];                              % Asigna color del texto blanco.
conmutador.ValueChangedFcn = @(~,~) alternarSimulacion();    % Asocia la simulación al conmutador.

%% BOTÓN DE REINICIO
reiniciarBoton = uibutton(fig,'push', ...                    % Crea el botón de reinicio.
    'Text','REINICIAR SISTEMA', ...                          % Define el texto del botón.
    'Position',[550 345 160 40]);                            % Define posición (termina antes del panel de información).
reiniciarBoton.ButtonPushedFcn = @(~,~) reiniciar();         % Asocia el reinicio al botón.

%% BOTONES DE ESCENARIOS PREDEFINIDOS (facilitan las pruebas del Paso 3)
uibutton(fig,'push','Text','Escenario A', ...                % Botón que carga el escenario de superávit.
    'Position',[380 302 100 32], ...                         % Define posición.
    'ButtonPushedFcn',@(~,~) cargarEscenario(120,60,80,50)); % Solar 120, eólica 60, demanda 80 kW, SOC 50 %.
uibutton(fig,'push','Text','Escenario B', ...                % Botón que carga el escenario de alerta.
    'Position',[490 302 100 32], ...                         % Define posición.
    'ButtonPushedFcn',@(~,~) cargarEscenario(50,30,60,50));  % Solar 50, eólica 30, demanda 60 kW, SOC 50 % (luego subir demanda).
uibutton(fig,'push','Text','Escenario C', ...                % Botón que carga el escenario de emergencia.
    'Position',[600 302 100 32], ...                         % Define posición.
    'ButtonPushedFcn',@(~,~) cargarEscenario(40,20,150,25)); % Solar 40, eólica 20, demanda 150 kW, SOC 25 %.

%% FUNCIÓN AUXILIAR: ACTUALIZAR ETIQUETAS NUMÉRICAS
    function actualizarValor(etiqueta,valor,unidad)          % Actualiza el texto de un control con el valor recibido.
        if strcmp(unidad,'%')                                % Verifica si el dato es porcentaje.
            etiqueta.Text = sprintf('%.0f %%',valor);        % Muestra el valor sin decimales.
        else                                                 % Si el dato es potencia...
            etiqueta.Text = sprintf('%.1f %s',valor,unidad); % Muestra el valor con unidad.
        end                                                  % Finaliza la condición.
    end                                                      % Finaliza la función auxiliar.

%% FUNCIÓN AUXILIAR: NIVEL DE OPERACIÓN CON HISTÉRESIS
    function nuevoNivel = evaluarNivel(socValor,nivelPrevio) % Determina el nivel (1, 2 o 3) a partir del SOC.
        if socValor <= umbralEmergencia                      % Si el SOC es menor o igual a 20 %...
            nuevoNivel = 3;                                  % ...se activa la ruta de emergencia.
        elseif socValor <= umbralAlerta                      % Si el SOC está entre 20 % y 40 %...
            if nivelPrevio == 3 && socValor <= umbralEmergencia + histeresis % ...y venía de emergencia sin superar la banda...
                nuevoNivel = 3;                              % ...se mantiene la emergencia (evita parpadeo).
            else                                             % En caso contrario...
                nuevoNivel = 2;                              % ...se activa la ruta de alerta.
            end                                              % Finaliza la verificación de emergencia.
        else                                                 % Si el SOC es mayor a 40 %...
            if nivelPrevio >= 2 && socValor <= umbralAlerta + histeresis % ...y venía de alerta sin superar la banda...
                nuevoNivel = 2;                              % ...se mantiene la alerta (evita parpadeo).
            else                                             % En caso contrario...
                nuevoNivel = 1;                              % ...se activa la ruta segura.
            end                                              % Finaliza la verificación de alerta.
        end                                                  % Finaliza la selección del nivel.
    end                                                      % Finaliza la función de nivel.

%% FUNCIÓN AUXILIAR: ACTUALIZAR SALIDAS VISUALES
    function actualizarSalidas(estado)                       % Refresca medidor, lámparas y gráfica con el estado vigente.
        socGauge.Value = socActual;                          % Actualiza el medidor con el SOC actual.
        lamparas = [escuelaLamp bombeoLamp alumbradoLamp];   % Agrupa las tres lámparas en un arreglo.
        for j = 1:3                                          % Recorre las tres cargas.
            if estado(j) == 1                                % Si el relé está cerrado...
                lamparas(j).Color = colorActivo;             % ...la lámpara se pone en verde.
            else                                             % Si el relé está abierto...
                lamparas(j).Color = colorSuspendido;         % ...la lámpara se pone en rojo.
            end                                              % Finaliza la verificación del relé.
        end                                                  % Finaliza el recorrido de lámparas.
        lineaGen.YData = genHist;                            % Actualiza la curva de generación.
        lineaDem.YData = demHist;                            % Actualiza la curva de demanda original.
        lineaAtend.YData = atendidaHist;                     % Actualiza la curva de demanda atendida.
    end                                                      % Finaliza la actualización de salidas.

%% FUNCIÓN AUXILIAR: LIMPIAR EL BÚFER DE GRAFICACIÓN
    function limpiarHistoriales()                            % Borra los datos de la corrida anterior.
        muestra = 0;                                         % Reinicia el contador de minutos.
        genHist(:) = nan;                                    % Vacía el búfer de generación.
        demHist(:) = nan;                                    % Vacía el búfer de demanda.
        atendidaHist(:) = nan;                               % Vacía el búfer de demanda atendida.
        lineaGen.YData = genHist;                            % Borra la curva de generación.
        lineaDem.YData = demHist;                            % Borra la curva de demanda.
        lineaAtend.YData = atendidaHist;                     % Borra la curva de demanda atendida.
    end                                                      % Finaliza la limpieza.

%% FUNCIÓN: CONMUTADOR DE LA SIMULACIÓN
    function alternarSimulacion()                            % Se ejecuta cada vez que cambia el conmutador.
        if conmutador.Value                                  % Si el conmutador quedó activado...
            ejecutar();                                      % ...inicia la simulación.
        else                                                 % Si el conmutador quedó desactivado...
            ejecutando = false;                              % ...solicita detener el ciclo de simulación.
        end                                                  % Finaliza la verificación del conmutador.
    end                                                      % Finaliza la función del conmutador.

%% FUNCIÓN DE SIMULACIÓN
    function ejecutar()                                      % Ejecuta la lógica del SIGE minuto a minuto.
        if muestra >= duracion + 1                           % Si la corrida anterior ya terminó...
            limpiarHistoriales();                            % ...se limpia el búfer para una corrida nueva.
        end                                                  % Finaliza la verificación de corrida previa.
        if muestra == 0                                      % Si se trata de una corrida nueva (no una reanudación)...
            socActual = socSlider.Value;                     % ...se toma el SOC inicial del deslizador.
            nivel = evaluarNivel(socActual,1);               % ...y se calcula el nivel inicial sin histéresis.
        end                                                  % Finaliza la inicialización.
        ejecutando = true;                                   % Marca la simulación como en marcha.
        conmutador.Text = 'DETENER SIMULACIÓN';              % Cambia el texto del conmutador.
        conmutador.BackgroundColor = [0.75 0.15 0.15];       % Cambia el color a rojo mientras corre.
        while ejecutando && isvalid(fig) && muestra < duracion + 1 % Ciclo temporal: minuto a minuto.
            muestra = muestra + 1;                           % Avanza un minuto simulado.
            solar = solarSlider.Value;                       % Lee la generación solar.
            eolica = eolicaSlider.Value;                     % Lee la generación eólica.
            demanda = demandaSlider.Value;                   % Lee la demanda comunitaria.
            generacion = solar + eolica;                     % Calcula la generación total.
            nivel = evaluarNivel(socActual,nivel);           % Determina el nivel de operación según el SOC vigente.
            estado = tablaEstados(nivel,:);                  % Obtiene el estado de los relés para ese nivel.
            demandaAtendida = demanda * (pesos * estado.');  % Calcula la demanda conectada (suma ponderada de cargas activas).
            balance = generacion - demandaAtendida;          % Calcula el balance energético.
            if balance >= 0                                  % Si existe excedente energético...
                socActual = socActual + (balance*tiempoPaso*eficienciaCarga/capacidadBat)*100; % Aumenta el SOC.
            else                                             % Si existe déficit energético...
                socActual = socActual + (balance*tiempoPaso/(capacidadBat*eficienciaDescarga))*100; % Reduce el SOC.
            end                                              % Finaliza la actualización.
            socActual = min(100,max(0,socActual));           % Limita el SOC entre 0 y 100.
            nivel = evaluarNivel(socActual,nivel);           % Reevalúa el nivel con el SOC ya actualizado (coherencia LED-medidor).
            estado = tablaEstados(nivel,:);                  % Estado de relés que se mostrará en pantalla.
            genHist(muestra) = generacion;                   % Guarda la generación en el búfer.
            demHist(muestra) = demanda;                      % Guarda la demanda original.
            atendidaHist(muestra) = demandaAtendida;         % Guarda la demanda atendida.
            switch nivel                                     % Selecciona el mensaje según el nivel.
                case 1                                       % Nivel seguro.
                    mensaje = 'OPERACIÓN NORMAL';            % Mensaje del sistema.
                case 2                                       % Nivel de alerta.
                    mensaje = 'ALERTA: ALUMBRADO DESCONECTADO'; % Mensaje de alerta.
                otherwise                                    % Nivel de emergencia.
                    mensaje = 'EMERGENCIA: CARGAS NO PRIORITARIAS DESCONECTADAS'; % Mensaje crítico.
            end                                              % Finaliza la selección del mensaje.
            actualizarSalidas(estado);                       % Refresca medidor, lámparas y gráfica.
            infoLabel.Text = sprintf('%s | t = %d min | Generación: %.1f kW | Demanda: %.1f kW | SOC: %.2f %%', ...
                mensaje,muestra-1,generacion,demanda,socActual); % Muestra el estado operativo.
            drawnow limitrate;                               % Refresca la interfaz sin saturar el procesador.
            pause(retardo);                                  % Espera para que la gráfica se vea en tiempo real y se atiendan los controles.
        end                                                  % Finaliza el ciclo temporal.
        if isvalid(fig)                                      % Si la ventana sigue abierta...
            ejecutando = false;                              % ...se marca la simulación como detenida.
            conmutador.Value = false;                        % ...se desactiva el conmutador.
            conmutador.Text = 'INICIAR SIMULACIÓN';          % ...se restaura el texto.
            conmutador.BackgroundColor = [0.1 0.55 0.25];    % ...y el color verde.
            if muestra >= duracion + 1                       % Si se completó la duración...
                infoLabel.Text = [infoLabel.Text ' | FIN']; % ...se indica el fin de la corrida.
            end                                              % Finaliza la verificación de fin.
        end                                                  % Finaliza la verificación de la ventana.
    end                                                      % Finaliza la simulación.

%% FUNCIÓN: CARGAR ESCENARIO PREDEFINIDO
    function cargarEscenario(solarKW,eolicaKW,demandaKW,socIni) % Ajusta los controles a un escenario de prueba.
        reiniciar();                                         % Detiene y limpia el sistema antes de cargar los valores.
        solarSlider.Value = solarKW;                         % Asigna la generación solar.
        eolicaSlider.Value = eolicaKW;                       % Asigna la generación eólica.
        demandaSlider.Value = demandaKW;                     % Asigna la demanda.
        socSlider.Value = socIni;                            % Asigna el SOC inicial.
        actualizarValor(solarValor,solarKW,'kW');            % Actualiza el texto solar.
        actualizarValor(eolicaValor,eolicaKW,'kW');          % Actualiza el texto eólico.
        actualizarValor(demandaValor,demandaKW,'kW');        % Actualiza el texto de demanda.
        actualizarValor(socTexto,socIni,'%');                % Actualiza el texto del SOC.
        socActual = socIni;                                  % Sincroniza el SOC interno.
        nivel = evaluarNivel(socActual,1);                   % Calcula el nivel inicial del escenario.
        actualizarSalidas(tablaEstados(nivel,:));            % Muestra el estado inicial en medidor y lámparas.
        infoLabel.Text = 'Escenario cargado. Presionar INICIAR SIMULACIÓN.'; % Indica el siguiente paso al operador.
    end                                                      % Finaliza la carga de escenario.

%% FUNCIÓN DE REINICIO
    function reiniciar()                                     % Restablece la interfaz.
        ejecutando = false;                                  % Detiene cualquier simulación en curso.
        conmutador.Value = false;                            % Desactiva el conmutador.
        conmutador.Text = 'INICIAR SIMULACIÓN';              % Restaura el texto del conmutador.
        conmutador.BackgroundColor = [0.1 0.55 0.25];        % Restaura el color del conmutador.
        solarSlider.Value = valorInicialSolar;               % Restaura la generación solar.
        eolicaSlider.Value = valorInicialEolica;             % Restaura la generación eólica.
        demandaSlider.Value = valorInicialDemanda;           % Restaura la demanda.
        socSlider.Value = valorInicialSOC;                   % Restaura el SOC inicial.
        solarValor.Text = sprintf('%.1f kW',valorInicialSolar);   % Actualiza el texto solar.
        eolicaValor.Text = sprintf('%.1f kW',valorInicialEolica); % Actualiza el texto eólico.
        demandaValor.Text = sprintf('%.1f kW',valorInicialDemanda); % Actualiza el texto de demanda.
        socTexto.Text = sprintf('%.0f %%',valorInicialSOC);  % Actualiza el texto del SOC.
        socActual = valorInicialSOC;                         % Restaura el SOC interno.
        nivel = 1;                                           % Restaura el nivel de operación seguro.
        limpiarHistoriales();                                % Limpia el búfer y la gráfica.
        actualizarSalidas(tablaEstados(1,:));                % Reactiva medidor y las tres lámparas en verde.
        infoLabel.Text = 'Sistema reiniciado y listo para operar'; % Muestra el mensaje de reinicio.
    end                                                      % Finaliza el reinicio.

%% FUNCIÓN DE CIERRE SEGURO
    function cerrarAplicacion()                              % Cierra la aplicación sin dejar el ciclo activo.
        ejecutando = false;                                  % Detiene el ciclo de simulación.
        delete(fig);                                         % Elimina la ventana principal.
    end                                                      % Finaliza el cierre seguro.

end                                                          % Finaliza la función principal.