%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tutorial 2 - Speech Modulation Analysis                                 %
% Modulation Toolbox version 2.1                                          %
%                                                                         %
% This script uses the Modulation Toolbox to informally assess how much   %
% of speech intelligibility can be attributed to the envelopes vs. the    %
% carriers. The signals generated here also appear in the speech          %
% processing demo on the toolbox webpage:                                 %
%   http://isdl.ee.washington.edu/projects/modulationtoolbox/             %
%                                                                         %
% Run time (using dual-core 2.8 GHz processor and 2 GB RAM): 24 seconds   %
%                                                                         %
% Pascal Clark, University of Washington EE Department                    %
% 08-31-10 (revised for version 2.1)                                      %
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 1. Demodulate a speech signal using coherent pitch-synchronous carrier
%     estimation of the fundamental frequency.

% Use the following line if your current working directory is the same as
% the toolbox directory. Otherwise, you will have to change the search path
% as described in the comments in filepath.m
addpath( genpath( '.' ) );

[x fs] = wavread( 'speech_female.wav' );

numHarmonics = 16;      % number of harmonics to demodulate
modBandwidth = 150;     % modulator (envelope) bandwidth, Hz
voicingSens  = 0.3;     % signal-dependent parameter voicing-detection parameter

% Harmonic demodulation with the 'verbose' command. Verbose mode prints
% internal specifications and plots the detected carriers.
[M C data] = moddecomp( x, fs, {'harm',numHarmonics,voicingSens}, modBandwidth, 'verbose' );


%% 2. Incremental Synthesis

% First we incrementally reconstruct the speech signal one harmonic
% component at a time. How many harmonics are required for intelligibility?
% How does intelligibility change when varying the modulation bandwidth?
% Perhaps the answers depend on external factors like background noise or
% interfering background talkers.

x1  = modsynth( M(1,:),   C(1,:),   data );  % fundamental only
x2  = modsynth( M(1:2,:), C(1:2,:), data );  % harmonics 1-2
x4  = modsynth( M(1:4,:), C(1:4,:), data );  % harmonics 1-4
x8  = modsynth( M(1:8,:), C(1:8,:), data );  % harmonics 1-8
x16 = modsynth( M,        C,        data );  % harmonics 1-16


%% 3. Replace coherent carriers with harmonic sine carriers

% An interesting property of the harmonic decomposition is that only the
% modulators convey lexical information, while the carriers contain only
% pitch information. We should therefore be able to replace the original
% carriers with synthetic carriers without affecting the intelligibility of
% a speech utterance. In this test we replace the original carriers with
% constant-frequency sinusoidal carriers.

% First, here is the reconstruction of the 16 coherent carriers without any
% envelope information. If you listen to c16 you will find that it is
% entirely unintelligible.
c16 = modsynth( ones( size(C) ), C, data );
c16 = c16 / norm(c16)*norm(x)/2;

% Now we replace the original carriers with harmonics of a flat tone at 250
% Hz, which is around the speaker's actual fundamental frequency.
F0flat = 250;
C0flat = exp( j*2*pi*F0flat/fs*(0:length(x)-1) );

% Incremental synthesis using harmonics of the flat 250-Hz tone.
x1flat  = modsynth(  M(1,:),   C0flat, data );  % first harmonic only
x2flat  = modsynth(  M(1:2,:), C0flat, data );  % harmonics 1-2
x4flat  = modsynth(  M(1:4,:), C0flat, data );  % harmonics 1-4
x8flat  = modsynth(  M(1:8,:), C0flat, data );  % harmonics 1-8
x16flat = modsynth(  M,        C0flat, data );  % harmonics 1-20

% Carriers-only synthesis of the synthetic carriers.
c16flat = modsynth( ones( size(M) ), C0flat, data );
c16flat = c16flat / norm(c16flat)*norm(x)/2;


%% 4. Replace coherent carriers with noise carriers

% With the same motivation as in part 3, we now replace the original
% carriers with bandpass noise carriers. Each carrier is generated from one
% subband of a filterbank excited by white Gaussian noise.
centerFreqs = F0flat*(1:1:numHarmonics);
carrierBandwidth = F0flat;
fb = designfilterbank( centerFreqs/fs*2, carrierBandwidth/fs*2 );
groupDelay = fb.afilterorders / 2;

r = randn( size(x) );
r = r / sqrt( var(r)/2/numHarmonics );
Crand = filtersubbands( r, fb );
Crand = Crand( :, 1+groupDelay:end-groupDelay );

% Incremental synthesis.
x1rand  = modsynth(  M(1,:),   Crand(1,:),   data );  % first harmonic only
x2rand  = modsynth(  M(1:2,:), Crand(1:2,:), data );  % harmonics 1-2
x4rand  = modsynth(  M(1:4,:), Crand(1:4,:), data );  % harmonics 1-4
x8rand  = modsynth(  M(1:8,:), Crand(1:8,:), data );  % harmonics 1-8
x16rand = modsynth(  M,        Crand,        data );  % harmonics 1-20

% Carriers-only synthesis.
c16rand = modsynth( ones( size(Crand) ), Crand, data );
c16rand = c16rand / norm(c16rand)*norm(x)/2;

% The above three cases (original carriers, flat carriers, and random
% carriers) demonstrate that the carriers are more or less interchangeable
% without affecting the intelligibility of the speech signal. Using
% harmonic decomposition, the lexical information is conveyed entirely
% by the the low-bandwidth envelopes.


%% 4. Comparison between coherent and incoherent carriers and envelopes

% The above analyses used carrier-only synthesis to demonstrate that the
% lexical information in speech is independent from the carrier fine
% structure. What if we use an incoherent demodulation system instead,
% based on the often-used Hilbert envelope?

% Apply Hilbert-envelope demodulation to detect real, non-negative subband 
% envelopes, with uniformly spaced subbands 400 Hz apart.
[Mh Ch datah] = moddecomp( x, fs, 'hilb', 400 );

% Carriers-only synthesis. Compare this signal to c16 from Part 3 above.
c16incoherent = modsynth( ones( size(Mh) ), Ch, datah );
c16incoherent = c16incoherent / norm(c16incoherent)*norm(x);

% Replace the carriers with fixed tones located at the subband center
% frequencies.
Cflat = exp( diag( sparse( j*2*pi*400/fs*(0:size(Ch,1)-1) ) ) * repmat( (0:size(Ch,2)-1), size(Ch,1), 1 ) );
x16incoherent = modsynth( Mh, Cflat, datah );

% Compared to the coherent carriers-only synthesis represented by c16, the
% incoherent signal c16incoherent is far more speech-like. Whereas coherent
% carrier detection estimates only pitch cues, the incoherent carrier
% detection also preserves syllabic rhythm and possible lexical cues.
% From a mathematical standpoint, the incoherent decomposition introduces
% artifact in the form of noisy bandwidth expansion, and calls into
% question the general practice of speech analysis/modification using
% Hilbert envelopes. A quantitative study of the effects of bandwidth
% expansion appears in Tutorial 4: Modulation Filtering.
