%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tutorial 4 - Distortion-Free Modulation Filtering                       %
% Modulation Toolbox version 2.1                                          %
%                                                                         %
% This script quantitatively measures the performance of a modulation     %
% filter based on whether the filtered envelopes can be recovered after   %
% a seconds demodulation. The following results appear in [1] and [2],    %
% using the analysis method of [3].                                       %
%                                                                         %
% Run time (using dual-core 2.8 GHz processor and 2 GB RAM): 27 seconds.  %
%                                                                         %
% Pascal Clark, University of Washington EE Department                    %
% 09-01-10 (revised for version 2.1)                                      %
%                                                                         %
% References:                                                             %
% [1] P. Clark and L. Atlas, "Time-Frequency Coherent Modulation          %
%     Filtering of Nonstationary Signals," IEEE Trans. Sig. Process.,     %
%     vol. 57, no. 11, Nov. 2009.                                         %
% [2] P. Clark and L. Atlas, "A Sum-of-Products Model for Effective       %
%     Coherent Modulation Filtering," Proc. IEEE ICASSP 2009.             %
% [3] S. Schimmel and L. Atlas, "Coherent Envelope Detection for          %
%     Modulation Filtering of Speech," Proc. IEEE ICASSP 2005.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 1. Load a test signal

close all

% Use the following line if your current working directory is the same as
% the toolbox directory. Otherwise, you will have to change the search path
% as described in the comments in filepath.m
addpath( genpath( '.' ) );

% Male speaking English, 8 KHz, from the \sounds folder
[x fs] = wavread( 'speech_male.wav' );


%% 2. Modulation Filtering

% The MODFILTER function demodulates a signal and applies an LTI filter to
% the detected modulators. The output signal results from recombining the
% filtered modulators with the original carriers.

% Subband bandwidth (Hz), which will also be the modulator bandwidth.
freqDiv = 150;

% Incoherent modulation filtering, using Hilbert envelopes.
yHilb = modfilter( x, fs, [0 2], 'pass', 'hilb', freqDiv );

% Coherent modulation filtering using complex envelopes computed via
% spectral center-of-gravity carrier detection.
yCOG = modfilter( x, fs, [0 2], 'pass', 'cog', freqDiv );

% Coherent modulation filtering using complex envelopes computed via
% harmonic (pitch-based) carrier detection.
yHarm = modfilter( x, fs, [0 2], 'pass', 'harm', freqDiv/2 );


%% 3. Modulation Spectral Analysis

% We use MODSPECGRAM to view a colormap representing modulation-frequency
% power spectra with respect to the three demodulation methods used above,
% before and after modulation filtering. All three cases show somewhat of a
% lowpass effect, but it can be difficult to see evidence for the expected
% 2-Hz cutoff.

figure,
subplot( 2, 3, 1 ), modspectrum( x, fs, 'hilb', freqDiv, 'normalize' );
xlim( [-10 10] ), title( 'Original Hilbert', 'FontWeight', 'bold' )
subplot( 2, 3, 2 ), modspectrum( x, fs, 'cog', freqDiv, 'normalize' );
xlim( [-10 10] ), title( 'Original COG', 'FontWeight', 'bold' )
subplot( 2, 3, 3 ), modspectrum( x, fs, 'harm', freqDiv/2, 'normalize' );
xlim( [-10 10] ), title( 'Original Harmonic', 'FontWeight', 'bold' )

subplot( 2, 3, 4 ), modspectrum( yHilb, fs, 'hilb', freqDiv, 'normalize' );
xlim( [-10 10] ), title( 'Filtered Hilbert', 'FontWeight', 'bold' )
subplot( 2, 3, 5 ), modspectrum( yCOG, fs, 'cog', freqDiv, 'normalize' );
xlim( [-10 10] ), title( 'Filtered COG', 'FontWeight', 'bold' )
subplot( 2, 3, 6 ), modspectrum( yHarm, fs, 'harm', freqDiv/2, 'normalize' );
xlim( [-10 10] ), title( 'Filtered Harmonic', 'FontWeight', 'bold' )


%% 4. Modulation Spectral Analysis with Carrier Side Information

% It turns out we must change the way we view modulator spectra in order to
% see the full effects of the 2-Hz lowpass filter. In the following, we
% decompose the original signal an obtain the original carriers. Then, we
% demodulate the processed signals (yHilb, yCOG, and yHarm) with respect to
% the original carriers, unlike in Part 3 where we re-estimated the
% carriers from the processed signals.

% Modulation decompositions to extract the original carrier signals
[MHilb CHilb dataHilb] = moddecomp( x, fs, 'hilb', freqDiv, 'maximal' );
[MCOG  CCOG  dataCOG]  = moddecomp( x, fs, 'cog',  freqDiv, 'maximal' );
[MHarm CHarm dataHarm] = moddecomp( x, fs, 'harm', freqDiv/2, 'maximal' );

% Incoherent Hilbert modulation spectra after filtering, using the original
% carriers
SHilb = filtersubbands( yHilb, dataHilb.filtbankparams );
Mrecov = SHilb.*conj( CHilb );
W = diag( sparse( hamming( size(Mrecov,2) ) ) );
Mrecov = diag( sparse( 1./sqrt( sum( abs(Mrecov).^2, 2 ) ) ) ) * Mrecov * W;
PHilb = fft( Mrecov, [], 2 );

% Coherent modulation spectra after filtering, using the original spectral
% COG carriers
SCOG = filtersubbands( yCOG, dataCOG.filtbankparams );
Mrecov = SCOG.*conj( CCOG );
W = diag( sparse( hamming( size(Mrecov,2) ) ) );
Mrecov = diag( sparse( 1./sqrt( sum( abs(Mrecov).^2, 2 ) ) ) ) * Mrecov * W;
PCOG = fft( Mrecov, [], 2 );

% Coherent modulation spectra after filtering, using the original harmonic
% carriers
Mrecov = moddecompharm( yHarm, dataHarm.F0/fs*2, size(CHarm,1), dataHarm.modbandwidth/fs*2 );
Mrecov = downsample( Mrecov.', dataHarm.dfactor ).';
W = diag( sparse( hamming( size(Mrecov,2) ) ) );
Mrecov = diag( sparse( 1./sqrt( sum( abs(Mrecov).^2, 2 ) ) ) ) * Mrecov * W;
PHarm = fft( Mrecov, [], 2 );

% Visual comparisons
figure,
subplot( 2, 3, 1 ), modspectrum( x, fs, 'hilb', freqDiv, 'normalize' );
xlim( [-10 10] ), title( 'Original Hilbert', 'FontWeight', 'bold' )
subplot( 2, 3, 2 ), modspectrum( x, fs, 'cog', freqDiv, 'normalize' );
xlim( [-10 10] ), title( 'Original COG', 'FontWeight', 'bold' )
subplot( 2, 3, 3 ), modspectrum( x, fs, 'harm', freqDiv/2, 'normalize' );
xlim( [-10 10] ), title( 'Original Harmonic', 'FontWeight', 'bold' )

maxis = (0:size(MHilb,2)-1)/size(MHilb,2)*dataHilb.modfs - dataHilb.modfs/2;
faxis = dataHilb.filtbankparams.centers/2*fs;
subplot( 2, 3, 4 ), imagesc( maxis, faxis, 20*log10( abs( fftshift( PHilb, 2 ) ) ) ), axis xy,
xlim( [-10 10] ), climdb( 40 ), title( 'Filtered Hilbert', 'FontWeight', 'bold', 'FontWeight', 'bold' )
xlabel( 'Modulation Frequency (Hz)' ), ylabel( 'Acoustic Frequency (Hz)' )

maxis = (0:size(MCOG,2)-1)/size(MCOG,2)*dataCOG.modfs - dataCOG.modfs/2;
faxis = dataCOG.filtbankparams.centers/2*fs;
subplot( 2, 3, 5 ), imagesc( maxis, faxis, 20*log10( abs( fftshift( PCOG, 2 ) ) ) ), axis xy,
xlim( [-10 10] ), climdb( 40 ), title( 'Filtered COG', 'FontWeight', 'bold' )
xlabel( 'Modulation Frequency (Hz)' ), ylabel( 'Acoustic Frequency (Hz)' )

maxis = (0:size(MHarm,2)-1)/size(MHarm,2)*dataHarm.modfs - dataHarm.modfs/2;
faxis = (1:size(MHarm,1));
subplot( 2, 3, 6 ), imagesc( maxis, faxis, 20*log10( abs( fftshift( PHarm, 2 ) ) ) ), axis xy,
xlim( [-10 10] ), climdb( 40 ), title( 'Filtered Harmonic', 'FontWeight', 'bold' )
xlabel( 'Modulation Frequency (Hz)' ), ylabel( 'Acoustic Frequency (Hz)' )


%% 5. Quantitative Measure of Filter Performance

% To get a better idea of the modulation filter performance, this section
% calculates the average modulator transfer function. As seen, with the
% inclusion of carrier side information (described in Part 4), both
% coherent methods greatly outperform the incoherent Hilbert envelope. This
% is because incoherent demodulation introduces distortion in the form of
% nonlinear bandwidth expansion.

% Original modulation spectra
PHilb0 = modspectrum( x, fs, 'hilb', freqDiv,   'normalize' );
PCOG0  = modspectrum( x, fs, 'cog',  freqDiv,   'normalize' );
PHarm0 = modspectrum( x, fs, 'harm', freqDiv/2, 'normalize' );

% Intended modulation transfer function (2 Hz lowpass impulse response)
impulse = [zeros(floor(length(x)/2),1); 1; zeros(ceil(length(x)/2)-1,1)];
G = narrowbandfilter( impulse, [0 2]/fs*2, 'pass' );
G = abs( fft( G.*hamming(length(G)) ) );
G = G / G(1);

% Empirical average modulation transfer function (incoherent)
GHilb = sum( abs( PHilb./PHilb0 ) );
GHilb = GHilb / GHilb(1);

% Empirical average modulation transfer function (coherent spectral COG)
GCOG = sum( abs( PCOG./PCOG0 ) );
GCOG = GCOG / GCOG(1);

% Empirical average modulation transfer function (coherent harmonic)
GHarm = sum( abs( PHarm./PHarm0 ) );
GHarm = GHarm / GHarm(1);

% Visual comparisons
figure,
subplot( 1, 3, 1 ), maxis = (0:length(GHilb)-1)/length(GHilb)*dataHilb.modfs;
plot( (0:length(G)-1)/length(G)*fs, 20*log10( G ), 'Color', [.5 .5 .5] ), hold on
plot( maxis, 20*log10( GHilb ) ); axis( [0 10 -80 10] ), hold off
xlabel( 'Modulation Freq. (Hz)' ), ylabel( 'dB Magnitude' ), title( 'Incoherent', 'FontWeight', 'bold' )

subplot( 1, 3, 2 ), maxis = (0:length(GCOG)-1)/length(GCOG)*dataCOG.modfs;
plot( (0:length(G)-1)/length(G)*fs, 20*log10( G ), 'Color', [.5 .5 .5] ), hold on
plot( maxis, 20*log10( GCOG ) ); axis( [0 10 -80 10] ), hold off
xlabel( 'Modulation Freq. (Hz)' ), ylabel( 'dB Magnitude' ), title( 'Coherent (COG)', 'FontWeight', 'bold' )

subplot( 1, 3, 3 ), maxis = (0:length(GHarm)-1)/length(GHarm)*dataHarm.modfs;
plot( (0:length(G)-1)/length(G)*fs, 20*log10( G ), 'Color', [.5 .5 .5] ), hold on
plot( maxis, 20*log10( GHarm ) ); axis( [0 10 -80 10] ), hold off
xlabel( 'Modulation Freq. (Hz)' ), ylabel( 'dB Magnitude' ), title( 'Coherent (Harmonic)', 'FontWeight', 'bold' )

