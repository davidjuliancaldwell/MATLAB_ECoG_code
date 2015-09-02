function gloveTrace = CreateSmoothGloveTrace(states, parameters, method)
% function [gloveTrace] = CreateSmoothGloveTrace(states, parameters, method)
%
% Changelog
%   8/11/11 - tmb - originally written
%   6/16/21 - jdw - changed to accept multiple cyberglove states naming
%   conventions
%
% Simple function to take in the states and parameter structure from
% BCI2000 and use a spline to interpolate the stairstepped glove trace.
%
% states - the bci2k state struct
% parameters - the bci2k parameters structure
% method - 'spline' or 'pchip', which is the piecewise cubic Hermite
% interpolation. Slightly less organic than the spline, but avoids the
% flat-step-flat artifacts that occur with splines

if isstruct(parameters.SamplingRate) == 1
    params = CleanBCI2000ParamStruct(parameters);
else
    params = parameters;
end

if (isfield(states, 'rCyber1'))
    prefix = 'r';
elseif (isfield(states, 'lCyber1'))
    prefix = 'l';
else
    prefix = '';
end

for i=1:22
    eval(sprintf('gloveTrace(:,i) = double(states.%sCyber%i);',prefix,i));
    zeroPeriod = find(gloveTrace(:,i) > 0, 1, 'first')-1;
    gloveTrace(1:zeroPeriod,i) = gloveTrace(zeroPeriod+1,i);

%     gloveTrace(:,i) =
%     spline(1:params.SampleBlockSize:length(gloveTrace(:,i)),gloveTrace(1:params.SampleBlockSize:end,i),1:length(gloveTrace(:,i)));
    gloveTrace(:,i) = interp1(1:params.SampleBlockSize:length(gloveTrace(:,i)),gloveTrace(1:params.SampleBlockSize:end,i),1:length(gloveTrace(:,i)),method);
end