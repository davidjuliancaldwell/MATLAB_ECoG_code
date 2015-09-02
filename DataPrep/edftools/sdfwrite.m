function [count,EDF]=sdfwrite(EDF,data)
% count=sdfwrite(EDF_Struct,data)
% Appends data to an EDF File (European Data Format for Biosignals) 
% one block per column (EDF raw form)

%	Version 0.80
%	18 Sep 2000
%	Copyright (c) 1997-2000 by Alois Schloegl
%	a.schloegl@ieee.org	

data(data>2^15-1)=  2^15-1;
data(data<-2^15) = -2^15;

if EDF.SIE.RAW,
        if isnan(EDF.AS.spb),  %first call of sdfwrite
                [EDF.AS.spb,EDF.NRec]=size(data);
                EDF.AS.bpb = 2*EDF.AS.spb; %only for EDF
        end;
        if sum(EDF.SPR)~=size(data,1)
                fprintf(2,'Warning EDFWRITE: datasize must fit to the Headerinfo %i %i %i\n',EDF.AS.spb,size(data));
                fprintf(2,'Define the Headerinformation correctly.\n',EDF.AS.spb,size(data));
        end;
        count = fwrite(EDF.FILE.FID,data,'integer*2');
else
        [nr,EDF.NS] = size(data);
        if isnan(EDF.AS.spb),  %first call of sdfwrite
                EDF.AS.MAXSPR = floor(61440/2/EDF.NS);
                EDF.SPR = ones(EDF.NS,1)*EDF.AS.MAXSPR;
                EDF.AS.spb = sum(EDF.SPR);
                EDF.AS.bpb = 2*EDF.AS.spb; %only for EDF
        end;        
        for k=0:floor(nr/EDF.AS.MAXSPR)-1;
                count = fwrite(EDF.FILE.FID,data(k*EDF.SPR+(1:EDF.AS.MAXSPR),:),'integer*2');
        end;
        tmp= rem(nr,EDF.AS.MAXSPR);
        if tmp,
                fprintf(2,'Warning SDFWRITE: last block is too short\n');
        end;
end;

EDF.FILE.POS = EDF.FILE.POS+count/EDF.AS.bpb;
                        
