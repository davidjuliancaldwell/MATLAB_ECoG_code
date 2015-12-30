function [] = modop_shell( x, fs, varargin )
% [...] = MODOP_SHELL( X, FS, ..., <DEMOD>, <SUBBANDS>, ... , <VERBOSE> )
% 
% This is a shell function that provides an Application Programming
% Interface (API) for designing your own functions for modulation analysis,
% modification, and synthesis. MODOP_SHELL takes care of parameter handling
% and encompasses function calls to MODDECOMP and MODSYNTH.
%
% Examples of how to use MODOP_SHELL are the MODSPECTRUM and MODFILTER
% functions, each of which act as an extension of the basic template
% defined by MODOP_SHELL.
%
% See also moddecomp, modsynth, modspectrum, modfilter,
%          moddecomphilb, moddecompcog, moddecompharm, moddecompharmcog,

% Revision history:
%   P. Clark - integrated with version 2.1, 09-01-10
%   A. Greenhall - initial idea and prototype code, 10-xx-09

% Contact:
%   Pascal Clark (UW EE)    : clarkcp @ u.washington.edu
%   Prof. Les Atlas (UW EE) :   atlas @ u.washington.edu
%   
%   http://modulation.ee.washington.edu/
%   http://isdl.ee.washington.edu/projects/modulationtoolbox/

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


% Initial input parsing
if nargin < 2
    error( 'MODOP_SHELL requires at least two input parameters.' )
end


% --- Essential Code ------------------------------------------------------
% These two function calls are the essence of MODOP_SHELL: parameter
% handling and formatting of the modulation decomposition. Note that the
% downsampling factor is left at your discretion (here it is set to 1).
[decompparams verbose opinputs] = parsedecompinputs( varargin );
[M C data] = moddecomp( x, fs, decompparams{1}, decompparams{2}, 1, verbose );
    
    % Notes on the above:
    %
    % MODOP_SHELL parses input parameters with the following convention:
    %   ( X, FS, [PARAM1, PARAM2,...], <DEMOD>, <SUBBANDS>, <OPARAM1, OPARAM2,...>, <VERBOSE> )
    %
    % X, FS, PARAM1, PARAM2,... are all required inputs, where PARAM1,
    % PARAM2,... are function-specific.
    % 
    % <DEMOD> and <SUBBANDS> are optional parameters that pertain to
    % MODDECOMP. These are parsed from the VARARGIN object and placed into
    % the DECOMPPARAMS object.
    %
    % <OPARAM1, OPARAM2,...> are also optional parameters, but are
    % function-specific. These paramters are parsed from the VARARGIN
    % object and placed into the OPINPUTS object.
    % 
    % <VERBOSE> is a tag that operates in the same way as for MODDECOMP.
    % The 'verbose' string can be included anywhere after the required
    % inputs, but it must be the last user-supplied (i.e., non-default)
    % input.


% --- Optional Code -------------------------------------------------------
% Add necessary toolbox subfolders when MODOP is called from within the
% toolbox directory. MODDECOMP already does this for the 'demod' and
% 'filterbank' subfolders.
checksubfolders( 'filter' );


% --- Insert Custom Code Here ---------------------------------------------
% This space is for you to analyze and/or modify the modulation components
% obtained above. Some things that will be useful:
% 1. OPINPUTS is a cell array containing the user inputs that come after
%    the DEMODPARAMS and SUBBANDS elements, and before the 'verbose' command.
% 2. The M and C arrays have the same dimensions, containing row-wise
%    modulator and carrier signals.
% 3. DATA is a struct containing fields FILTBANKPARAMS, DEMODPARAMS, FS
%    (the original signal sampling rate) and MODFS (the modulator sampling
%    rate, possibly lower than FS), among other pieces of information.
% 4. Refer to MODSPECGRAM and MODFILTER for examples.


% --- Optional Code -------------------------------------------------------
% Function call to MODSYNTH, which combines modulators with carriers to 
% synthesize a new audio signal
y = modsynth( M, C, data );

end % End modop_shell


% =========================================================================
% Define your operation-specific sub-functions below.
% =========================================================================




% =========================================================================
% The following are utility functions from MODOP_SHELL that are probably
% best left unaltered.
% =========================================================================

% -------------------------------------------------------------------------
function [decompparams vflag remaining] = parsedecompinputs( inputs )
% This function extracts the DEMOD and SUBBANDS parameters from a
% variable-length cell array of optional input arguments, and places them
% into the DECOMPPARAMS list. Any remaining optional parameters are
% returned in the REMAINING output list.
% Note that this sub-function does not extract a DFACTOR parameter for the
% DECOMPPARAMS list! From the standpoint of MODOP_SHELL, modulator
% downsampling is considered a 'function-specific' argument.
% Also, the 'verbose' command can follow any argument as long as it is at
% the end.

    % Check the 'verbose' parameter (always at the end of the input list,
    % if present at all)
    % -------------------------------------------------------------------
    if ~isempty( inputs ) && isa( inputs{end}, 'char' ) && strcmpi( inputs{end}, 'verbose' )
        vflag = 'verbose';
        inputs = indexcellarray( inputs, 1:length(inputs)-1 );
    else
        vflag = '';
    end

    % Any missing or empty arguments will be handled internally by
    % moddecomp() and replaced by default values.
    numinputs = length( inputs );
    
    if numinputs == 0 
        decompparams = {[], []};
    elseif numinputs == 1
        decompparams = {inputs{1}, []};
    else
        decompparams = {inputs{1}, inputs{2}};
    end
    
    % Return the remaining optional input arguments
    remaining = indexcellarray( inputs, 3:length(inputs) );
    
end % End parsedecompinputs


%--------------------------------------------------------------------------
function checksubfolders( varargin )
% Automatically adds the toolbox subfolders needed for the parent function.

    % Get the toolbox directory
    toolboxDir = which( 'modop_shell' );
    toolboxDir = toolboxDir( 1:end-13 );

    % Get the toolbox directory listing
    d = dir( toolboxDir );

    % Get Matlab's search path
    p = path;
    
    check = ones( 1, length( varargin ) );
    warnStr = [];

    % Look for the subfolder names in the presumed toolbox directory, and
    % add them to Matlab's search path if they are present. This allows
    % modspecgram to be run easily without manually adding paths to the
    % required subfolders.
    for k = 1:length( varargin )

        i = 1;

        % Check to see if the subfolder is already a part of Matlab's search path
        if ~isempty( strfind( p, [toolboxDir '\' varargin{ k }] ) ) || ...
           ~isempty( strfind( p, [toolboxDir '/' varargin{ k }] ) )
            check( k ) = 0;
            continue
        end

        % Search the presumed toolbox directory for the necessary subfolder
        while i <= length( d ) && check( k ) == 1

            if strcmp( d( i ).name, varargin{ k } )
                addpath( [toolboxDir '/' varargin{ k }] );
                check( k ) = 0;
            end

            i = i + 1;
        end

        % Check to see if the subfolder is still absent
        if check( k ) == 1
            warnStr = [warnStr, varargin{ k }, ' '];
        end
    end

    % If any of the folder names were not found, then alert the user to the
    % problem
    if sum( check ) > 0
        msgid = 'MODOP:SUBFOLDERS';
        msg   = ['Could not find the required subfolders(s): '...
                  warnStr '. '...
                  'Refer to filepath.m within the Modulation Toolbox for help.'];

        warning( msgid, msg );
    end

end % End checksubfolders


%--------------------------------------------------------------------------
function c2 = indexcellarray( c1, indx )
% Returns a cell array containing the elements of c1 located at the index
% numbers in indx. This function ignores out-of-bound errors, so for
% example, c1 = {1, 2, 3} and indx = 4 will return c2 = {} since there is
% no fourth element.

    c2 = {};
    
    for i = 1:length( indx )
        try c2{ i } = c1{ indx( i ) }; catch end
    end

end % End indexcellarray

