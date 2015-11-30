clear all

DATADIR='./DADOS_0P50/';
DATABLN='./BLN/';
BRUTOS=dir(fullfile(DATADIR,'*.RT'));
CONTORNOS=dir(fullfile(DATABLN,'*.bln'));

[Y,X]=ndgrid(-89.75:0.50:89.75,0.25:0.5:360);
XX=X(110:200,560:660);
YY=Y(110:200,560:660);
LON=reshape(XX(:,:)',1,91*101)'-360;
LAT=reshape(YY(:,:)',1,91*101)';

kk=2;
for bacia=1:size(CONTORNOS)
    N=dlmread(fullfile(DATABLN,CONTORNOS(bacia).name),',',2);
    W=inpolygon(LON(:),LAT(:),N(:,1),N(:,2));
    [ly,lx]=size(W);
    k=0;
    
    for i=1:ly
        if (W(i)==1)
            k=k+1;
            Z(1,k)=LON(i);
            Z(2,k)=LAT(i);
        
        end
            
    end
    kk=kk+2;
    celula=strcat('c',num2str(kk));
    xlswrite('CONTORNOS.xlsx',Z,'PONTOS',celula);
    celula=strcat('b',num2str(kk));
    xlswrite('CONTORNOS.xlsx',k,'PONTOS',celula);
    celula=strcat('a',num2str(kk));
    xlswrite('CONTORNOS.xlsx',{CONTORNOS(bacia).name},'PONTOS',celula);
    
    clear Z
end
