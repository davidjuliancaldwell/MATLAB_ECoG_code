function [trainData,valData,testData] = divide_data(data)

% Copyright 2010-2012 The MathWorks, Inc.

if data.train.all
  trainData = data;
  valData = [];
  testData = [];
else
  trainData = nncalc.split_data(data,data.train.sampleMask);
  valData = nncalc.split_data(data,data.val.sampleMask);
  testData = nncalc.split_data(data,data.test.sampleMask);
end
