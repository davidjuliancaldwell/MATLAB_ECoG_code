function gE2 = dperf(net,A,gE1,Q,hints)
%PROCESSOUTPUTDERIV

% Copyright 2007-2012 The MathWorks, Inc.

TS = size(A,2);
gE2 = cell(size(gE1));
for i=1:net.numLayers
  if ~net.outputConnect(i) || isempty(net.outputs{i}.processFcns)
    gE2(i,:) = gE1(i,:);
  else
    
    % Only calculate for active processing functions
    ii = hints.layer2output(i);
    pfcns = nnproc.active_fcns(hints.outputs(ii).process);
    numPF = length(pfcns);
    
    for ts=1:TS
      AA = cell(1,numPF+1);
      AA{1} = A{i,ts};
      
      % Reverse calculate values, to use for derivates
      % TODO - precalculate these
      for j=1:numPF
        processFcn = pfcns(numPF+1-j);
        AA{j+1} = processFcn.reverse(AA{j},processFcn.settings);
      end
      
      % Calculate derivatives
      ge1 = gE1{i,ts};
      for j=numPF:-1:1
        processFcn = pfcns(numPF+1-j);
        ge2 = zeros(processFcn.settings.yrows,Q);
        dpf = processFcn.dx_dy(AA{j+1},AA{j},processFcn.settings);
        for q=1:Q
          ge2(:,q) = dpf{q}' * ge1(:,q);
        end
        ge1 = ge2;
      end
      gE2{i,ts} = ge1;
    end
  end
end
