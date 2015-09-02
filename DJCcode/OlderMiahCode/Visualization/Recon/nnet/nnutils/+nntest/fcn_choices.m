function fcns = fcn_choices(fcns)

% Copyright 2010-2012 The MathWorks, Inc.

persistent FCNS
if ~isempty(FCNS)
  fcns = FCNS;
  return,
end

% Layer Initialization Functions
fcns.initLayerFcns = nnpath.file2fcn(nnfile.mfiles(fullfile(nnpath.nnet_toolbox,'nnet','nninitlayer')));
fcns.initLayerFcns(nnstring.first_match('Contents',fcns.initLayerFcns)) = [];

% Weight/Bias Initialization Functions
initWeightFcns = nnfcn.siblings('rands');
fcns.initBiasFcns = initWeightFcns;
fcns.initInputWeightFcns = initWeightFcns;
fcns.initLayerWeightFcns = initWeightFcns;
for i=length(initWeightFcns):-1:1
  if ~feval(initWeightFcns{i},'initBias')
    fcns.initBiasFcns(i) = [];
  end
  if ~feval(initWeightFcns{i},'initInputWeight')
    fcns.initInputWeightFcns(i) = [];
  end
  if ~feval(initWeightFcns{i},'initLayerWeight')
    fcns.initLayerWeightFcns(i) = [];
  end
end

% Forward Tap Delay Mode
fcns.forwardDelayFcns = { ...
  inline('0:n')
  inline('1:max(1,n)')
  inline('n')
  inline('unique([1 n])')
  inline('find((rand(1,n)>0.5) | compet(rand(n,1))'')')
  };
fcns.feedbackDelayFcns = {
  inline('1:n')
  inline('n')
  inline('unique([1 n])')
  inline('find((rand(1,n)>0.5) | compet(rand(n,1))'')')
  };

FCNS = fcns;
