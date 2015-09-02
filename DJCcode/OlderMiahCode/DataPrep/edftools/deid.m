function [EDF]=deid(FN1)

if nargin<2,
	FN1='*.*';
end;

if ~exist(FN1,'file'),
        [FN1,pfad]=uigetfile(FN1,'Open biosignal data file');
else
        pfad='';
end;

[pfad,FN1]
EDF = sdfopen([pfad,FN1],'r',0,'UCAL');
EDF = sdferror(EDF);
if any(EDF.ErrNo),
	fprintf(2,'Error: file %s can not be opened\n',FN1);
	return;
end;


EDF.PID = '';
% EDF.AS,MAXSPR=max(EDF.SPR);
% EDF.SIE.RAW = 1;
% 
% EDF=sdfopen(EDF,'w+');
%  % open output file   
% EDF.SIE.RAW = 1;  % write mode  

    
EDF=sdfclose(EDF);



return; 

