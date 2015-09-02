function [EDF,EDF2]=edf2edf100(TSR,FN1,FN2)
% EDF2EDF loads EDF data format and tries to store it in EDF with a different sampling rate 
% [inEDF,outEDF]=edf2edf(target_sampling_rate,inFile,outFile)
%
% See also: SDFREAD, SDFWRITE, SDFCLOSE
%
% This software is under developement. Especially, the user interface might need some improvement
%  Please let me know any strange behavior. 
%
% Current limitations: 
%   -  imputs checks are not very strict. Please make sure that you provide valid header info.
%
%       Version 0.82,   20 Sep 2001
% 	(c) 1997-2001 Alois Schloegl 
%	<a.schloegl@ieee.org>  


% References: 
% [1] Bob Kemp, Alpo Värri, Agostinho C. Rosa, Kim D. Nielsen and John Gade
%     A simple format for exchange of digitized polygraphic recordings.
%     Electroencephalography and Clinical Neurophysiology, 82 (1992) 391-393.
% see also: http://www.medfac.leidenuniv.nl/neurology/knf/kemp/edf/edf_spec.htm
%
% [2] Alois Schlögl, Oliver Filz, Herbert Ramoser, Gert Pfurtscheller
%     GDF - A GENERAL DATAFORMAT FOR BIOSIGNALS
%     Technical Report, Department for Medical Informatics, Universtity of Technology, Graz (1999)
% see also: http://www-dpmi.tu-graz.ac.at/~schloegl/matlab/eeg/gdf4/tr_gdf.ps
%
% [3] The SIESTA recording protocol. 
% see http://www.ai.univie.ac.at/siesta/protocol.html
% and  http://www.ai.univie.ac.at/siesta/protocol.rtf 
%
% [4] Alois Schlögl
%     The electroencephalogram and the adaptive autoregressive model: theory and applications. 
%     (ISBN 3-8265-7640-3) Shaker Verlag, Aachen, Germany.
% see also: "http://www.shaker.de/Online-Gesamtkatalog/Details.idc?ISBN=3-8265-7640-3"



% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.



if nargin<1
    TSR=200;  % default target sampling rate
end;


if nargin<2,
	FN1='*.*';
end;

if ~exist(FN1,'file'),
        [FN1,pfad]=uigetfile(FN1,'Open biosignal data file');
else
        pfad='';
end;

[pfad,FN1]
EDF = sdfopen([pfad,FN1],'r',0,'UCAL',TSR);
EDF = sdferror(EDF);
if any(EDF.ErrNo),
	fprintf(2,'Error EDF2EDF: file %s can not be opened\n',FN1);
	return;
end;
	
if nargin<3,
        [FN2,pfad] = uiputfile([EDF.FILE.Name,int2str(TSR),EDF.FILE.Ext],'Output file name ');
else
        pfad='';
end;

[pfad,filename,ext] = fileparts([pfad,FN2]);



EDF2=EDF;
EDF2.FileName=FN2; 
%[EDF.FILE.Name,int2str(TSR),'.',EDF.FILE.Ext];


EDF2.SampleRate(:)=TSR;
EDF2.SPR(:)=EDF.Dur*TSR;
EDF2.AS,MAXSPR=max(EDF2.SPR);
EDF2.SIE.RAW = 1;
%EDF2.reserved1=['resampled to ', int2str(TSR),' Hz']

EDF2=sdfopen(EDF2,'w'); % open output file   
EDF2.SIE.RAW = 1;  % write mode  

for k=1:EDF.NRec,
    [s,EDF]=sdfread(EDF,EDF.Dur);
    
    %plot(s(:,2)),drawnow,pause    
    
    [count,EDF2]=sdfwrite(EDF2,s(:));
    
end;
    
EDF=sdfclose(EDF);
EDF2=sdfclose(EDF2);



return; 

