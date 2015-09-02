function [EDF]=sdftell(EDF)
% EDF=sdftell(EDF_Struct)
% returns the location of the EDF_file position indicator in the specified file.  
% Position is indicated in Blocks from the beginning of the file.  If -1 is returned, 
% it indicates that the query was unsuccessful; 
% EDF_Struct is a struct obtained by sdfopen.
%
% EDF.FILE.POS contains the position of the EDF-Identifier in Blocks


%	Version 0.85
%	15 Jun 2002
%	Copyright (c) 1997-2002 by Alois Schloegl
%	a.schloegl@ieee.org	


POS = ftell(EDF.FILE.FID);
if POS<0
        [EDF.ERROR,EDF.ErrNo] = ferror(EDF.FILE.FID);
        return; 
end;
EDF.FILE.POS = (POS-EDF.HeadLen)/EDF.AS.bpb;
EDF.ERROR=[];
EDF.ErrNo=0;

if (EDF.AS.startrec+EDF.AS.numrec)~=EDF.FILE.POS
        fprintf(2,'Warning SDFTELL: File postion error in EDF/GDF/SDF-toolbox.\n')
        EDF.AS.startrec = EDF.FILE.POS;
end;        

