function [EDF]=sdfclose(EDF)
% [EDF]=sdfclose(EDF)
% Closes an EDF-File

%	Version 0.78
%	18 June 2000
%	Copyright (C) 1997-2000 by Alois Schloegl
%	a.schloegl@ieee.org


if ~(EDF.FILE.FID<0)
    if EDF.FILE.OPEN==2
        status   = fseek(EDF.FILE.FID, 0, 'eof'); % go to end-of-file
        endpos   = ftell(EDF.FILE.FID);           % get file length
        tmp = floor((endpos - EDF.HeadLen) / EDF.AS.bpb);  % calculate number of records
        if ~isnan(tmp)
            EDF.NRec=tmp;
        end;
        
        %fclose(EDF.FILE.FID);
        EDF=sdfopen(EDF,'w+');                    % update header information
    end;
    
    if EDF.FILE.OPEN
        EDF.FILE.OPEN=0;
        EDF.ErrNo=fclose(EDF.FILE.FID);
    end;
    
end;