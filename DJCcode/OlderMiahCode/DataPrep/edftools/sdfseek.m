function [EDF]=sdfseek(EDF,offset,origin)
% [EDF]=sdfseek(EDF,offset,origin)
% Currently, offset and origin are the number of (EDF) records. 
% EDF.status contains the value of the older version of [status]=gdfseek(...) 
%
% See also: FSEEK, SDFREAD, SDFWRITE, SDFCLOSE, SDFREWIND, GSFTELL, SDFEOF

%	Copyright (c) 1997-2002 by Alois Schloegl
%	a.schloegl@ieee.org	
%	Version 0.85
%	15. Juni 2002

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the  License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


if strcmp(origin,'bof')
	origin=-1;        
elseif strcmp(origin,'cof')
	origin=0;        
elseif strcmp(origin,'eof')
	origin=1;        
end;

if origin==-1 
	EDF.FILE.POS = offset;
        OFFSET = EDF.AS.bpb*offset;
        status = fseek(EDF.FILE.FID,EDF.HeadLen+OFFSET,-1);
elseif origin==0 
	EDF.FILE.POS = EDF.FILE.POS + offset;
        OFFSET = EDF.AS.bpb*offset;
        status = fseek(EDF.FILE.FID,OFFSET,0);
elseif origin==1 
	EDF.FILE.POS = EDF.NRec+offset;
        OFFSET = EDF.AS.bpb*offset;
        status = fseek(EDF.FILE.FID,OFFSET,1);
else
        fprintf(2,'error SDFSEEK: 3rd argument "%s" invalid\n',origin);
        return;
end;


EDF.AS.startrec=EDF.FILE.POS;
EDF.AS.numrec = 0;
EDF = sdftell(EDF); % not really needed, only for double check of algorithms

% Initialization of Bufferblock for random access (without EDF-blocklimits) of data 
if ~EDF.SIE.RAW & EDF.SIE.TimeUnits_Seconds
        EDF.Block.number=[0 0 0 0]; %Actual Blocknumber, start and end time of loaded block, diff(EDF.Block.number(1:2))==0 denotes no block is loaded;
        % EDF.Blcok.number(3:4) indicate start and end of the returned data, [units]=samples.
        EDF.Block.data=[];
        EDF.Block.dataOFCHK=[];
end;


if 1; %isfield(EDF,'AFIR');
        if EDF.SIE.AFIR
                EDF.AFIR.w = zeros(EDF.AFIR.nC,max(EDF.AFIR.nord));
                EDF.AFIR.x = zeros(1,EDF.AFIR.nord);
                EDF.AFIR.d = zeros(EDF.AFIR.delay,EDF.AFIR.nC);
                fprintf(2,'WARNING SDFSEEK: Repositioning deletes AFIR-filter status\n');
        end;
end;
if 1; %isfield(EDF,'Filter');
        if EDF.SIE.FILT
                [tmp,EDF.Filter.Z]=filter(EDF.Filter.B,EDF.Filter.A,zeros(length(EDF.Filter.B+1),length(EDF.SIE.ChanSelect)));
                EDF.FilterOVG.Z=EDF.Filter.Z;
                fprintf(2,'WARNING SDFSEEK: Repositioning deletes Filter status of Notch\n');
        end;
end;

if 1; %isfield(EDF,'TECG')
        if EDF.SIE.TECG
                
                fprintf(2,'WARNING SDFSEEK: Repositioning deletes TECG filter status\n');
        end;
end;
EDF.FILE.status=status;
