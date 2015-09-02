function net = revert(net)
%REVERT Revert network weight and bias values.
%
%  <a href="matlab:doc revert">revert</a>(NET) returns neural network NET with weight and bias values
%  restored to the values generated the last time the network was
%  initialized.
%
%  If the network has been altered so that it has different weight
%  and bias connections or different input or layer sizes, then REVERT
%  cannot set the weights and biases to their previous values and they
%  will be set to zeros instead.
%
%  Here a feedforward network is created, configured and initialized.
%  After training has altered the wieghts and biases, the original
%  initial values are reverted to.
%
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc configure">configure</a>(net,x,t);
%    net = <a href="matlab:doc init">init</a>(net);
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{1}
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{1}
%    net = <a href="matlab:doc revert">revert</a>(net)
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{1}
%
%  See also INIT, SIM, ADAPT, TRAIN.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.5.4.2 $  $Date: 2010/07/16 19:33:49 $

% Convert network to structure
net = struct(net);

% Are stored revert values ok?
ok = 1;
if ~all(size(net.revert.IW) == size(net.IW))
  ok = 0;
elseif ~all(size(net.revert.LW) == size(net.LW))
  ok = 0;
elseif ~all(size(net.revert.b) == size(net.b))
  ok = 0;
else
  for i=1:size(net.IW,1)
    for j=1:size(net.IW,2)
      if ~all(size(net.revert.IW{i,j}) == size(net.IW{i,j}))
        ok = 0;
      end
    end
  end
  for i=1:size(net.LW,1)
    for j=1:size(net.LW,2)
      if ~all(size(net.revert.LW{i,j}) == size(net.LW{i,j}))
        ok = 0;
      end
    end
  end
  for i=1:size(net.b,1)
    if ~all(size(net.revert.b{i}) == size(net.b{i}))
      ok = 0;
    end
  end
end

% If OK, revert values
if ok
  net.IW = net.revert.IW;
  net.LW = net.revert.LW;
  net.b = net.revert.b;
  
% Otherwise, set to zeros
else
  for i=1:size(net.IW,1)
    for j=1:size(net.IW,2)
      net.IW{i,j} = zeros(size(net.IW{i,j}));
    end
  end
  for i=1:size(net.LW,1)
    for j=1:size(net.LW,2)
      net.LW{i,j} = zeros(size(net.LW{i,j}));
    end
  end
  for i=1:size(net.b,1)
    net.b{i} = zeros(size(net.b{i}));
  end
end

% Convert network back to object
net = class(net,'network');
