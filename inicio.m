%------------------------------------------------------------------------
% CALCULA CHUVA MEDIA DIARIA E ACUMULADA MENSAL DE CHUVA TIPO GRADE
% VERSAO 1.0 PARA DADOS DO CPC 0.5 GRAUS 
% BY REGINALDO VENTURA DE SA (reginaldo.venturadesa@gmail.com)
% -----------------------------------------------------------------------
% baixa os dados, faz o recorte para o Brasil e grava a chuva de todo o
% perido em um arquivo chamado CHUVA_MEIOGRAU.dat 
% 
clear all
%
% define as datas de controle de tudo que o script faz
%
DATA_INICIAL=datenum(2015,10,1);
DATA_FINAL=datenum(2015,11,30);        
DATA_DOWNLOAD_INICIAL=datenum(2015,10,1);
% 
% verifica se tem arquivo de CONTORNOS.xlsx
% se não tem, cria chamando contornos.m 
%
if (exist('CONTORNOS.xlsx')==0) 
    contornos
end
%
% diretorio dos dados baixados de chuva
% e guarda em BRUTOS
%
DATADIR='./DADOS_0P50/';
BRUTOS=dir(fullfile(DATADIR,'*.RT'));
TAMX=102;
TAMY=91;
NUMREG=size(BRUTOS)+1; 

%
% 
% baixa os dados de chuva  
%
site='ftp://ftp.cpc.ncep.noaa.gov/precip/CPC_UNI_PRCP/GAUGE_GLB/RT/';
cd(DATADIR);
for i=DATA_DOWNLOAD_INICIAL:DATA_FINAL
    [ano,mes,dia]=datevec(i);
    dirsite=sprintf('%04d/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.%04d%02d%02d.RT',ano,ano,mes,dia);
    file=sprintf('PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.%04d%02d%02d.RT',ano,mes,dia);
    link=strcat(site,dirsite);
   
    if (exist(file)==0)
        file;
        [f,g]=urlwrite(link,file);
    else
        disp(strcat(file,'ja existe:'));
        file;
    end              
end
cd('../');               


%
% processa
%

%
%
% ABRE ARQUIVO CONTENDO BACIAS HIDROGRAFICAS CADASTRADAS
%   
disp(strcat(datestr(now),' ABRINDO ARQUIVOS DE BACIAS'));
[D,P]=xlsread('CONTORNOS.xlsx','PONTOS');
[anoref,~,~]=datevec(DATA_INICIAL);
[anofim,~,~]=datevec(DATA_FINAL);
[b,~]=size(P);
NUM_BACIAS=ceil((b+1)/2);

%
%  celulas etiquetas para o excell
%
LABELDATA=nan((DATA_INICIAL-DATA_FINAL)+1);
LABELDATAMES=nan((anoref-anofim)+1,12);
%
% inicio das variaveis
%
MEDIA_DIARIA=zeros(NUM_BACIAS,ceil(DATA_FINAL-DATA_INICIAL)+1);
SOMA_MENSAL=zeros(NUM_BACIAS,(anofim-anoref)+1,12);
CONTA_MENSAL=zeros(NUM_BACIAS,(anofim-anoref)+1,12);
MEDIA_MENSAL=zeros(NUM_BACIAS,(anofim-anoref)+1,12);

%
% geometria da grade chuva ncep
%
[Y,X]=ndgrid(-89.75:0.50:89.75,0.25:0.5:360);
LON=X(110:200,560:660)-360;
LAT=Y(110:200,560:660);
%
% processa
%
for loop=DATA_INICIAL:DATA_FINAL
    %
    % varre a data inicial para final 
    % e pega os arquivos de chuva dentro dessa data
    % 
    indice=loop-(DATA_INICIAL-1);
    [ano,mes,dia]=datevec(loop);
    dirsite=sprintf('%04d/PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.%04d%02d%02d.RT',ano,ano,mes,dia);
    arquivo=sprintf('PRCP_CU_GAUGE_V1.0GLB_0.50deg.lnx.%04d%02d%02d.RT',ano,mes,dia);
    id=fopen(fullfile(DATADIR,arquivo),'rb');
    M=fread(id,720*360,'single');
    fclose(id);
    if (length(M) == 720*360)
    for i=1:720*360 
        if (M(i,1) < 0 ) 
            M(i,1)=NaN;
        end
    end
    else
        disp(strcat('Arquivo com problema:',arquivo));
        return
    end
    
    %
    % manipula matriz de dados lida na matriz de chuva 
    %
    Z=reshape(M,[720,360]); 
    Z=Z'/10;
        %
    % recorte para uma matriz que só tenha o Brasil 
    % use o grads  para epgar as informacoes do recorte
    %
    %from grads
    %X is varying   Lon = 279.75 to 329.75   X = 560 to 660
    %Y is varying   Lat = -35.25 to 9.75     Y = 110 to 200
    DADOS(:,:)=Z(110:200,560:660);
    LABELDATA(indice)=loop;
    LABELDATAMES((ano-anoref)+1,mes)=loop;
    b=1;
    %
    % calculo diario e mensal da chuva. 
    % 
    for bacia=1:NUM_BACIAS
             SOMA=0;
             for i=1:D(b,1)
                  [l,c]=find((LON == D(b,i+1)) & (LAT == D(b+1,i+1)));
                  VALOR_CHUVA=DADOS(l,c);
                  if (VALOR_CHUVA >=0 )
                    SOMA=SOMA+VALOR_CHUVA;
                  end
             end
             
             MEDIA_DIARIA(bacia,indice)=SOMA/D(b,1);
             SOMA_MENSAL(bacia,(ano-anoref)+1,mes)=SOMA_MENSAL(bacia,(ano-anoref)+1,mes)+SOMA/D(b,1);
             CONTA_MENSAL(bacia,(ano-anoref)+1,mes)=CONTA_MENSAL(bacia,(ano-anoref)+1,mes)+1;
             b=b+2;
    end
  
%    

end




%
%
% gravar planilha excell
%
%
% %
% % cria cabeçahos, coluna de datas etc..
% % para quando for gravar no excell 
disp(strcat(datestr(now),' GRAVANDO DADOS NO EXCEL '));
celula={'b2','c2','d2','e2','f2','g2','h2','i2','j2','k2','l2','m2','n2' ...
        'o2','p2','q2','r2','s2','t2','u2','v2','w2','x2','y2','z2','aa2' ...
        'ab2','ac2','ad2','ae2','af2','ag2','ah2','ai2','aj2','ak2','al2','am2','an2' ...
        'ao2','ap2','aq2','ar2','as2','at2','au2','av2','aw2','ax2','ay2','az2' };
xlswrite('RESULTADO.xlsx',unique(P)','MEDIA','a1');
% xlswrite('RESULTADO.xlsx',unique(P)','MEDIAMES','a1');
xlswrite('RESULTADO.xlsx',unique(P)','SOMAMES','a1');
        
for i=1:size(MEDIA_DIARIA)
    xlswrite('RESULTADO.xlsx',MEDIA_DIARIA(i,:)','MEDIA',char(celula(i)));
end

a=datestr(LABELDATA,'dd/mm/yyyy');
b=cellstr(a);
xlswrite('RESULTADO.xlsx',b,'MEDIA','a2');



for bacia=1:NUM_BACIAS
    k=0;
    clear e es
    as=datestr(LABELDATAMES','mm/yyyy');
    bs=cellstr(as);
    a=squeeze(SOMA_MENSAL(bacia,:,:));
    b=reshape(a',1,[]);
    c=squeeze(CONTA_MENSAL(bacia,:,:));
    d=reshape(c',1,[]);
    [zy,zx]=size(b);
    for i=1:zx
        if(d(1,i)>0)
           k=k+1;
           e(k,1)=b(1,i);
           es(k,1)=bs(i);
        end
    end
    xlswrite('RESULTADO.xlsx',e,'SOMAMES',char(celula(bacia)));
    xlswrite('RESULTADO.xlsx',es,'SOMAMES','a2');
end




    
 


