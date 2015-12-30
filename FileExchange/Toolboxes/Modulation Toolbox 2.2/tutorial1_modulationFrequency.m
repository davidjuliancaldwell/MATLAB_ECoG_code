%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tutorial 1 - Modulation Frequency Analysis                              %
% Modulation Toolbox version 2.1                                          %
%                                                                         %
% This script introduces the concepts motivating coherent demodulation    %
% as an alternative to the incoherent Hilbert envelope. It also           %
% demonstrates how to use the high-level modulation analysis and          %
% synthesis functions included with the Modulation Toolbox:               %
%   - modspectrum (same as modspecgram)                                   %
%   - modfilter                                                           %
%   - moddecomp                                                           %
%                                                                         %
% Run time (using dual-core 2.8 GHz processor and 2 GB RAM): 33 seconds   %
%                                                                         %
% Pascal Clark, University of Washington EE Department                    %
% 08-31-10 (revised for version 2.1)                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Demo 1: Synthetic Test Signal

% Use the following line if your current working directory is the same as
% the toolbox directory. Otherwise, you will have to change the search path
% as described in the comments in filepath.m
addpath( genpath( '.' ) );

close all

% The Modulation Toolbox is designed for modulation frequency analysis and
% modification, using incoherent and coherent methods. Consider the
% following synthetic test signal consisting of a low-frequency modulator
% multiplied by a linear chirp (starting at 800 Hz and increasing at 100
% Hz/sec).
fs = 8000;
modFreq = 2;
carrFreq = 800;
t = (0:4*fs-1)/fs;

modulator = 0.1*( sin( 2*pi*modFreq*t ) + sin( 2*pi*3*modFreq*t ) );
carrier = sin( 2*pi*( carrFreq*t + 50*t.^2 ) );
x1 = modulator .* carrier;

% The modulation spectrum of this signal depends on how we choose to
% demodulate it. Figure 1 compares the "incoherent" (conventional Hilbert
% envelope) spectrum with the "coherent" (spectral center-of-gravity)
% spectrum. As seen, the coherent demodulation more accurately represents
% the 2-Hz and 6-Hz modulations without the interference of cross-terms.
figure(1), subplot( 2, 1, 1 )
modspectrum( x1, fs, 'hilb', 500 ); title( 'Non-coherent Modulation Spectrum (before filtering)', 'FontWeight', 'bold' )
axis( [-12 12 0 2000] ), climdb( [-5 15] ), colorbar

figure(1), subplot( 2, 1, 2 )
modspectrum( x1, fs, 'cog', 500 ); title( 'Coherent Modulation Spectrum (before filtering)', 'FontWeight', 'bold' )
axis( [-12 12 0 2000] ), climdb( [-5 15] ), colorbar

% Another capability of the toolbox is modulation filtering, both coherent
% and incoherent. Here we apply a 4-Hz lowpass modulation filter with the
% intent of removing the 6-Hz modulation component.
yHilb = modfilter( x1, fs, [0 4], 'pass', 'hilb', 500 );
yCOG  = modfilter( x1, fs, [0 4], 'pass', 'cog',  500 );

% For reference, here is the 2-Hz modulated signal we expect to obtain
% after lowpass modulation filtering.
desired = 0.1*sin( 2*pi*modFreq*t ) .* carrier;

% The following time-domain plots show the original signal, the desired
% (target) signal, and the incoherently-filtered and coherently-filtered
% output signals. The coherent output is the closest the target, in both
% modulation depth and modulation phase.
figure(2), subplot( 2, 2, 1 )
plot( t, x1 ), hold on, plot( t, modulator, 'r', 'LineWidth', 2 )
hold off, axis( [2 3 -0.2 0.2] ), xlabel( 'Time (s)' ), title( 'Original signal', 'FontWeight', 'bold' )
figure(2), subplot( 2, 2, 3 )
plot( t, desired ), hold on, plot( t, 0.1*sin( 2*pi*modFreq*t ), 'r', 'LineWidth', 2 )
hold off, axis( [2 3 -0.2 0.2] ), xlabel( 'Time (s)' ), title( 'Desired signal', 'FontWeight', 'bold' )
figure(2), subplot( 2, 2, 2 )
plot( t, yHilb ), axis( [2 3 -0.2 0.2] ), xlabel( 'Time (s)' ), title( 'Non-coherently lowpass filtered', 'FontWeight', 'bold' )
figure(2), subplot( 2, 2, 4 )
plot( t, yCOG ), axis( [2 3 -0.2 0.2] ), xlabel( 'Time (s)' ), title( 'Coherently lowpass filtered', 'FontWeight', 'bold' )

% Time-frequency spectrogram analysis reveals bandwidth-expansion
% distortion in the incoherently-filtered signal, an artifact that repeats
% with an 8-Hz periodicity -- exactly the component we attempted to remove
% via modulation filtering. The coherently-filtered signal, however, is
% much closer to the desired spectrogram.
figure(3), subplot( 2, 2, 1 )
specgram( x1, 512, fs, 128, 64 ), climdb( 40 ), axis( [2 3 600 1400] ), title( 'Original signal', 'FontWeight', 'bold' )
xlabel( 'Time (s)' ), ylabel( 'Frequency (Hz)' )
figure(3), subplot( 2, 2, 3 )
specgram( desired, 512, fs, 128, 64 ), climdb( 40 ), axis( [2 3 600 1400] ), title( 'Desired signal', 'FontWeight', 'bold' )
xlabel( 'Time (s)' ), ylabel( 'Frequency (Hz)' )
figure(3), subplot( 2, 2, 2 )
specgram( yHilb, 512, fs, 128, 64 ), climdb( 40 ), axis( [2 3 600 1400] ), title( 'Non-coherently lowpass filtered', 'FontWeight', 'bold' )
xlabel( 'Time (s)' ), ylabel( 'Frequency (Hz)' )
figure(3), subplot( 2, 2, 4 )
specgram( yCOG, 512, fs, 128, 64 ), climdb( 40 ), axis( [2 3 600 1400] ), title( 'Coherently lowpass filtered', 'FontWeight', 'bold' )
xlabel( 'Time (s)' ), ylabel( 'Frequency (Hz)' )

% Try listening to the modulation-filtered signals, too. You will find that
% the spectral distortion in yHilb is audible as a 8-Hz popping sound. For
% more information on coherent vs. incohrent modulation filtering, refer to
% Tutorial 5.


%% Demo 2: An Actual Speech Signal

% We could have avoided distortion in the incoherent case if we had defined
% the modulator to be a non-negative signal. But do modulations in nature
% follow this seemingly arbitrary rule? In this demo we'll compare
% incoherent modulation-filtering of speech to two coherent versions.

% Female speaking English, sampled at 16 kHz
[x2 fs] = wavread( 'speech_female.wav' );

% Incoherent modulation filter (fixed subbands, Hilbert envelopes)
subbandWidths = 250;     % Hz
yHilb = modfilter( x2, fs, [0 2], 'pass', 'hilb', subbandWidths );

% Coherent modulation filter (fixed subbands, complex envelopes)
yCOG = modfilter( x2, fs, [0 2], 'pass', {'cog'}, subbandWidths );

% Coherent modulation filter (harmonic-tracking subbands, complex envelopes)
voicingSens  = 0.3;     % signal-dependent parameter voicing-detection parameter
yHarm = modfilter( x2, fs, [0 2], 'pass', {'harm',[],voicingSens}, subbandWidths );

% As in Demo 1, the incoherently modulation-filtered signal is noisy as a
% result of spectral distortion. The coherently filtered signal, however,
% shows temporal smoothing without bandwidth expansion of the harmonics.
figure(4)
subplot( 2, 2, 1 ), specgram( x2, 1024, fs, 512, 300 ), climdb( 60 ), axis( [1 3 0 2000] ), title( 'Original speech signal', 'FontWeight', 'bold' )
subplot( 2, 2, 2 ), specgram( yHilb, 1024, fs, 512, 300 ), climdb( 60 ), axis( [1 3 0 2000] ), title( 'Non-coherently filtered', 'FontWeight', 'bold' )
subplot( 2, 2, 3 ), specgram( yCOG, 1024, fs, 512, 300 ), climdb( 60 ), axis( [1 3 0 2000] ), title( 'Coherently filtered (COG)', 'FontWeight', 'bold' )
subplot( 2, 2, 4 ), specgram( yHarm, 1024, fs, 512, 300 ), climdb( 60 ), axis( [1 3 0 2000] ), title( 'Coherently filtered (harmonic)', 'FontWeight', 'bold' )

% The following calls to MODDECOMP perform the same non-coherent and coherent
% (harmonic) decompositions used in the above MODFILTER calls, and will
% allow us to examine the modulators and carriers in more detail.
[MHilb CHilb dataHilb] = moddecomp( x2, fs, 'hilb', subbandWidths );
[MHarm CHarm dataHarm] = moddecomp( x2, fs, {'harm',[],voicingSens}, subbandWidths );

% What is the cause of spectral bandwidth distortion in the incoherent
% case? The answer is rooted in the Hilbert-envelope assumption that forces
% envelopes to be real-valued and non-negative. As a result, the modulators
% and the carriers are non-bandlimited. In the following figure, the left
% plots overlay the carrier instantaneous frequency (derivative of the
% phase) with the spectrogram of the speech signal. The incoherent case is
% highly non-bandlimited. Next, the plots on the right show a zoomed-in
% portion of the carriers (in blue) and modulator magnitudes (in red). Note
% that the coherent case also shows the modulator phase (in black), since
% the envelope is complex-valued. In the coherent case, the generality of
% complex numbers allows the modulator and the carrier to each be
% bandlimited.
figure(5)
tHilb = (0:size(CHilb,2)-1)/fs - dataHilb.filtbankparams.afilterorders/2/fs;
tHarm = (0:size(CHarm,2)-1)/fs;
subplot( 2, 2, 1 ), viewcarriers( x2, fs, CHilb, dataHilb, 2 ); axis( [1 3 0 800] )
title( 'Incoherent carrier instantaneous frequency' )
subplot( 2, 2, 2 ), plot( tHilb, real( CHilb(2,:) ) ), hold on, plot( tHilb, 28*MHilb(2,:), 'r', 'LineWidth', 2 ), hold off, xlim( [1.29 1.43] )
title( 'Incoherent carrier (blue) and modulator (red)' ), xlabel( 'Time (s)' )
subplot( 2, 2, 3 ), viewcarriers( x2, fs, CHarm, dataHarm, 1 ); axis( [1 3 0 800] )
title( 'Coherent carrier instantaneous frequency' )
subplot( 2, 2, 4 ), plot( tHarm, real( CHarm(1,:) ) ), hold on, plot( tHarm, 28*abs(MHarm(1,:)), 'r', 'LineWidth', 2 ), plot( tHarm, cos( angle(MHarm(1,:)) ), 'k', 'LineWidth', 2 ), hold off, xlim( [1.29 1.43] )
title( 'Coherent carrier (blue), modulator magnitude (red), modulator phase (black)' ), xlabel( 'Time (s)' )

% This code stretches the width of the figure window
set( figure(5), 'Units', 'inches' );
P = get( figure(5), 'Position' );
P( 3 ) = 9;
set( figure(5), 'Position', P );
