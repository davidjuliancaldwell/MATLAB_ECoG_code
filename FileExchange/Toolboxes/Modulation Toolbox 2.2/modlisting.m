% =========================================================================
% File Listing for the MODULATION TOOLBOX, version 2.1.
% To view this list in the Matlab console, type: help modlisting
%
% High-Level Analysis and Modification Functions
% ----------------------------------------------
%  modspecgramgui - Runs a GUI that allows signal analysis and modification
%                   in the modulation frequency domain.
%     modspectrum - Plots the joint-frequency modulation spectrum of a
%                   signal.
%     modspecgram - Legacy version of the modulation spectrum. Although it
%                   is still supported, use of modspectrum() instead is
%                   encouraged.
%       modfilter - Filters the modulators of a signal while keeping the
%                   original carriers unchanged.
%       moddecomp - Demodulates an audio signal, returning a collection of
%                   modulator and carrier signals.
%        modsynth - Recombines modulator and carrier signals to form an
%                   audio signal.
%     modop_shell - A template function for designing your own modulation
%                   analysis/modification/synthesis routines.
%
% Demodulation Functions
% ----------------------
%    moddecompharm  - Coherently demodulates a signal based on a pitch
%                     estimate and an assumption of harmonic carriers.
%      moddecompcog - Coherently demodulates subband signals using carriers
%                     based on time-varying spectral center-of-gravity.
%  moddecompharmcog - Coherently demodulates a signal with COG-refined,
%                     quasi-harmonic carriers.
%     moddecomphilb - Incoherently demodulates subband signals using
%                     magnitude Hilbert envelopes.
%          modrecon - Reconstructs subband signals from modulator/carrier
%                     pairs.
%      modreconharm - Reconstructs a signal from modulators and harmonic
%                     carriers.
%       detectpitch - Detects the fundamental frequency of a signal,
%                     assuming a harmonic signal model.
%      viewcarriers - Overlays carrier frequencies with a spectrogram of
%                     the original audio signal for comparison.
%        if2carrier - Converts instantaneous frequency track(s) into
%                     complex-exponential carrier signal(s).
%        carrier2if - Extracts the instantaneous frequency track(s) from
%                     the phase of complex-exponential carrier signal(s).
%
% Filtering Functions
% -------------------
%      designfilter - Designs a narrowband multirate FIR filter.
%       filterfreqz - Plots the frequency response of a multirate filter.
%  narrowbandfilter - Performs a multirate filter operation.
%
% Filterbank Functions
% --------------------
%     cutoffs2fbdesign - Generates filterbank design parameters from a list
%                        of subband cutoff frequencies.
%  designfilterbankgui - Runs a GUI for designing a filterbank with
%                        equispaced subbands and near-perfect synthesis.
%     designfilterbank - Designs a filterbank with arbitrary subband
%                        spacing and bandwidths.
% designfilterbankstft - Designs a filterbank with equispaced subbands
%                        based on the short-time Fourier transform.
%      filterbankfreqz - Plots the frequency responses of the subbands in a
%                        filterbank design.
%       filtersubbands - Use a filterbank design to extract subband
%                        signals from an audio signal.
%      filterbanksynth - Recombine subband signals to form an audio signal.
%
% Alphabetical Links:
% -------------------
% See also carrier2if
%          cutoffs2fbdesign
%          designfilter
%          designfilterbank
%          designfilterbankgui
%          designfilterbankstft
%          detectpitch
%          filterbankfreqz
%          filterbanksynth
%          filterfreqz
%          filtersubbands
%          if2carrier
%          moddecomp
%          moddecompcog
%          moddecompharm
%          moddecompharmcog
%          moddecomphilb
%          modfilter
%          modop_shell
%          modrecon
%          modreconharm
%          modspecgram
%          modspecgramgui
%          modspectrum
%          modsynth
%          narrowbandfilter
%          viewcarriers
%          
% =========================================================================

% Revision history:
%   P. Clark - revised for version 2.1, 08-27-10
%   P. Clark - prepared for beta testing, 02-23-09

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

