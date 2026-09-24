%% ---------------------------------------------------------
% Nombre del estudiante: Jonathan Sanchez
% Grupo: Grupo – 184
% Programa: Ingeniería de Telecomunicaciones
% Código Fuente: Autoría Propia
% ---------------------------------------------------------

%% SIMULACIÓN Y MODELADO DE UNA MICRO-RED HÍBRIDA
% Este bloque identifica el programa y establece que la simulación 
% representa una micro-red híbrida mediante generación solar, generación 
% eólica y demanda eléctrica de la comunidad.

% Este comentario indica que el modelo integra tres componentes principales:
% generación solar, generación eólica y demanda de la comunidad.

% Cada posición de los vectores representa una hora específica del día.

% El periodo de simulación comprende las horas 1 a 24.

% El objetivo del script es representar la generación solar.

% El objetivo del script es representar la generación eólica.

% El objetivo del script es calcular la generación híbrida total.

% El objetivo del script es representar la demanda eléctrica.

% Finalmente, se realiza una comparación gráfica entre la generación total
% disponible y la demanda eléctrica de la comunidad.


% Esta instrucción limpia la ventana de comandos de MATLAB para que los
% resultados de la ejecución actual aparezcan de forma organizada.
clc;

% Esta instrucción elimina las variables almacenadas previamente en el
% espacio de trabajo para evitar que valores antiguos interfieran
% con los cálculos de la simulación.
clear;

% Esta instrucción cierra todas las ventanas de figuras que se encuentren
% abiertas antes de generar la nueva gráfica de la micro-red.
close all;


%% 1. VECTOR DE TIEMPO

% Esta sección establece las 24 horas que serán utilizadas como referencia
% temporal para todos los vectores de generación y demanda.


% Esta instrucción crea un vector fila desde 1 hasta 24.
% El operador ":" genera una secuencia consecutiva de valores enteros.
% Cada posición del vector representa una hora del día.
horas = (1:24);


%% 2. VECTOR DE GENERACIÓN SOLAR

% Esta sección define la potencia de generación solar correspondiente
% a cada una de las 24 horas del día.


% El vector P_solar almacena la potencia solar en kW.
% Cada posición corresponde a una hora específica.
%
% Horas 1 a 5: generación solar igual a 0 kW.
% Horas 6 a 12: aumento progresivo hasta alcanzar 25 kW.
% Horas 13 a 18: disminución progresiva.
% Horas 19 a 24: generación solar igual a 0 kW.

% Los puntos suspensivos (...) permiten continuar la definición del mismo 
% vector en la siguiente línea.
% A. = Los valores de las horas 1 a 6 son: Estos cinco valores representan las horas 1 a 5, durante las cuales la generación solar es igual a cero.
% B. = Estos siete valores representan las horas 6 a 12,con crecimiento progresivo hasta el máximo de 25 kW.
% C. = Estos seis valores representan las horas 13 a 18, mostrando la disminución progresiva de la generación solar.
% D. = Estos seis valores representan las horas 19 a 24, durante las cuales la generación solar es igual a cero.

P_solar = [ ...
    0  0  0  0  0 ...              % A. = Horas 1 a 5 
    3  6  10  15  20  23  25 ...   % B. = Horas 6 a 12 
    23  20  16  11  6  2 ...       % C. = Horas 13 a 18 
    0  0  0  0  0  0 ];            % D. = Horas 19 a 24


% Esta instrucción es otra forma de definir el vector P_solar en una sola línea contiene exactamente los mismos 24 valores del vector solar.
% P_solar = [0,0,0,0,0,3,6,10,15,20,23,25,23,20,16,11,6,2,0,0,0,0,0,0];


% Esta instrucción almacena la potencia máxima establecida para
% la generación solar.
% El valor corresponde a 25 kW.
Pmax_solar = 25; %25kW


% La función reshape reorganiza el vector P_solar.
% El primer argumento "1" establece una fila.
% El argumento "[]" permite que MATLAB determine automáticamente
% el número de columnas necesarias para conservar todos los datos.
P_solar = reshape(P_solar,1,[]);


%% 3. VECTOR DE GENERACIÓN EÓLICA

% Esta sección define la generación eólica durante las 24 horas.
% A diferencia de la generación solar, la energía eólica puede existir
% tanto durante el día como durante la noche.


% P_eolica almacena la potencia generada por los aerogeneradores
% para cada una de las 24 horas.
%
% Los valores representan variaciones en la generación producidas
% por diferentes condiciones del viento.
%
% Ningún valor supera el límite máximo de 15 kW establecido.
% A. = Los valores de las horas 1 a 6 son: 7, 9, 6, 8, 5 y 3 kW.
% B. = Los valores de las horas 7 a 12 son: 10, 8, 11, 9, 12 y 10 kW.
% C. = Los valores de las horas 13 a 18 son: 13, 9, 11, 7, 1 y 12 kW.
% D. = Los valores de las horas 19 a 24 son: 10, 14, 11, 9, 8 y 6 kW.

P_eolica = [ ...
    7 9 6 8 5 3 ...                       % A. = Horas 1 a 6
    10 8 11 9 12 10 ...                   % B. = Horas 7 a 12
    13 9 11 7 1 12 ...                    % C. = Horas 13 a 18
    10 14 11 9 8 6 ];                     % D. = Horas 19 a 24


% Esta instrucción vuelve a definir el vector eólico en una sola línea.
% Se conserva exactamente como aparece en el código suministrado.
% P_eolica = [7,9,6,8,5,3,10,8,11,9,12,10,13,9,11,7,1,12,10,14,11,9,8,6];


% Esta instrucción almacena la potencia máxima nominal establecida
% para la generación eólica.
Pmax_eolica = 15; %15kW


% Esta función garantiza que P_eolica quede organizado como vector fila.
P_eolica = reshape(P_eolica,1,[]);


%% 4. VECTOR DE GENERACIÓN HÍBRIDA TOTAL

% Esta sección calcula la generación total disponible en la micro-red.


% Esta operación realiza una suma elemento a elemento.
% Para cada hora se suma la generación solar con la generación eólica.
%
% Por ejemplo:
% generación total hora 1 = solar hora 1 + eólica hora 1.
%
% El resultado conserva 24 posiciones correspondientes a las 24 horas.
P_generacion_total = P_solar + P_eolica;


%% 5. VECTOR DE LA DEMANDA ELÉCTRICA DE LA COMUNIDAD

% Esta sección define el consumo eléctrico de la comunidad
% durante cada una de las 24 horas.


% P_demanda almacena la potencia demandada en kW.
%
% Horas 1 a 5: consumo entre 2 y 4 kW.
% Horas 6 a 17: consumo entre 6 y 10 kW.
% Horas 18 a 21: periodo de mayor demanda.
% Horas 22 a 24: retorno al consumo nocturno.

% A. = Los valores de las horas 1 a 5 representan el consumo nocturno.
% B. = Estos valores representan la demanda de las horas 6 a 12.
% C. = Estos valores representan la demanda de las horas 13 a 17.
% D. = Estos valores representan la demanda de las horas 18 a 21.
% E. = Estos valores representan la demanda de las horas 22 a 24.

P_demanda = [ ...
    3 2 2 3 4 ...                         % A. = Horas 1 a 5
    6 7 8 9 8 10 9 ...                    % B. = Horas 6 a 12
    8 9 10 8 7 ...                        % C. = Horas 13 a 17
    12 14 15 13 ...                       % D. = Horas 18 a 21
    4 3 2 ];                              % E. = Horas 22 a 24


% Esta instrucción establece la potencia máxima de demanda
% considerada en el modelo de la comunidad.
Pmax_demanda = 15; %15kW


% Esta función organiza el vector de demanda como una fila.
P_demanda = reshape(P_demanda,1,[]);


%% 6. VERIFICACIÓN DE LOS VECTORES

% Esta sección comprueba que los vectores utilizados tengan
% exactamente 24 elementos, uno por cada hora del día.


% La función length devuelve el número de elementos del vector.
% El operador ~= significa "diferente de".
%
% Si P_solar no tiene 24 elementos, se ejecuta la instrucción error.
if length(P_solar) ~= 24

    % La función error detiene la ejecución y muestra el mensaje
    % correspondiente al problema encontrado.
    error('El vector de generación solar debe tener 24 elementos.');

end


% Esta condición verifica que el vector eólico tenga exactamente
% 24 elementos.
if length(P_eolica) ~= 24

    % Esta instrucción muestra un error y detiene la ejecución
    % si el vector eólico no tiene 24 elementos.
    error('El vector de generación eólica debe tener 24 elementos.');

end


% Esta condición verifica que el vector de demanda tenga exactamente
% 24 elementos.
if length(P_demanda) ~= 24

    % Esta instrucción muestra un error y detiene la ejecución
    % si el vector de demanda no tiene 24 elementos.
    error('El vector de demanda debe tener 24 elementos.');

end


%% 7. VERIFICACIÓN DE POTENCIAS MÁXIMAS

% Esta sección comprueba que los valores utilizados en la simulación
% no superen las potencias máximas establecidas.


% La función max identifica el mayor valor del vector solar.
% La condición compara dicho valor con Pmax_solar.
if max(P_solar) > Pmax_solar

    % Esta instrucción detiene la ejecución si la generación solar
    % supera los 25 kW establecidos.
    error('La generación solar supera la potencia máxima de 25 kW.');
end


% Esta condición comprueba que la generación eólica máxima
% no supere los 15 kW establecidos.
if max(P_eolica) > Pmax_eolica

    % Esta instrucción detiene la ejecución si se supera
    % la potencia máxima eólica.
    error('La generación eólica supera la potencia máxima de 15 kW.');

end


% Esta condición verifica que la demanda máxima no supere
% los 15 kW definidos para la comunidad.
if max(P_demanda) > Pmax_demanda

    % Esta instrucción detiene la ejecución si la demanda supera
    % el límite establecido.
    error('La demanda supera la potencia máxima permitida de 15 kW.');

end


%% 8. BALANCE ENERGÉTICO HORARIO

% Esta sección calcula el balance energético de cada hora.


% El balance se obtiene restando la demanda a la generación total.
%
% Si el resultado es positivo:
% existe superávit de generación.
%
% Si el resultado es cero:
% generación y demanda son iguales.
%
% Si el resultado es negativo:
% existe déficit de generación.
balance = P_generacion_total - P_demanda;


%% 9. IDENTIFICACIÓN DE SUPERÁVIT Y DÉFICIT

% Esta sección identifica las horas correspondientes a cada
% condición del balance energético.


% Esta operación lógica selecciona los valores del vector horas
% en los cuales el balance es mayor que cero.
horas_superavit = horas(balance > 0);


% Esta operación lógica selecciona las horas donde el balance
% es exactamente igual a cero.
horas_equilibrio = horas(balance == 0);


% Esta operación lógica selecciona las horas donde el balance
% es menor que cero.
horas_deficit = horas(balance < 0);


%% 10. PRESENTACIÓN DE RESULTADOS EN LA VENTANA DE COMANDOS

% Esta sección presenta los resultados de la simulación
% en la ventana de comandos.


% fprintf permite escribir texto y valores formateados
% directamente en la ventana de comandos.
% '\n' genera un salto de línea.
fprintf('\n');


% Esta instrucción imprime una línea de separación.
fprintf('=============================================\n');


% Esta instrucción presenta el título de los resultados.
fprintf('     RESULTADOS DE LA MICRO-RED HÍBRIDA\n');


% Esta instrucción imprime otra línea de separación.
fprintf('=============================================\n\n');


% max(P_solar) obtiene la mayor potencia solar.
% %.2f muestra el valor numérico con dos decimales.
fprintf('Potencia máxima solar registrada: %.2f kW\n', max(P_solar));


% Esta instrucción imprime una línea para separar visualmente
% los diferentes resultados.
fprintf('........................................................\n');


% max(P_eolica) obtiene la mayor potencia eólica registrada.
fprintf('Potencia máxima eólica registrada: %.2f kW\n', max(P_eolica));


% Esta instrucción imprime una línea de separación.
fprintf('..........................................................\n');


% max(P_demanda) obtiene la mayor demanda registrada.
fprintf('Potencia máxima de demanda: %.2f kW\n', max(P_demanda));


% Esta instrucción imprime una línea de separación.
fprintf('..........................................................\n\n');


% Esta instrucción imprime el encabezado de la tabla horaria.
fprintf('=====================================================================\n');


% Esta instrucción identifica las columnas que aparecerán
% en la tabla de resultados.
fprintf('Hora | P. Solar | P. Eolica | P. Generacion T. | P. Demanda | Balance\n');


% Esta instrucción imprime una línea de separación de la tabla.
fprintf('.....................................................................\n');


% El ciclo for permite recorrer consecutivamente las 24 horas.
% La variable i representa la posición actual de los vectores.
for i = 1:24

    % Esta instrucción presenta los valores correspondientes a la hora i.
    %
    % %2d representa un número entero con dos posiciones.
    % %5.1f, %6.1f, etc. representan valores numéricos con un decimal.
    fprintf('%2d   | %5.1f    | %6.1f    | %9.1f        | %7.1f    | %4.1f\n', ...
        horas(i), ...               % Se obtiene la hora correspondiente a la posición i.
        P_solar(i), ...             % Se obtiene la generación solar de la hora i.
        P_eolica(i), ...            % Se obtiene la generación eólica de la hora i.
        P_generacion_total(i), ...  % Se obtiene la generación híbrida total de la hora i.
        P_demanda(i), ...           % Se obtiene la demanda de la comunidad de la hora i.
        balance(i));                % Se obtiene el balance energético de la hora i.

end


% Esta instrucción imprime una línea de cierre de la tabla.
fprintf('....................................................................................\n\n');


% Esta instrucción imprime una línea de separación antes
% de la clasificación energética.
fprintf('====================================================================================\n');


%% 11. MOSTRAR HORAS CON SUPERÁVIT Y DÉFICIT

% Esta sección muestra las horas clasificadas según el resultado
% del balance energético.


% Esta instrucción presenta el título correspondiente al superávit.
fprintf('Horas con superávit energético:\n');


% disp muestra directamente en la ventana de comandos
% el vector de horas con superávit.
disp(horas_superavit);


% Esta instrucción imprime una línea de separación.
fprintf('....................................................................................\n\n');


% Esta instrucción presenta el título correspondiente al equilibrio.
fprintf('Horas con equilibrio energético:\n');


% disp muestra las horas cuyo balance es exactamente cero.
disp(horas_equilibrio);


% Esta instrucción imprime una línea de separación.
fprintf('....................................................................................\n\n');


% Esta instrucción presenta el título correspondiente al déficit.
fprintf('\nHoras con déficit energético:\n');


% disp muestra las horas cuyo balance es negativo.
disp(horas_deficit);


%% 12. VISUALIZACIÓN GRÁFICA

% Esta sección genera una figura para comparar visualmente
% la generación híbrida total y la demanda de la comunidad.


% figure crea una nueva ventana gráfica de MATLAB.
figure;


% plot genera la curva de generación híbrida total.
%
% horas representa el eje X.
% P_generacion_total representa el eje Y.
%
% 'r--hexagram' establece las características de línea y marcador
% definidas originalmente en el código.
%
% 'LineWidth', 1 establece el grosor de la línea.
%
% 'MarkerSize', 10 establece el tamaño de los marcadores.
plot(horas, P_generacion_total, 'r--hexagram', ...
    'LineWidth', 1, ...     % Esta propiedad establece el grosor de la línea de generación.
    'MarkerSize', 10);      % Esta propiedad establece el tamaño de los marcadores.


% hold on permite conservar la primera curva para incorporar
% la segunda curva dentro de la misma figura.
hold on;


% plot genera la curva correspondiente a la demanda de la comunidad.
%
% horas representa el eje X.
% P_demanda representa el eje Y.
%
% 'b-diamond' establece las características de línea y marcador
% definidas originalmente en el código.
%
% 'LineWidth', 1 establece el grosor de la línea.
%
% 'MarkerSize', 10 establece el tamaño de los marcadores.
plot(horas, P_demanda, 'b-diamond', ...
    'LineWidth', 1, ...     % Esta propiedad establece el grosor de la línea de demanda.
    'MarkerSize', 10);      % Esta propiedad establece el tamaño de los marcadores.


% title establece el nombre que aparecerá en la parte superior
% de la gráfica.
title('Generación Híbrida Total y Demanda de la Micro-red');


% xlabel establece el nombre del eje horizontal.
xlabel('Tiempo en horas');


% ylabel establece el nombre del eje vertical.
ylabel('Potencia en Kilovatios (kW)');


% grid on activa la cuadrícula para facilitar la lectura
% y comparación visual de las curvas.
grid on;


% legend crea la leyenda para identificar cada curva.
legend('Generación Total', ...
    'Demanda de la Comunidad'); % Este texto identifica la segunda curva como demanda eléctrica de la comunidad.


% xticks establece las marcas del eje X para las 24 horas.
xticks(1:24);


% xlim establece los límites del eje horizontal desde la hora 1
% hasta la hora 24.
xlim([1 24]);


% yticks establece las marcas del eje vertical desde 1 hasta 40.
% Se conserva esta instrucción y sus valores originales.
yticks(1:40)


% hold off finaliza la superposición de curvas en la figura.
hold off;