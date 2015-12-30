%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tutorial 3 - Basic Modulation Operations                                %
% Modulation Toolbox version 2.1                                          %
%                                                                         %
% This script runs through all of the capabilities of the Modulation      %
% Toolbox, and explicitly demonstrates the low-level building blocks that %
% are used by the high-level toolbox functions like MODDECOMP, MODFILTER  %
% and MODSPECTRUM (same as MODSPECGRAM).                                  %
%                                                                         %
% Run time (using dual-core 2.8 GHz processor and 2 GB RAM): 22 seconds.  %
%                                                                         %
% Pascal Clark, University of Washington EE Department                    %
% 08-31-10 (revised for version 2.1)                                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 1. Load a test signal

close all

% Use the following line if your current working directory is the same as
% the toolbox directory. Otherwise, you will have to change the search path
% as described in the comments in filepath.m
addpath( genpath( '.' ) );

% Female speaking English, 16 KHz, from the \sounds folder
[x fs] = wavread( 'speech_female.wav' );


% The Modulation Toolbox supports two main types of demodulation:
% multirate-filterbank-based and harmonic-based.
% 
% Filterbank demodulation consists of the following steps:
%   F1. Design and implement a filterbank (get subband signals)
%   F2. Demodulate each subband of x(n) by its unique carrier
%
% Harmonic-based demodulation consists of the following steps:
%   H1. Detect the pitch of x(n)
%   H2. Demodulate x(n) using carriers that are integer multiples of the
%       fundamental frequency
% 
% Filterbank-based demodulation can be incoherent (Hilbert envelope) or
% coherent (spectral center-of-gravity). Harmonic-based demodulation is
% strictly coherent.
% 
% If you're interested in signal modification, you need a few more steps:
%   3. Modify modulators/carriers (e.g., LTI filtering)
%   4. Remodulate and combine subbands using filterbank/harmonic synthesis
%
% The rest of this script proceeds through the aforementioned steps in more
% detail.


%% F1. Design a filterbank

% Here we use uniformly-spaced subbands in a modified short-time Fourier
% transform (STFT) filterbank. Each subband has a roughly-rectangular
% frequency response. Each subband signal is frequency-shifted to baseband
% and downsampled in time, for computational convenience.
numHalfbands  = 64;         % number of subbands from 0 to fs
sharpness     = 9;          % subband frequency-response sharpness
decFactor     = 64 / 4;     % decimation factor (chosen to avoid aliasing)
fb1 = designfilterbankstft( numHalfbands, sharpness, decFactor );

% The following figure displays the subband frequency responses, along with
% the effective 'impulse response' of the filterbank, including synthesis.
% A flat response means the filterbank satisfies perfect reconstruction.
figure, filterbankfreqz( fb1, [], fs );


% For non-uniform subband spacing, you can use DESIGNFILTERBANK to easily
% design a filterbank with arbitrary subband widths and spacing. Here is an
% example.
cutoffs = (2/fs)*[50 100 200 400 800 1600 3200 6400];
[centers bandwidths] = cutoffs2fbdesign( cutoffs );
fb2 = designfilterbank( centers, bandwidths );

% Now let's look at the subband frequency responses of this new filterbank.
figure, filterbankfreqz( fb2, [], fs );


% Choosing the filterbank with uniformly-spaced subbands, the following
% command filters the speech signal x into an array of subband signals.
S = filtersubbands( x, fb1 );

% The subband sampling rate (also the modulator and carrier sampling rate)
% will come in handy later in the script.
modFs = fs / decFactor;


%% F2. Demodulate each subband

% Coherent demodulation settings
carrierWinLen = 2^ceil( log2( modFs / 10 ) );  % 1/10 second window for computing spectral COG
carrierHop    = carrierWinLen / 2;             % skip distance for the COG window

% Coherent demodulation via spectral center-of-gravity
[Mc Cc Fc] = moddecompcog( S, carrierWinLen, carrierHop );

% Incoherent demodulation via Hilbert envelope
[Mh Ch Fh] = moddecomphilb( S );

% A major difference between coherent and incoherent demodulation is that
% coherent modulators are allowed to be complex. Although this may seem
% counter-intuitive, the generality of complex envelopes allows bandlimited
% subband carriers. In the following plots, the coherent carrier frequency
% is far better behaved than its noisy incoherent counterpart.
figure, viewcarriers( x, fs, Cc, fb1, 3 ); title( 'Spectral COG, subband 3' ), ylim( [0 1000] )
figure, viewcarriers( x, fs, Ch, fb1, 3 ); title( 'Hilbert - subband 3' ), ylim( [0 1000] )


%% H1. Detect pitch assuming a harmonic signal model

% Perhaps a better demodulation method for speech signals is to treat each
% harmonic of the fundamental frequency as one carrier.

% We first detect the pitch, assuming that x is mostly harmonic. Unvoiced
% parts will be assigned an interpolated 'fundamental frequency' based on
% the pitch values in adjacent voiced portions.

% Getting a correct pitch-track might require some tuning of parameters.
% For example, a Voicing Sensitivity of 0.3 (instead of the default 0.5)
% works best for this signal. Setting the final parameter to 1 activates
% display mode, so you can visually confirm the accuracy of the fundamental
% frequency estimate.
figure, F0 = detectpitch( x, fs, 0.3, [], [], 1 );

% Note that empty brackets [] tell the function to use its internal default
% value for a particular parameter. This convention remains consistent for
% all toolbox functions.


%% H2. Harmonic demodulation

% Demodulation parameters for harmonic demodulation
modBandwidth = (2/fs)*100;        % modulation bandwidth
numHarmonics = 15;                % number of modulated components to extract

% Obtain harmonic carriers and their respective modulator signals
% (downsampled to the same rate as those in Mc and Mh)
[Mharm Charm] = moddecompharm( x, F0, numHarmonics, modBandwidth );
Mharm = downsample( Mharm.', fb1.dfactor ).';

% The following plot displays the detected harmonic carrier frequencies.
figure, viewcarriers( x, fs, Charm ); title( 'Harmonic pitch estimate' )


% Another method is harmonic-COG demodulation, which combines both coherent
% methods. Each carrier results from a spectral COG estimate in the local
% vicinity of one harmonic frequency. This allows each carrier to deviate
% from strict harmonicity, and could correct errors in F0 estimation.
carrierWinLen = round( fs/10 );
[Mharmcog Charmcog] = moddecompharmcog( x, F0, carrierWinLen, [], numHarmonics, modBandwidth );
Mharmcog = downsample( Mharmcog.', fb1.dfactor ).';

% The following plot displays the detected harmonic carrier frequencies.
figure, viewcarriers( x, fs, Charmcog ); title( 'Harmonic pitch estimate' )


% To see how the two harmonic methods differ, this plot overlays the
% instantaneous frequency of the first and second carriers.
figure, t = (0:size(Charm,2)-1)/fs; hold on
plot( t, fs/2*carrier2if( Charm(1,:) ) ), plot( t, fs/2*carrier2if( Charm(2,:) ) ),
plot( t, fs/2*carrier2if( Charmcog(1,:) ), 'r' ), plot( t, fs/2*carrier2if( Charmcog(2,:) ), 'r' )
xlabel( 'Time (s)' ), ylabel( 'Frequency (Hz)' ), title( 'Harmonic IFs (blue) compared to quasi-harmonic (red)' )


%% 3. Modification (e.g. LTI filtering)

% We'll design a 2 Hz lowpass filter
wp = (2/modFs)*2;   % passband frequency (normalized)
wt = wp / 2;        % transition bandwidth
h  = designfilter( [0 wp], 'pass', wt );

% View the overall frequency response of the multirate filter
figure, filterfreqz( h, [], modFs ); xlim( [0 50] )

% Carry out row-wise modulation filtering operations
Mc2       = narrowbandfilter( Mc, h );
Mh2       = narrowbandfilter( Mh, h );
Mharm2    = narrowbandfilter( Mharm, h );
Mharmcog2 = narrowbandfilter( Mharmcog, h );


%% 4. Remodulation and synthesis

% Recombine the filtered modulators with the original carriers to form new
% subband signals
Scog  = modrecon( Mc2, Cc );
Shilb = modrecon( Mh2, Ch );

% Combine subbands to form the modulation-filtered output signals
ycog  = filterbanksynth( Scog, fb1 );
yhilb = filterbanksynth( Shilb, fb1 );

% Combine harmonic and quasi-harmonic components to form
% modulation-filtered output signals
yharm    = modreconharm( Mharm2, Charm );
yharmcog = modreconharm( Mharmcog2, Charmcog );


%% 5. To make sure everything is working properly, the processed signals
%  from part 7 should sound the same as the test signals provided in the
%  \sounds folder in the Modulation Toolbox.

ycog0  = wavread( 'speech_female_64bands_cog_2Hz.wav' );
yhilb0 = wavread( 'speech_female_64bands_hilbert_2Hz.wav' );
yharm0 = wavread( 'speech_female_harmonic_2Hz.wav' );

% You might also want to compare processing results for male speech. Here
% we repeat the demodulation, filtering and synthesis steps for the male
% speech example in the \sounds folder.
[x_male fs_male] = wavread( 'speech_male.wav' );
S_male = filtersubbands( x_male, fb1 );

[Mc_male Cc_male] = moddecompcog( S_male, carrierWinLen/2, carrierHop/2 );
[Mh_male Ch_male] = moddecomphilb( S_male );
F0_male = detectpitch( x_male, fs_male, 0.5 );
[Mharm_male Charm_male] = moddecompharm( x_male, F0_male, numHarmonics, 2*modBandwidth );
Mharm_male = downsample( Mharm_male.', fb1.dfactor ).';

Mc2_male    = narrowbandfilter( Mc_male, [0 2/fs*fb1.dfactor], 'pass' );
Mh2_male    = narrowbandfilter( Mh_male, [0 2/fs*fb1.dfactor], 'pass' );
Mharm2_male = narrowbandfilter( Mharm_male, [0 2/fs*fb1.dfactor], 'pass' );

ycog_male  = filterbanksynth( Mc2_male.*Cc_male, fb1 );
yhilb_male = filterbanksynth( Mh2_male.*Ch_male, fb1 );
yharm_male = modreconharm( Mharm2_male, Charm_male );

% Now you can compare the above results with the pre-computed ones in the
% \sounds folder
ycog0_male  = wavread( 'speech_male_64bands_cog_2Hz.wav' );
yhilb0_male = wavread( 'speech_male_64bands_hilbert_2Hz.wav' );
yharm0_male = wavread( 'speech_male_harmonic_2Hz.wav' );
