function climdb(range)
% CLIMDB( RANGE )
%
% Sets the current axis color limits in dB units. Since colorbars are not
% automatically updated, it is best to call this function before displaying
% a colorbar.
%
% INPUTS:
%   RANGE - If a scalar, sets the color limits to [MAX-RANGE MAX]. If a
%           two-element vector, sets the color range directly.

% Revision history:
%   S. Schimmel - wrote it some time ago.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                    %
%    Modulation Toolbox version 2.1                                  %
%    Copyright (c) ISDL, University of Washington, 2010.             %
%                                                                    %
%    This software is distributed for evaluation purposes only,      %
%    and may not be used for any commercial activity. It remains     %
%    the property of ISDL, University of Washington.                 %
%    Modification of this software for personal use is allowed.      %
%    Redistribution of this software is prohibited.                  %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% determine clim if not fully specified
switch numel(range),
case 1,
    clim = get(gca,'clim');
    clim(1) = clim(2)-range;
case 2,
    clim = range;
otherwise,
    error('RANGE must be a scalar or a 2 element vector');
end;

% set new color limits on current axis 
set(gca,'clim',clim);
