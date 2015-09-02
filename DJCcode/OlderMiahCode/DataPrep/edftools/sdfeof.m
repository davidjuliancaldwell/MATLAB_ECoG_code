function [status]=sdfeof(EDF)
% sdfeof(EDF)
% returns 1 if End-of-EDF-File is reached
% returns 0 otherwise

%	Copyright (c) 1997-99 by Alois Schloegl
%	a.schloegl@ieee.org	
%	Version 0.60
%	16. Aug. 1999


% status=feof(EDF.FILE.FID);  % does not work properly
%if EDF.FILE.POS~=EDF.AS.startrec+EDF.AS.numrec;
        
status=(EDF.FILE.POS>=EDF.NRec);


