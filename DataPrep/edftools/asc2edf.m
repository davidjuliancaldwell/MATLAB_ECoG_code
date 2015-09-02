function EDF=edf2edf100(FN)
% ASC2EDF loads data in ASCII format and tries to store it in EDF
% EDF=asc2edf(FILENAME)
%
% See also: SDFREAD, SDFWRITE, SDFCLOSE
%
% This software is under developement. Please let me know about any strange behavior. 
%
% Current limitations: 
%   -  one channel only (more channel do not produce valid EDF files)
%   -  imputs checks are not very strict. Please make sure that you provid valid header info.
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




return; 



if nargin<1,
        [FN,pfad]=uigetfile('*.*','Open biosignal data file');
else
        pfad='';
end;

[pfad,filename,ext]=fileparts([pfad,FN]);

if strcmpi(ext,'.txt') | strcmpi(ext,'.asc'),
        D = load(FN,'-ascii');
        [EDF,D]=scale2edf(D);
	[LEN,EDF.NS]= size(D);        
        EDF.VERSION = '0       ';
        EDF.PID = ' ';
        EDF.RID = ' ';
        EDF.T0  = [1985 1 1 0 0 0];
        EDF.HeadLen = 256*(EDF.NS+1);
        tmp = ' ';
        EDF.reserved1 = tmp(ones(1,44));
        EDF.NRec=-1;
        EDF.Dur = 1;
        EDF.SampleRate = 1;
elseif strcmpi(ext,'.edf'),
        EDF=sdfopen(FN,'r',0);
elseif strcmpi(ext,'.rec'),
        EDF=sdfopen(FN,'r',0);
else
	fprintf(2,'Error %s: type of file not identified\n',upper(mfilename),FN);        
end



%%%%%%%%%%%%% HEADER 1111111111111111 %%%%%%%%%%%%%%


Prompt={'Version:', ...
        'Patient Identification:', ...
        'Record Identification:', ...
        'Date [dd.mm.yy]:', ...
        'Time [hh:mm:ss]:', ...
        'Headerlength [byte]:', ...
        'reserved (1):', ...
        'number of records:', ...
        'sampling rate [Hz]:', ...
        'duration of 1 block [s]:', ...
        'number of channels:', ...
};

dlgTitle='ASC2EDF: Edit header information  (c) 1997-2001, A.Schlögl';

DataFormat={'EDF','GDF','MAT','BKR'};
DefAns = {DataFormat,EDF.PID,EDF.RID,...
                sprintf('%02i.%02i.%02i',mod(EDF.T0(3:-1:1),100)), ...
                sprintf('%02i.%02i.%02i',round(EDF.T0(4:6))), ...
                int2str(EDF.HeadLen),...
                EDF.reserved1,int2str(EDF.NRec),int2str(EDF.SampleRate),sprintf('%i',EDF.Dur), int2str(EDF.NS), ...
        };

NumLines=[1 8; 1 80; 1 80; 1 8; 1 8; 1 6; 1 44; 1 6; 1 6; 1 6; 1 6];

% PromptDef(1,:) = 0 for edit box
%                  N for Popup menu(N is  the initial selection)    
%                 -N for ListBox(ListInit{N} is the initial selection)    
PromptDef(1,:)=  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
% PromptDef(2,:) = 1 for initially disabled Quests
%      for ListBox:	1  initially disabled ListBox
%                  	2  Single item selection ListBox
%                    3  Single item selection + initially disabled ListBox
PromptDef(2,:)=  [1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0];


[Answer, figfmen1, AnsFlg1] = inpdlg(Prompt,dlgTitle, NumLines,DefAns,PromptDef);

if strcmpi(Answer{1},'EDF'),
        EDF.VERSION='0       ';
end;

EDF.PID=Answer{2};
EDF.RID=Answer{3};
EDF.SampleRate=str2num(Answer{9});
EDF.Dur=str2num(Answer{10});
EDF.FILE.stderr=2;
EDF.NS=str2num(Answer{11});

EDF.SPR=EDF.Dur*EDF.SampleRate;

%%%%%%%%%%%%% HEADER 2222222222 %%%%%%%%%%%%%%

EDF.Label=repmat(' ',EDF.NS,16);
EDF.Transducer=repmat(' ',EDF.NS,80);
EDF.PhysDim=repmat(' ',EDF.NS,8);
EDF.PreFilt=repmat(' ',EDF.NS,80);
%EDF.Label=repmat(' ',EDF.NS,16);

%EDF.PhysMin=zeros(EDF.NS,1);
%EDF.PhysMax=ones(EDF.NS,1);

%EDF.DigMin=zeros(EDF.NS,1);
%EDF.DigMax=ones(EDF.NS,1);

        
Prompt={'Label :' ...
        'Transducer type: ' ...
        'Physical Dimension :' ...
        'Pre-Filtering :' ...
};

dlgTitle='ASC2EDF: Edit header information  (c) 1997-2001, A.Schlögl';

DefAns = { EDF.Label, EDF.Transducer, EDF.PhysDim, EDF.PreFilt ...
        };

NumLines=[EDF.NS, 16; EDF.NS, 80; EDF.NS, 8; EDF.NS, 80; ];


clear PromptDef
% PromptDef(1,:) = 0 for edit box
%                  N for Popup menu(N is  the initial selection)    
%                 -N for ListBox(ListInit{N} is the initial selection)    
PromptDef(1,:)=  [0, 0, 0, 0];
% PromptDef(2,:) = 1 for initially disabled Quests
%      for ListBox:	1  initially disabled ListBox
%                  	2  Single item selection ListBox
%                    3  Single item selection + initially disabled ListBox
PromptDef(2,:)=  [0, 0, 0, 0];


[Answer, figfmen1, AnsFlg1] = inpdlg(Prompt,dlgTitle, NumLines,DefAns,PromptDef);

EDF.Label=Answer{1};
EDF.Transducer=Answer{2};
EDF.PhysDim=Answer{3};
EDF.PreFilt=Answer{4};

EDF.NRec = size(D,1)/EDF.SampleRate/EDF.Dur;

EDF.FileName=[pfad,filesep,filename,'.edf'];
EDF.AS.MAXSPR=max(EDF.SPR);
%EDF.SPR=EDF.AS.MAXSPR(ones(1,EDF.NS))*EDF.NS;

EDF=sdfopen(EDF,'w');
[count,EDF]=sdfwrite(EDF,D);
EDF=sdfclose(EDF);


