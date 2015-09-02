function display(net)
%DISPLAY Display the name and properties of a neural network variable.
%
%  <a href="matlab:doc display">display</a>(NET) display's a network's properties, including variable
%  name, at the command line.
%
%  Here a network is created and displayed.
%
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    <a href="matlab:doc display">display</a>(net)
%
%  See also DISP, SIM, INIT, TRAIN, ADAPT, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.7.4.5 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');
if (isLoose), fprintf('\n'), end
fprintf('%s =\n',inputname(1));
if (isLoose), fprintf('\n'), end
disp(net,inputname(1))
