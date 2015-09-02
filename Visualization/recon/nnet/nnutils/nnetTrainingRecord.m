function tr = nnetTrainingRecord(net)

% Copyright 2010 The MathWorks, Inc.

  tr.trainFcn = net.trainFcn;
  tr.trainParam = net.trainParam;
  tr.performFcn = net.performFcn;
  tr.performParam = net.performParam;
  tr.derivFcn = net.derivFcn;
  tr.divideFcn = net.divideFcn;
  tr.divideMode = net.divideMode;
  tr.divideParam = net.divideParam;
  tr.trainInd = [];
  tr.valInd = [];
  tr.testInd = [];
  tr.stop = '';
  tr.num_epochs = -1;
  
end
