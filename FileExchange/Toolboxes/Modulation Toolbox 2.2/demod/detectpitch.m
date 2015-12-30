function [F0 F0m voicing] = detectpitch( x, fs, voicingSens, medFiltLen, freqCutoff, display, interpMethod )
% [F0 F0M VOICING] = DETECTPITCH( X, FS, <VOICINGSENS>, <MEDFILTLEN>, <FREQCUTOFF>, <DISPLAY> )
%
% Detects the fundamental frequency of a harmonic signal with nonharmonic
% segments interpolated by straight lines. A small random component makes
% it possible that two identical function calls can return slightly
% different results.
%
% INPUTS:
%               X - A real-valued vector time-series.
%              FS - The sampling rate of x, in Hz.
%   <VOICINGSENS> - Sets the sensitivity of the voicing detector, on a
%                   sliding scale from 0 (minimial voicing) to 1 (maximal
%                   voicing). The default is 0.5.
%    <MEDFILTLEN> - The length of the median-filter used to smooth the
%                   pitch estimate. The default is 3, where 1 indicates no
%                   smoothing.
%    <FREQCUTOFF> - The upper frequency cutoff (in Hz) used for pitch
%                   detection. A smaller cutoff will shorten computation
%                   time at the expense of possible errors resulting from
%                   reduced temporal resolution. The default is 2000 Hz.
%       <DISPLAY> - Plots the spectrogram of X overlaid with the detected
%                   fundamental frequency contour. The default is 0 (no
%                   display).
% OUTPUTS:
%              F0 - The fundamental frequency of X, with interpolated unvoiced
%                   parts, and normalized by FS/2 so that 1 represents the
%                   Nyquist rate.
%             F0M - The actual measured pitch values, occurring every 25
%                   milliseconds, also normalized by FS/2. F0M is the
%                   downsampled version of F0 with unvoiced parts indicated
%                   by zeros.
%         VOICING - A vector indicating 1 for voiced and 0 for unvoiced,
%                   sampled at the same rate as F0M.
% 
% See also moddecompharm, moddecompharmcog, modreconharm, modlisting

% Revision history:
%   P. Clark - fixed all-zero F0 bug, 07-06-10
%   P. Clark - changed pitch resolution from 0.1 to 1 Hz, 06-29-10
%   P. Clark - new peak-finding, voiced detection, post-processing, 06-25-10
%   P. Clark - prepared for beta testing, 04-15-09
%   B. King  - successive pitch refinement, 04-20-08
%   Q. Li    - least-squares harmonic model, 07-??-02

% Contact:
%   Pascal Clark (UWEE)    : clarkcp @ u.washington.edu
%   Prof. Les Atlas (UWEE) :   atlas @ u.washington.edu
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
% 
% Voicing detection:
%   [1] S. Van Gerven and F. Xie, "A comparative study of speech detection
%       methods," in Proc. 5th Eur. Conf. Speech Comm. Tech., EUROSPEECH
%       1997, Rhodes, Greece, 1997.
% 
% Least-squares harmonic modeling
%   [2] N. Abu-Shikhah and M. Deriche, "A robust technique for harmonic
%       analysis of speech," ICASSP 2001, Salt Lake City, Utah, USA.
%   
%   [3] R.J. McAulay, T.F. Quatieri, "Pitch estimation and voicing
%       detection based on a sinusoidal speech model," ICASSP 1990,
%       Albuquerque, NM, USA.
% 
% Nonlinear post-filtering (e.g., median filtering)
%   [4] L.R. Rabiner, M.R. Sambur and C.E. Schmidt, "Applications of a
%       nonlinear smoothing algorithm to speech processing," IEEE Trans.
%       Acoust., Speech, and Sig. Proc., vol. ASSP-23, no. 6, December 1975
% -------------------------------------------------------------------------


% Set default parameter values
% ------------------------------------------------------------------------
if nargin < 2
    error( 'Not enough input arguments.' )
end
if nargin < 3 || isempty( voicingSens )
    voicingSens = 0.5;
end
if nargin < 4 || isempty( medFiltLen )
    medFiltLen = 3;
end
if nargin < 5 || isempty( freqCutoff )
    freqCutoff = 2000;
end
if nargin < 6 || isempty( display )
    display = 0;
end
if nargin < 7 || isempty( interpMethod )
    interpMethod = 'linear';
end

% Check for improperly formatted inputs
checkInputs( x, fs, medFiltLen, voicingSens, freqCutoff, display );

% The rest of the function assumes a column vector
if size( x, 1 ) == 1
    x = x.';
    isRowVector = 1;
else
    isRowVector = 0;
end

% Downsample the signal for computational efficiency
% ------------------------------------------------------------------------
origLen = length( x );
origFs  = fs;

% Downsample for computational efficiency; however, the reduced temporal
% resolution can cause errors in pitch estimation based on finding peaks in
% the short-time autocorrelations
decFactor = max( 1, floor( fs/2/freqCutoff ) );
x = decimate( x, decFactor );
fs = fs / decFactor;


% Define constants
% ------------------------------------------------------------------------
F0min = 50;         % Hz
F0max = 600;        % Hz
winDur = 0.05;      % seconds
winHop = 0.025;     % seconds
winLen = ceil( winDur*fs );     % samples
winHop = ceil( winHop*fs );     % samples
ARorder = 12;       % linear-predictive whitening filter order
modelOrder = 4;     % number of harmonics to use in the least-squares model fit


% Buffer the signal for frame-wise processing
% ------------------------------------------------------------------------
numFrames = ceil( length(x) / winHop );
xcorrLen = 2*winLen-1;

win = hamming( winLen );
win = win / norm( winLen );

B = buffer2( x, winLen, winHop, -winHop, numFrames );

% Autocorrelation for each time frame
R = real( ifft( abs( fft( diag(win)*B, xcorrLen ) ).^2 ) );
R = R( 1:winLen, : );


% Detect voicing based on the presumably bimodal log-RMS distribution,
% where the user-defined voicing threshold places the decision boundary 
% on a sliding scale between the unvoiced distribution mean (thresh<0.5)
% and the voiced distribution mean (thresh>0.5). Works for clean speech,
% and will degrade with added noise or interference.
% ------------------------------------------------------------------------
frameRMS = sqrt( sum( abs( B ).^2 ) );
voicing = medfilt1( double( detectVoicing( log( frameRMS ), voicingSens ) ), 3 );

if ~any( voicing == 1 )
    voicing = ones( size( voicing ) );
    warning( 'detectpitch:voicing1', 'No voicing detected, so this signal will be treated as ''voiced''. Consider revising parameter values.' );
end

% Frame-wise processing, consisting of the following steps to estimate F0
% for each frame:
%   1. Find the location of the largest peak in the frame autocorrelation
%   2. Find the location of the largest peak in the whitened frame autocorr
%   3. From these two estimates, choose the most likely F0 candidate
%   4. Refine the F0 estimate using a least-squares search over a
%      successively narrowing frequency range.
% ------------------------------------------------------------------------
F0m  = zeros( numFrames, 1 );

for i = 1:numFrames

    if ~voicing( i )
        % Skip this frame
        continue;
    end

    if i > 1
        % Whiten using initial conditions from the previous frame
        bw = whiten( B(:,i), ARorder, B(winHop-ARorder+1:winHop,i-1) );
    else
        % Whiten using the symmetrized signal for the initial conditions
        bw = whiten( B(:,i), ARorder );
    end
    
    % Whitened autocorrelation
    R2 = xcorr( bw );
    R2 = R2( winLen:end );
    
    % Detect the location of the largest peak in the autocorrelations,
    % including peaks that may land between samples (each autocorrelation
    % is shifted by 0.5 samples using sinc interpolation). findPeaks()
    % returns -1 if it can't find any viable peak locations.
    numPeaks = 1;
    useHalfSampleDelay = 1;
    peakInd1 = findPeaks( R(:,i), round(fs/F0max), numPeaks, useHalfSampleDelay );
    peakInd2 = findPeaks( R2, round(fs/F0max), numPeaks, useHalfSampleDelay );
    
    % Initial F0 estimates based on peak location - these will be coarsely
    % quantized as dictated by the sampling rate
    tempF01 = fs / ( peakInd1 - 1 );
    tempF02 = fs / ( peakInd2 - 1 );
    
    tempF01viable = peakInd1 ~= -1 && tempF01 <= F0max && tempF01 >= F0min;
    tempF02viable = peakInd2 ~= -1 && tempF02 <= F0max && tempF02 >= F0min;
    
    lastVoicedF0 = find( F0m(1:i-1) > 0, 1, 'last' );
    
    % Determine which F0 estimate is closest to the F0 measurement from the
    % most recent voiced frame
    if ~isempty( lastVoicedF0 )
        diff1 = abs( F0m( lastVoicedF0 ) - tempF01 );
        diff2 = abs( F0m( lastVoicedF0 ) - tempF02 );
    else
        diff1 = abs( tempF01 - ( F0max+F0min )/2 );
        diff2 = abs( tempF02 - ( F0max+F0min )/2 );
    end
    
    % With two separate estimates of F0, choose one based on these
    % heuristics: the true F0 is the one closest to the most recent
    % previous pitch estimate while being bounded within the min. and max.
    % allowed F0 values.
    if ~tempF01viable && ~tempF02viable
        voicing( i ) = 0;
        continue;
    elseif diff1 <= diff2 || ~tempF02viable
        tempF0 = tempF01;
    elseif diff1 > diff2 || ~tempF01viable
        tempF0 = tempF02;
    else
        voicing( i ) = 0;
        continue;
    end
    
    % The following for-loop successively narrows down the F0 estimate by
    % fitting the frame data to a harmonic model that minimizes squared
    % error over a uniform search grid of possible values for the fundamental
    % frequency. The number of iterations set in order to get down to around 
    % 1 Hz quantization of the pitch estimate.
    freqRes = fs/winLen;
    numRecursions = floor( -log( 1/freqRes ) / log( 5 ) );
    
    for k = 1:numRecursions
        % Define the F0 search range
        lowerBound = tempF0 - freqRes/2;
        upperBound = tempF0 + freqRes/2;
        F0step = freqRes/5;
        
        % Least-squares fit
        tempF0 = lsharm( B(:,i), fs, lowerBound:F0step:upperBound, modelOrder );
        
        freqRes = F0step;
    end
    
    F0m( i ) = tempF0;
end

% Throw out pitch detections which are outside the allowable range
F0m( F0m < F0min | F0m > F0max ) = 0;

% Post-processing to smooth the F0 estimate and resample back to the
% original signal sampling rate
% ------------------------------------------------------------------------
F0m = medfilt1( F0m, medFiltLen );
F0  = F0m;

% Make sure all frames with zero-F0 are labeled 'unvoiced' (after
% median-filter smoothing, some F0 estimates can switch between being
% voiced or unvoiced)
voicing = F0 ~= 0;

if ~any( F0 > 0 )
    F0 = zeros( 1, origLen );
    if isRowVector, F0 = F0'; end
    warning( 'detectpitch:voicing2', 'No voicing detected. Consider revising parameter values.' );
    return;
end

% If the endpoints are unvoiced, then replace them with default values so
% that interpolation is adequately constrained.
voicing2 = voicing;

if voicing( 1 ) == 0
    F0( 1 ) = F0( find( voicing2==1, 1 ) );
    voicing2( 1 ) = 1;
end
if voicing( end ) == 0
    F0( end ) = F0( find( voicing2==1, 1, 'last' ) );
    voicing2( end ) = 1;
end

% Interpolate the unvoiced parts (with the option between linear or cubic
% spline interpolation)
vSamples = find( voicing2 == 1 );
if strcmp( interpMethod, 'linear' )
    F0 = interp1( vSamples, F0( vSamples ), (1:length(F0m))', 'linear' );
else
    F0 = interp1( vSamples, F0( vSamples ), (1:length(F0m))', 'pchip' );
end

% Resample back to the original sampling rate. We need some careful
% interpolation here, since the measured pitch values in F0m might be
% heavily downsampled (by a factor of winHop).
L  = min( 4, floor( (numFrames-1)/2 ) );
F0 = factorinterp( F0, decFactor*winHop, L, 0.25 );
F0 = F0( 1:origLen );


% Optional display
% ------------------------------------------------------------------------
if display
    faxis = (0:winLen-1)/winLen*fs;
    taxis = (0:size(B,2)-1)/fs*winHop;
    imagesc( taxis, faxis, 20*log10( abs( fft( diag(win)*B ) ) ) ), axis xy, climdb( 40 ), hold on
    colormap( 'gray' )
    plot( taxis, F0m,  'b', 'LineWidth', 2 )
    plot( taxis, F0min*voicing, 'r', 'LineWidth', 2 )
    hold off, ylim( [0 50+max( F0m )] )
    ylabel( 'Frequency (Hz)' ), xlabel( 'Time (s)' ), title( 'Spectrogram (gray), detected pitch (blue), voiced regions (red)' )
end

% Normalized frequency units, where 1 corresponds to the Nyquist rate
F0  = F0/origFs*2;
F0m = F0m/origFs*2;

if isRowVector
    F0 = F0.';
    F0m = F0m.';
    voicing = voicing.';
end

end % End detectpitch


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function B = buffer2( x, winlen, hop, startindex, numframes )
% Buffer the row vector x with window length winlen and skip distance hop.
% The signal is appended with zeros in order to achieve the specified
% number of frames. The startindex specifies where the first frame begins,
% supposing that x begins at time sample index 0.

    if startindex <= 0
        prepend = zeros( -startindex, 1 );
        x = [prepend; x];
    else
        x = x( 1+startindex : end );
    end
    
    len = winlen + ( numframes-1 )*hop;
    
    x = [x; zeros( len - length(x), 1 )];
    
    if hop <= winlen
        B = buffer( x, winlen, winlen-hop, 'nodelay' );
    else
        B = buffer( x, winlen, winlen-hop, 0 );
    end

end % End buffer2


% -------------------------------------------------------------------------
function voiced = detectVoicing( logRMS, voicingSensitivity )
% Returns a vector with 1 indicating voiced and 0 indicating unvoiced. The
% voicing decision derives from a signal-adaptive method that fits a
% two-component Gaussian mixture model to the (presumably) bimodal
% distribution of the log energy for each time frame. The voicing
% sensitivity parameter can override the automatic threshold by pushing it
% toward the unvoiced distribution mean (sensitivity = 1) or toward the
% voiced distribution mean (sensitivity = 0).
    
    if nargin == 1 || isempty( voicingSensitivity )
        voicingSensitivity = 0.5;
    end
    
    % Replace -Inf values with the next smallest finite value. (-Inf
    % results from log of zero, when there is no energy in the frame)
    logRMS( isinf( logRMS ) ) = min( logRMS( ~isinf( logRMS ) ) );
        
    % A bimodal distribution corresponding to voiced/unvoiced is the
    % logarithm of the frame RMS. The assumption here is that the frame RMS
    % distributions are right-skewed and therefore symmetrized by the
    % logarithmic transformation.
    numTrials = 10;
    numIter   = round(length(logRMS)/4);
    [d1 d2]   = bimodalGaussianMixture( logRMS, numIter, numTrials );
    
    % Coefficients of the quadratic expression for the threshold at which
    % the two weighted distributions intersect (equal likelihood)
    q = [d2.sigma - d1.sigma, ...
         -2*(d2.sigma*d1.mu - d1.sigma*d2.mu), ...
         d2.sigma*d1.mu^2 - d1.sigma*d2.mu^2 - 2*d1.sigma*d2.sigma*log( d1.p/d2.p*sqrt( d2.sigma/d1.sigma ) )];

    if abs( q(1) ) < eps && abs( d1.mu - d2.mu ) > eps
        % In this case the variances of the two distributions are nearly
        % equal and the threshold reduces to a linear discriminant
        t = ( d2.mu^2 - d1.mu^2 + 2*d2.sigma*log( d1.p/d2.p ) ) / 2 / ( d2.mu - d1.mu );
        voiced = logRMS > t;
        return
    end
    
    % Optimal decision boundaries (roots of the quadratic expression)
    t1 = ( -q(2) + sqrt( q(2)^2 - 4*q(1)*q(3) ) ) / ( 2*q(1) );
    t2 = ( -q(2) - sqrt( q(2)^2 - 4*q(1)*q(3) ) ) / ( 2*q(1) );
    
    t1Between = ( t1 > d1.mu && t1 < d2.mu ) || ( t1 > d2.mu && t1 < d1.mu );
    t2Between = ( t2 > d1.mu && t2 < d2.mu ) || ( t2 > d2.mu && t2 < d1.mu );
    
    % Find the threshold located between the two distribution means
    if t1Between && ~t2Between
        thresh = t1;
    elseif t2Between && ~t1Between
        thresh = t2;
    else
        % If neither or both of the thresholds are situated between the
        % estimated means, then resort to a simple heuristic (this is the
        % case where the distribution is not really bimodal)
        voiced = logRMS > percentile( logRMS, 1-voicingSensitivity );
        return
    end
    
    if d1.mu < d2.mu
        muUnvoiced = d1.mu;
        muVoiced   = d2.mu;
    else
        muUnvoiced = d2.mu;
        muVoiced   = d1.mu;
    end
    
    if voicingSensitivity > 0.5
        % Slide the threshold on a linear scale toward muUnvoiced
        thresh = thresh - 2*(voicingSensitivity-0.5)*(thresh-muUnvoiced);
    elseif voicingSensitivity < 0.5
        % Slide the threshold on a linear scale toward muVoiced
        thresh = thresh + 2*(0.5-voicingSensitivity)*(muVoiced-thresh);
    end
    
    voiced = logRMS > thresh;
    
end % End detectVoicing


% -------------------------------------------------------------------------
function y = whiten( x, ARorder, xPrev )

    % Find autoregressive coefficients via linear prediction
    a = lpc( x, ARorder );

    % Whiten (guarding against filter transients)
    if nargin < 3
        zi = a(end:-1:2)*hankel( x( ARorder:-1:1 ) );
    else
        zi = a(end:-1:2)*hankel( xPrev );
    end

    y = filter( a, 1, x, zi );

end % whiten


% -------------------------------------------------------------------------
function [peakPosOut peakValOut] = findPeaks( x, minDistance, numPeaks, halfSampleShift )
% Finds the locations of the largest peaks in x that are located more than
% minDistance samples from the front of the vector. If halfSampleShift is
% set to 1, then the function will look for the largest peak(s) in x as
% well as its half-sample delayed version, accomplished through sinc
% interpolation (really just a linear-phase term in the DFT).
%
% Brian King, 4/20/2008
% Pascal Clark, 10/19/2008, 11/09/2009

    if size(x,2) == length(x)
        transposed = 1;
        x = x(:);
    else
        transposed = 0;
    end
    
    if halfSampleShift
        % This option includes peak-searching on the input data series as
        % well as its half-sample delayed version
        [p1 v1] = findPeaks( x, minDistance, numPeaks, 0 );
        [p2 v2] = findPeaks( nonIntGroupDelay( x, 0.5 ), minDistance, numPeaks, 0 );
        
        localPeakPos = [p1; p2-0.5];
        localPeakVal = [v1; v2];
    else
        % This ensures that no peaks located prior to, or at the index
        % minDistance, will be returned as output
        x( 1:minDistance ) = x( minDistance );

        % Selector array for isolating local peaks
        localPeaks = ( x(2:end-1) > x(1:end-2) ) & ( x(2:end-1) > x(3:end) );
        localPeaks = [0; localPeaks; 0];

        % Local peak indices and values
        localPeakPos = find( localPeaks == 1 );
        localPeakVal = x( localPeakPos );
    end
    
    [sortedPeaks idx] = sort( localPeakVal, 'descend' );
    
    if numPeaks <= length( idx )
        % Return only the requested number of peaks
        peakPosOut = localPeakPos( idx( 1:numPeaks ) );
        peakValOut = localPeakVal( idx( 1:numPeaks ) );
    else
        % Return as many peaks as possible, with -1 filling if there aren't
        % as many as requested
        peakPosOut = [localPeakPos( idx ); -ones( numPeaks-length(idx), 1 )];
        peakValOut = [localPeakVal( idx ); NaN*ones( numPeaks-length(idx), 1 )];
    end
    
    if transposed
        peakPosOut = peakPosOut';
        peakValOut = peakValOut.';
    end

end % End findPeaks


% ------------------------------------------------------------------------
function xs = nonIntGroupDelay( x, delay )
% Delays the time-series x by a non-integer delay by multiplying the DFT
% with a carefully constructed linear-phase term.

    DCIndex = floor( length(x)/2 );
    linearPhaseTerm = exp( -j*2*pi*delay/length(x)*( (0:length(x)-1) - DCIndex )' );
    linearPhaseTerm = circshift( linearPhaseTerm, -DCIndex );
    
    xs = real( ifft( fft( x ).*linearPhaseTerm ) );
    
    % COMMENT: The linear-phase term will be conjugate-symmetric except
    % possibly at the index corresponding to the Nyquist rate (when nfft is
    % even). In that case, taking the real part of the inverse Fourier
    % transform might attenuate the Nyquist component and violate the
    % concept of an all-pass filter. But the Nyquist coefficient is
    % technically distorted by aliasing when sampling the theoretical
    % continuous-time signal x(t) to form x(n). For this reason the Nyquist
    % component is lost forever and is not subject to meaningful
    % non-integer sample delay.

end % End nonIntGroupDelay


% ------------------------------------------------------------------------
function [f0 amp phi err] = lsharm( data, fs, freqs, order, weight )
% LSHARM   Constant frequency Least Squares Harmonic analysis function
%
% usage: [f0,amp,phi,error]=lsh(data,fs,freqs,order,err_weight)
% input arguments:
%        data: input data
%          fs: sampling frequency
%       freqs: a range of frequencies that will be searched to find the one 
%              with least squares error, assuming a harmonic signal model
%       order: total number of harmonic components
%      weight: harmonic weighting (a vector whose length = order)
% output arguments:
%         amp: amplitudes for each harmonic component (Fourier values
%              normalized by sqrt(N), where N = length(data))
%         phi: phase angles for each harmonic component
%          f0: fundamental frequency
%         err: modeling error (MSE) for each test frequency in freqs
%
% Reference: 
%    A robust technique for harmonic analysis of speech, Nazih Abu-Shikhan, 2001
%
% Writen by:
%   Qin Li, July, 2002
%
% Modified by:
%   Pascal Clark (04-23-10) - removed 'detrend' operation
%   Pascal Clark (11-05-09) - again revised for efficiency
%   Pascal Clark (10-20-08) - revised for efficiency
%   Brian King (7-2-08) - added decision-making based on f0Prev

    if nargin < 4
        error('At least four arguments are required');
    end
    if nargin < 5 || isempty(weight)
        weight = ones( order, 1 );
    end

    data = data(:);
    weight = weight(:);

    if isempty(freqs)
        error('freqs cannot be empty');
    end

    data = data - mean(data);
    N  = length(data);

    phi_all = zeros(order,length(freqs));
    amp_all = zeros(order,length(freqs));
    P = zeros( length(freqs), 1 );

    % Search over the grid of possible f0 values
    for nf = 1:length(freqs)

        f0 = freqs(nf);
        
        % Compute the largest number of harmonics allowed, given the
        % Nyquist rate of the data
        nyq = min( order, floor( fs/2 / f0 ) );

        % Commented out by P. Clark - replaced by the Goertzel-filtering
        % approach below.
        % % This is an approximately unitary transform matrix, using only the
        % % complex exponentials with frequencies that are integer multiples
        % % of the hypothesized f0
        % T = exp( j*2*pi*f0/fs*NK ) / sqrt( N );
        %
        % % Compute harmonic coefficients
        % C = T' * data;
        
        % Alternative Goertzel-filtering approach for calculating the inner
        % product with a complex exponential of arbitrary frequency
        % (equivalent to the matrix method deprecated above).
        C = zeros( nyq, 1 );
        for k = 1:nyq
            % b and a are the feed-forward and feedback coefficients of a
            % 2nd order filter with one pole on the unit circle at the kth
            % frequency
            b = [1 -exp(-j*2*pi*k*f0/fs)];
            a = [1 -2*cos(2*pi*k*f0/fs) 1];
            temp = filter( b, a, data );
            C(k) = exp( -j*2*pi*k*f0/fs*( N-1 ) )*temp(end) / sqrt( N );
        end

        amp = abs( C );
        phi = angle( C );

        phi_all(1:nyq,nf) = phi;
        amp_all(1:nyq,nf) = amp;

        % Determine how much energy is captured by the harmonic estimate
        % (the coefficients in C represent the sampled spectrum of the data
        % between -pi and pi, but we will only count the range 0 to pi,
        % assuming the data is real-valued, and scale by 2).
        P( nf ) = 2*norm( weight( 1:nyq ).*C( 1:nyq ) )^2;
    end

    % Select the f0 which describes the data in terms of capturing the most
    % signal energy...
    [maxP index] = max( P );
    f0 = freqs( index );
    phi = phi_all( :, index );
    amp = amp_all( :, index );

    % It should be noted that T is in general not an orthogonal transform,
    % which means that the model error is not orthogonal to the harmonic
    % approximation of the data. This calls into question the above method
    % of maximizing the energy captured by coefficients, since some of that
    % energy may be correlated with the model error. In practice, though,
    % the discrepancy is small and we choose to ignore it, saying that the
    % harmonic basis functions in T are "close enough" to orthogonal.

    % Compute the mean-squared error using the chosen f0
    NK = (0:N-1)' * (1:order);      % the outer-product constructs index matrix
    T = exp( j*2*pi*f0/fs*NK ) / sqrt( N );
    nyq = min( order, floor( fs/2 / f0 ) );
    syn = 2*real( T( :, 1:nyq ) * ( amp(1:nyq).*exp( j*phi(1:nyq) ) ) );
    err = norm( data - syn )^2;

end % End lsharm


% -------------------------------------------------------------------------
function y = factorinterp( x, R, L, cutoff )
% Successively interpolates the vector x by the factors of R, which greatly
% speeds up execution time for large R. Of course, there is an advantage
% only when R is not prime. 2*L is the number of original samples to use in
% each interpolation stage, meaning the interpolation filter is of order
% 2*Rk*L at the kth stage. Cutoff is the presumed bandlimit of x. The
% interp() function will design an interpolating filter with "don't care"
% regions in frequency based on the bandwidth of x.

    factors = factor( R );
    
    y = x;
    
    for i = 1:length( factors )
        y = interp( y, factors( i ), L, cutoff );
    end
    
end % End factorinterp


% -------------------------------------------------------------------------
function [theta1 theta2] = bimodalGaussianMixture( x, numIter, numTrials )
% Returns the parameters for a two-component Gaussian mixture model using
% the iterative Expectation-Maximization algorithm.

    if nargin == 1
        numIter = 25;
        numTrials = 10;
    elseif nargin == 2
        numTrials = 10;
    end
    
    theta1 = [];
    theta2 = [];
    
    N = length( x );
    prevMaxL = -Inf;
    
    % The EM solution is not unique, but with multiple trials we can find
    % the Gaussian mixture that maximizes the likelihood of the observed
    % data.
    for k = 1:numTrials
        % Initial parameters for distribution 1
        mu1 = x( round( (N-1)*rand )+1 );
        sigma1 = var( x );

        % Initial parameters for distribution 2
        mu2 = x( round( (N-1)*rand )+1 );
        sigma2 = var( x );

        % Initial mixing probability
        p = zeros( numIter+1, 1 );
        p(1) = 0.5;
        
        % Expectation-Maximization algorithm for computing the parameters of
        % two Gaussian distributions and the mixing probability of a latent
        % random variable that selects one distribution or the other for each
        % observed sample (assuming independence between samples).
        for i = 1:numIter

            % Compute the likelihood ratio between x(i) belonging to 
            % distribution 1 and x(i) belonging to distribution 1 OR distribution 2
            L1    = p(i)*GaussianLikelihood( x, mu1, sigma1 );
            L1or2 = L1 + (1-p(i))*GaussianLikelihood( x, mu2, sigma2 );
            LR    = L1 ./ L1or2;
            
            % Compute weighted mean estimates (actually the expected values of
            % the PDFs defined by LR and 1-LR)
            mu1 = sum( LR.*x ) / sum( LR );
            mu2 = sum( (1-LR).*x ) / sum( (1-LR) );
            
            % Compute weighted variance estimates (actually the central second
            % moments of the PDFs defined by LR and 1-LR)
            temp1 = sum( LR.*( x - mu1 ).^2 ) / sum( LR );
            temp2 = sum( (1-LR).*( x - mu2 ).^2 ) / sum( (1-LR) );
            
            if temp1 == 0 || temp2 == 0
                % If either of the computed variances is equal to zero,
                % then terminate this trial, using only valid values for p,
                % sigma1, and sigma2 up until the fault (this occurs in the
                % degenerate case when x actually has a unimodal
                % distribution).
                p = p( 1:i );
                break;
            else
                sigma1 = temp1;
                sigma2 = temp2;
            end
            
            % Compute the mixing probability estimate
            p(i+1) = sum( LR ) / N;
        end
        
        % Compute the likelihood of the data given the current estimated
        % Gaussian-mixture model
        L1 = p(end)*GaussianLikelihood( x, mu1, sigma1 );
        L2 = (1-p(end))*GaussianLikelihood( x, mu2, sigma2 );
        L  = sum( log( L1 + L2 ) );
        
        if L > prevMaxL
            prevMaxL = L;
            
            theta1.mu = mu1;
            theta1.sigma = sigma1;
            theta1.p = p(end);

            theta2.mu = mu2;
            theta2.sigma = sigma2;
            theta2.p = 1-p(end);
        end
    end
    
end % end bimodalGaussianMixture


% -------------------------------------------------------------------------
function p = GaussianLikelihood( x, mu, variance )

    p = 1/sqrt( 2*pi*variance )*exp( -( x-mu ).^2 / 2 / variance );

end % end GaussianLikelihood


% -------------------------------------------------------------------------
function xp = percentile( x, p )

    x  = sort( x, 'ascend' );
    xp = x( round( p*(length(x)-1)+1 ) );

end % End percentile


% -------------------------------------------------------------------------
function checkInputs( x, fs, medFiltLen, voicingSensitivity, freqCutoff, display )

    if numel( x ) > length( x )
        error( 'X must be a vector.' )
    end
    
    if numel( fs ) ~= 1 || fs <= 0
        error( 'FS must be a positive real scalar.' )
    end
    
    if numel( medFiltLen ) ~= 1 || mod( medFiltLen, 1 ) ~= 0 || medFiltLen < 1
        error( 'MEDFILTLEN must be a positive integer scalar greater than zero.' )
    end
    
    if numel( voicingSensitivity ) ~= 1 || voicingSensitivity < 0 || voicingSensitivity > 1
        error( 'The voicing sensitivity must be a positive scalar in the interval [0, 1].' )
    end
    
    if numel( freqCutoff ) ~= 1 || freqCutoff <= 0 || freqCutoff > fs/2
        error( 'FREQCUTOFF must be a positive scalar less than or equal to FS/2.' )
    end
    
    if display ~= 0 && display ~= 1
        error( 'DISPLAY must be a boolean value, 0 or 1.' )
    end

end % End checkInputs

