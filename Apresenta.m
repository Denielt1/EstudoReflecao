close all
clear all
clc

%% Display da imagem da linha de transmissão

imagem = imread('linha.png');
imagem2 = imread('linha2.png');
imshow(imagem)

%% Display dos dados de entrada

xzx = inputdlg({'Impedância da Linha','Impedância da Carga'},...
              'Linha de Transmissão', [1 30; 1 30]); 
close all

%% Atribuição dos dados de entrada
          
Zl = str2num(xzx{1,1});
Z0 = str2num(xzx{2,1});

%% Cálculo do coeficiente de reflexão e de VSWR

gama = (Zl-Z0)/(Zl+Z0);               % Coeficiente de reflexão
porcent_reflet = gama^2;              % Porcentagem refletida
SWR = (1+abs(gama))/(1-abs(gama));    % VSWR

%% Definição do início e fim físico

ycontorno = [];
desloc = 3;

ycomeco = (-1.5-desloc):0.1:(1.5+desloc);
xcomeco = zeros(1,length(ycomeco));
yfinal = (-1.5-desloc):0.1:(1.5+desloc);
xfinal = 6 + zeros(1,length(yfinal));

%% Construção das ondas

z = 0:0.01:6;         % Espaço
t = 0:0.01:4;         % Tempo
f = 1.5;              % Frequência
v = 3;                % Velocidade da onda
w = 2*pi*f;           % Frequência angular
beta = w/v;           % Constante de fase

figure('units','normalized','outerposition',[0 0 1 1])  % Cria janela fixa
xlim([-1.5 7.5])                                        % Define tamanho da janela
ylim([(-1.5-desloc) (1.5+desloc)])
Texxtoo1 = ['\Gamma = ',num2str(gama)];                 % Texto inserido(Incidente)

Textoo = text(-1,0,'Incidente \rightarrow', ... 
    'Color','blue','FontSize',14);                      % Set do texto ^

Texxtoo = text(6,3,Texxtoo1,'Color','black', ...        % Texto de Gama
    'FontSize',20);
hold on
image(imagem2,'XData',[0 6],'YData',[-0.8 0.8], ...     % Imagem de fundo
    'AlphaData', 0.2)

%% Plots das ondas

for k1 = 1:length(t)
    plot(xcomeco, ycomeco,'b')              % Plota linha vert. inicial
    hold on
    plot(xfinal, yfinal,'b')                % Plota linha vert. final
    
    A11 =  cos(w*t(k1) -beta.*z + pi/2);    % Função da onda
    T0 = plot(z, A11,'b');                  % Plota onda
    xlim([-1.5 7.5])                        % Mantém limites
    ylim([(-1.5-3) (1.5+3)])

    pause(0.00000001)                       % Reduz velocidade de reprodução
    
    if k1<length(t)
        delete(T0)                          % Deleta plot para inserir o próximo
    end
    
end
pause(1)
delete(T0)                 % Deleta último plot
delete(Textoo)             % Deleta texto de Gama

%% Inicia ondas refletidas

Textoo3 = text(-1,0,'Incidente \rightarrow',...    % Insere texto e seta dir.
    'Color','blue','FontSize',14);
Textoo4 = text(6,0,'\leftarrow Refletida',...      % Insere texto e seta esq.
    'Color','red','FontSize',14);

hold on
for k1 = 1:length(t)
    plot(xcomeco, ycomeco,'b')
    hold on
    plot(xfinal, yfinal,'b')
    A11 = cos(w*t(k1) -beta.*z + pi/2);                % Onda incidente
    A22 = gama.*cos(w*t(k1) +beta.*z + pi/2 + pi/6);   % Onda refletida
    T1 = plot(z, A11,'b');                             % Plot onda incid.
    hold on
    T2 = plot(z, A22,'r');                             % Plot onda reflet.
    
    xlim([-1.5 7.5])
    ylim([(-1.5-3) (1.5+3)])
    pause(0.00000001)

    if k1<length(t)
        delete(T1)                % Deleta plot incer.
        delete(T2)                % Deleta plot reflet.
    end
    
end

pause(1)
delete(T1)             % Deleta últimos textos da tela
delete(T2)
delete(Textoo3)
delete(Textoo4)

%% Ajuste na altura dos plots (suave)

for n = 1:100
    A111 = (3*n/100) + A11;               % Ajusta altura com taxa 3n/100
    A222 = -(3*n/100)+ A22;
    
    T1 = plot(z, A111,'b');               % Plota curva ajustada
    hold on
    T2 = plot(z, A222,'r');
    
    xlim([-1.5 7.5])
    ylim([(-1.5-desloc) (1.5+desloc)])
    
    Textoo3 = text(-1,(3*n/100),'Incidente \rightarrow',...
        'Color','blue','FontSize',14);
    Textoo4 = text(6,-(3*n/100),'\leftarrow Refletida',...
        'Color','red','FontSize',14);

    pause(0.00000001)
    if n<100
        delete(T1)                  % Deleta os textos até o penúltimo
        delete(T2)
        delete(Textoo3)
        delete(Textoo4)
    end
    
end

delete(Textoo3)            % Deleta últimos textos
delete(Textoo4)

%% Plot com as duas ondas somadas

text(-1,3,'Incidente \rightarrow','Color','blue','FontSize',14)
text(6,-3,'\leftarrow Refletida','Color','red','FontSize',14)
text(6,0,'Soma','Color','black','FontSize',16)
hold on
delete(T1)
delete(T2)

for k = 1:length(t)
    plot(xcomeco, ycomeco,'b')
    hold on
    plot(xfinal, yfinal,'b')
    A1 =  desloc+cos(w*t(k) -beta.*z + pi/2);
    A2 = -desloc+gama.*cos(w*t(k) +beta.*z + pi/2 + pi/6);
    A3 = A1+A2;                 % Soma as duas ondas
    if k == 1
        ycontorno = A3;         % Segura os valores plot             
    else
        for u = 1:length(A3)
            if abs(A3(u)>ycontorno(u))
                ycontorno(u) = abs(A3(u));  % Gera vetor do contorno final
            end
        end
    end
    
    P =  plot(z, A1,'b');
    P1 = plot(z, A2,'r');
    P2 = plot(z, A3, 'k');
    xlim([-1.5 7.5])
    ylim([(-1.5-desloc) (1.5+desloc)])
 
    pause(0.00000001)
    if k ~= length(t)
        delete(P)
        delete(P1)
        delete(P2)
    end
    
end

delete(P)
delete(P1)
delete(P2)
for k = 1:length(t)
    plot(xcomeco, ycomeco,'b')
    hold on
    plot(xfinal, yfinal,'b')
    A1 =  desloc+cos(w*t(k) -beta.*z + pi/2);
    A2 = -desloc+gama.*cos(w*t(k) +beta.*z + pi/2 + pi/6);
    A3 = A1+A2;                 % Soma as duas ondas
    if k == 1
        ycontorno = A3;         % Segura os valores plot             
    else
        for u = 1:length(A3)
            if abs(A3(u)>ycontorno(u))
                ycontorno(u) = abs(A3(u));  % Gera vetor do contorno final
            end
        end
    end
    
    P =  plot(z, A1,'b');
    P1 = plot(z, A2,'r');
    P2 = plot(z, A3, 'k');
    xlim([-1.5 7.5])
    ylim([(-1.5-desloc) (1.5+desloc)])
 
    pause(0.00000001)
    if k ~= length(t)
        delete(P)
        delete(P1)
        %delete(P2)
    end
    
end
pause(1)
%figure('units','normalized','outerposition',[0 0 1 1])

%% Análise de VSWR

ycontorno_neg = (-1).*ycontorno;        % Cria contorno negativo

P =  plot(z, A1,'b');                   % Plota linha do valor máximo
hold on
P1 = plot(z, A2,'r');                   % Plota linha do valor mínimo

plot(z, ycontorno,'k')
plot(z, ycontorno_neg, 'k')
plot(xcomeco, ycomeco,'b')
plot(xfinal, yfinal,'b')
xlim([-1.5 7.5])
ylim([(-1.5-desloc) (1.5+desloc)])

%% Ajuste final das figuras

pause(2)
for q = 1:100
    pause(0.01)
    a = 2*q/100;
    xlim([-1.5 (7.5+a)])                     % Aumenta tamanho em x
    ylim([(-1.5-desloc+a) (1.5+desloc-a)])   % Reduz tamanho em y
end

pause(1)

%% Escreve valor de 1+gama e 1-gama e valor de VSWR

ymax = 1+abs((gama+zeros(1,length(ycontorno))));    % 1+|gama|
ymin = 1-abs((gama+zeros(1,length(ycontorno))));    % 1-|gama|
plot(z, ymax)
plot(z, ymin)
text(6,ymax(1),'\leftarrow 1 + |\Gamma|','FontSize',18)
text(6,ymin(1),'\leftarrow 1 - |\Gamma|','FontSize',18)
SWR = num2str(SWR);  % Passa num para string

if(length(SWR) == length('Inf'))   % Escreve infinito no formato
    if SWR == 'Inf'    
        textimm = ['$$ VSWR = \frac{1+|\Gamma|}{1-|\Gamma|} = \infty $$'];
    else
        textimm = ['$$ VSWR = \frac{1+|\Gamma|}{1-|\Gamma|} =  $$',SWR];
    end
    
else
    textimm = ['$$ VSWR = \frac{1+|\Gamma|}{1-|\Gamma|} =  $$',SWR];
end
text(6.4,-1,textimm,'FontSize',20,'Interpreter','latex')
%movieVector(q+segura4+1) = getframe;
