function x = nn_new_input_struct

% Copyright 2011 The MathWorks, Inc.

x.name = 'Input';
x.feedbackOutput = [];
x.processFcns = cell(1,0);
x.processParams = cell(1,0);
x.processSettings = cell(1,0);
x.processedRange = zeros(0,2);
x.processedSize = 0;
x.range = zeros(0,2);
x.size = 0;
x.userdata.note = 'Put your custom input information here.';
% NNET 6.0 Compatibility
x.exampleInput = [];
