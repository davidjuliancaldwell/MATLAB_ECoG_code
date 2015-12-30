function [P mfreqs afreqs data] = modspecgram( x, fs, varargin )
% [P MFREQS AFREQS DATA] = MODSPECGRAM( X, FS, <DEMOD>, <SUBBANDS>, <SPECOPT>, <VERBOSE> )
% 
% Computes and displays the joint-frequency modulation spectrum of a signal,
% with modulation frequency on the horizontal axis and acoustic (carrier)
% frequency on the vertical. This function is identical to MODSPECTRUM.
%
% INPUTS:
%           X - A vector time series.
%          FS - The sampling rate of X, in Hz.
%     <DEMOD> - A data structure containing demodulation options. This can
%               be a string indicating the demodulation method, or
%               alternatively a cell array specifying parameter values in
%               the fashion of the MODDECOMP... functions. The default
%               setting is {'cog', 0.1, 0.05}.
%                   {'HILB'}
%                   {'COG', <carrwin>, <carrwinhop>}
%                       carrwin - seconds.
%                       carrwinhop - seconds.
%                   {'HARM', <numharmonics>, <voicingsens>, <F0smoothness>}
%                       numharmonics - a positive integer.
%                        voicingsens - a decimal value (0 to 1).
%                       F0smoothness - a positive integer.
%                   {'HARMCOG', <carrwin>, <carrwinhop>, ...
%                               <numharmonics>, <voicingsens>, <F0smoothness>}
%  <SUBBANDS> - A vector containing subband frequency boundaries, or a
%               scalar value specifying the bandwidth for uniform-width
%               subbands. All values are in Hz. One modulator-carrier pair
%               derives from each subband. The default is SUBBANDS = 150.
%   <SPECOPT> - Spectral estimation options, in no particular order:
%                    Data taper: 'rect', 'bart', 'hamming', or 'hann'
%                                (default is rectangular).
%                   'normalize': Equalizes subband energies.
%                      'demean': Subtracts individual modulator means prior
%                                to windowing and taking the DFT.
%   <VERBOSE> - When equal to the string 'verbose', this option prints
%               internal information and plots time-frequency carrier
%               trajectories. The 'verbose' tag can appear anywhere after
%               the required parameters, as long as it is the last.
% 
% OUTPUTS:
%           P - An array containing the complex-valued modulator spectral
%               estimates. The first row is the modulator transform
%               corresponding to the lowest-frequency carrier.
%      MFREQS - A vector of modulation frequency values in correspondence
%               with the horizontal dimension of P.
%      AFREQS - A vector of acoustic frequency values in correspondence
%               with the vertical dimension of P.
%        DATA - A data structure containing decomposition information,
%               used in some other Modulation Toolbox functions.
%
% See also modspectrum, modspecgramgui, modfilter, moddecomp, modsynth,
%          modop_shell, moddecomphilb, moddecompcog, moddecompharm,
%          moddecompharmcog

% Revision history:
%   P. Clark - simplified the user interface and integrated with high-level
%              modulation operation functions, 04-17-10
%   P. Clark - prepared for beta testing, 04-14-09

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

% REFERENCES
% [1] S. Greenberg and B.E.D. Kingsbury, "The modulation spectrogram: in
%     pursuit of an invariant representation of speech," IEEE ICASSP 1997.
% [2] M. Vinton and L.E. Atlas, "Scalable and progressive audio codec," 
%	  IEEE ICASSP 2001.
% [3] S.M. Schimmel, L.E. Atlas and K. Nie, "Feasibility of single channel
%     speaker separation based on modulation frequency analysis," IEEE
%     ICASSP 2007.
% -------------------------------------------------------------------------


% NOTE: This function only passes its input argument to MODSPECTRUM. As of
% version 2.1, we refer to the joint-frequency representation as the
% 'modulation spectrum' instead of the 'modulation spectrogram.' The
% display in MODSPECGRAMGUI, however, is a true 'modulation spectrogram' in
% the classical sense because the modulation spectrum varies as a function
% of a sliding temporal window. A good discussion of naming conventions
% appears in:
%   S. Schimmel, "Theory of Modulation Frequency Analysis and Modulation
%   Filtering, with Applications to Hearing Devices," Ph.D. dissertation,
%   Univerity of Washington, 2007, Chapter 3 Section 2.


numinputs = nargin; 

% Initial input parsing
if numinputs < 2
    error( 'MODSPECGRAM requires at least two input parameters.' )
end

% Default values for all MODSPECTRUM input arguments
demod = [];
subbands = [];
specopt = [];
verbose = '';

if ~isempty( varargin ) && isa( varargin{end}, 'char' ) && strcmpi( varargin{end}, 'verbose' )
    verbose = 'verbose';
    numinputs = numinputs - 1;
end

% Fill in user-specified values
if numinputs > 2
    demod = varargin{1};
end
if numinputs > 3
    subbands = varargin{2};
end
if numinputs > 4
    specopt = [varargin{3:end}];
end
 
% Call the MODSPECTRUM function
if nargout == 0
    modspectrum( x, fs, demod, subbands, specopt, verbose );
else
    [P mfreqs afreqs data] = modspectrum( x, fs, demod, subbands, specopt, verbose );
end

