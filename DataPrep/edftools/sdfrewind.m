function [EDF]=sdfrewind(EDF);
% [EDF]=sdfseek(EDF,offset,origin)
% Currently, offset and origin are the number of (EDF) records. 
% EDF.status contains the value of the older version of [status]=gdfseek(...) 
%
% See also: FSEEK, SDFREAD, SDFWRITE, SDFCLOSE, SDFSEEK, SDFREWIND, SDFTELL, SDFEOF

%	Copyright (c) 1997-2000 by Alois Schloegl
%	a.schloegl@ieee.org	
%	Version 0.76
%	7. Juni 2000

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


EDF=sdfseek(EDF,0,'bof');
