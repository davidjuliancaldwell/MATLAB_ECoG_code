function [out1,out2,out3,out4,out5,out6] = srchcha(varargin)
%SRCHCHA One-dimensional minimization using the method of Charalambous.
%
%  <a href="matlab:doc srchcha">srchcha</a> is a linear search routine.  It searches in a given direction
%   to locate the minimum of the performance function in that direction.
%   It uses a technique based on the method of Charalambous.
%
%  Search functions are not commonly called directly.  They are called
%  by training functions.
%
%  <a href="matlab:doc srchcha">srchcha</a>(NET,X,P,Pd,Tl,Ai,Q,TS,dX,gX,PERF,DPERF,DELTA,TOL,CH_PERF)
%    NET     - Neural network.
%    X       - Vector containing current values of weights and biases.
%    P       - Processed inputs.
%    Pd      - Delayed input vectors.
%    Ai      - Initial input delay conditions.
%    Tl      - Layer target vectors.
%    EW      - Error weights.
%    Q       - Batch size.
%    TS      - Time steps.
%    dX      - Search direction vector.
%    gX      - Gradient vector.
%    PERF    - Performance value at current X.
%    DPERF   - Slope of performance value at current X in direction of dX.
%    DELTA   - Initial step size.
%    TOL     - Tolerance on search.
%    CH_PERF - Change in performance on previous step.
%  and returns,
%    A       - Step size which minimizes performance.
%    gX      - Gradient at new minimum point.
%    PERF    - Performance value at new minimum point.
%    RETCODE - Return code which has three elements. The first two elements 
%              correspond to the number of function evaluations in the two
%              stages of the search.  The third element is a return code.
%              These will have different meanings for different search 
%              algorithms. Some may not be used in this function.
%                0 - normal; 1 - minimum step taken; 2 - maximum step taken;
%                3 - beta condition not met.
%    DELTA   - New initial step size. Based on the current step size.
%    TOL     - New tolerance on search.
%
%  Parameters used for the Charalombous algorithm are:
%    alpha     - Scale factor which determines sufficient reduction in perf.
%    beta      - Scale factor which determines sufficiently large step size.
%    gama      - Parameter to avoid small reductions in performance. Usually 
%                 set to 0.1.
%    scale_tol - Parameter which relates the tolerance tol to the initial step
%                 size delta. Usually set to 20.
%
%  Dimensions for these variables are:
%    Pd - NoxNixTS cell array, each element P{i,j,ts} is a DijxQ matrix.
%    Tl - NlxTS cell array, each element P{i,ts} is an VixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%  Where
%    Ni = net.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>
%    LD = net.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Vi = net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%    Dij = Ri * length(net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>)
%
%  Here a feed-forward network is trained with the <a href="matlab:doc traincgf">traincgf</a> training
%  function and this search function.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(20,'traincgf');
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.searchFcn">searchFcn</a> = '<a href="matlab:doc srchcha">srchcha</a>';
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x)
%
%  See also SRCHBAC, SRCHBRE, SRCHGOL, SRCHHYB

% Copyright 1992-2012 The MathWorks, Inc.
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% $Revision: 1.1.6.13 $ $Date: 2012/04/20 19:13:59 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Search Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me,
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [out1,out2,out3,out4,out5,out6] = do_search(varargin{:});
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnSearch(mfilename,'Charalambous One-Dimensional Minimization',fcnversion);
end

function [a,gX,perf,retcode,delta,tol] = ...
    do_search(calcLib,calcNet,dX,gX,perf,dperf,delta,tol,ch_perf,param,~,~)

% Parallel Workers
isParallel = calcLib.isParallel;
isMainWorker = calcLib.isMainWorker;
mainWorkerInd = calcLib.mainWorkerInd;

% Create broadcast variables
a = [];
retcode = [];
X_temp = [];
NaNFlag = [];
whileStop = [];

if isMainWorker
    if (nargin < 1), error(message('nnet:Args:NotEnough')); end
    if ischar(calcNet)
      switch(calcNet)
        case 'name'
          a = 'One-Dimensional Interval Location w-Charalambous''s Method';
        otherwise, nnerr.throw(['Unrecognized code: ''' calcNet ''''])
      end
      return
    end

    % ALGORITHM PARAMETERS
    X = calcLib.getwb(calcNet);
    scale_tol = param.scale_tol;
    alpha = param.alpha;
    beta = param.beta;
    gama = param.gama;
    gama1 = 1 - gama;
    % We need the following parameters to avoid very small increasing steps
    minstep = param.min_step;

    % Parameter Checking
    if (~isa(scale_tol,'double')) | (~isreal(scale_tol)) | (any(size(scale_tol)) ~= 1) | ...
      (scale_tol <= 0)
      error(message('nnet:ObsErr:ScaleNotPos'))
    end
    if (~isa(alpha,'double')) | (~isreal(alpha)) | (any(size(alpha)) ~= 1) | ...
      (alpha < 0) | (alpha > 1)
      error(message('nnet:srchcha:Alpha'))
    end
    if (~isa(beta,'double')) | (~isreal(beta)) | (any(size(beta)) ~= 1) | ...
      (beta < 0) | (beta > 1)
      error(message('nnet:srchcha:Beta'))
    end
    if (~isa(gama,'double')) | (~isreal(gama)) | (any(size(gama)) ~= 1) | ...
      (gama < 0) | (gama > 1)
      error(message('nnet:srchcha:Gama'))
    end

    % STEP SIZE INCREASE FACTOR FOR INTERVAL LOCATION 
    scale = 3;

    % INITIALIZE
    a = 0;
    perfa = perf;
    dperfa = dperf;
    cnt1 = 0;
    cnt2 = 0;

    % FIND FIRST STEP SIZE
    % delta_star must be always positive
    delta_star = abs(-2*ch_perf/dperf);
    delta = max([delta delta_star]);
    b = delta;

    % CALCULATE PERFORMANCE, GRADIENT AND SLOPE AT POINT B
    X_temp = X + b*dX;
end
    
calcNet_temp = calcLib.setwb(calcNet,X_temp);
perfb = calcLib.trainPerf(calcNet_temp);
gX_b = -calcLib.grad(calcNet_temp);

if isMainWorker
    dperfb = gX_b'*dX;
    cnt1 = cnt1 + 1;
end

% If perfb is NaN we return, also dperfb
if isMainWorker, NaNFlag = (~isnan(perfb) && ~isnan(dperfb)); end
if isParallel, NaNFlag = labBroadcast(mainWorkerInd,NaNFlag); end
if NaNFlag
  if isMainWorker
      if (perfa < perfb)
        amin = a; minperf = perfa; dperfmin = dperfa; gX_1 = gX;
      else
        amin = b; minperf = perfb; dperfmin = dperfb; gX_1 = gX_b;
      end

      bma = b - a;
  end
  % LOCATE THE MINIMUM POINT BY THE CHARALAMBOUS METHOD
  while true
    if isMainWorker, whileStop = ~(((bma)>tol) && (perfb~=perfa) && ((minperf > perf + alpha*amin*dperf) || abs(dperfmin)>abs(beta*dperf) ) && cnt2<100); end
    if isParallel, whileStop = labBroadcast(mainWorkerInd,whileStop); end
    if whileStop, break; end
  
    % IF THE SLOPE AT B IS NEGATIVE INCREASE OR DECREASE THE STEP SIZE BY SCALE
    % We check we are above minimum step
    if isMainWorker
        if (dperfb < 0) && (delta > minstep)
          % IF FUNCTION IS HIGHER, DECREASE STEP SIZE BY SCALE
          if (perfb > perfa)
            delta = delta/scale;
          % IF FUNCTION IS LOWER, CHANGE THE A POINT AND INCREASE THE STEP SIZE BY SCALE
          else
            delta = scale*delta;
          end
          % IF THE SLOPE AT B IS POSITIVE DO A CUBIC INTERPOLATION FOR THE MINIMUM
        else
          ww = 3*(perfa - perfb)/(b-a) + dperfa + dperfb;
          w_gagb = ww^2 - dperfa*dperfb;
          v = sqrt(w_gagb);
          denom_delta = (dperfb - dperfa +2*v);
          if denom_delta==0,
            delta =  max( [gama*bma gama1*bma] );
          else
            delta_star =  (b-a)*(1 - (dperfb + v - ww)/denom_delta);
            delta = max( [gama*bma min( [delta_star gama1*bma] )] );
          end
        end

        % CALCULATE PERFORMANCE AND SLOPE AT TEST POINT
        b_test = a + delta;
        X_temp = X + b_test*dX;
    end
    calcNet_temp = calcLib.setwb(calcNet,X_temp); 
    perfbt = calcLib.trainPerf(calcNet_temp);
    gX_temp = -calcLib.grad(calcNet_temp);
    if isMainWorker
        dperfbt = gX_temp'*dX;
        cnt2 = cnt2 + 1;  
        % USE TEST POINT TO UPDATE ENDPOINTS
        if (b_test > b)
          a = b; perfa = perfb; dperfa = dperfb; gX = gX_b;
          b = b_test; perfb = perfbt; dperfb = dperfbt; gX_b = gX_temp;
        else
          if (dperfbt > 0) || (perfbt > perfa)
            b = b_test; perfb = perfbt; dperfb = dperfbt; gX_b = gX_temp;
          else
            a = b_test; perfa = perfbt; dperfa = dperfbt; gX = gX_temp;
          end
        end

        bma = b - a;

        % FIND THE MINIMUM POINT
        if (perfa < perfb)
          amin = a; minperf = perfa; dperfmin = dperfa; gX_1 = gX;
        else
          amin = b; minperf = perfb; dperfmin = dperfb; gX_1 = gX_b;
        end
    end
  end
else
   if isMainWorker
       minperf=perfa;
       amin=a;
       gX_1 = gX;
   end
end	% END of ~isnan(perfb)
  
if isMainWorker
    a = amin;
    perf = minperf;
    gX = gX_1;

    % CHANGE INITIAL STEP SIZE TO PREVIOUS STEP
    delta=amin;
    if delta < param.delta
      delta = param.delta;
    end

    % We always update the tolerance.
    tol=delta/scale_tol;
    retcode = [cnt1 cnt2 0];
end
end
