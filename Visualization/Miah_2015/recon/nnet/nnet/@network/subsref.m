function [v,out2,out3]=subsref(vin,subscripts)
%SUBSREF Reference fields of a neural network.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.7.4.9 $

% Assume no error
err = '';

% Evaluate network
if isa(vin,'network') && strcmp(subscripts(1).type,'()')
   subs = subscripts(1).subs;
   switch nargout
     case 3, [v,out2,out3] = sim(vin,subs{:});
     case 2, [v,out2] = sim(vin,subs{:});
     otherwise, v = sim(vin,subs{:});
   end
   return
end

% Call method
if subscripts(1).type == '.'
  subs1 = subscripts(1).subs;
  if nnstring.first_match(subs1,...
      {'adapt','configure','gensim','init',...
      'perform','sim','train','view','unconfigure'})
    if length(subscripts) == 1
      feval(subs1,vin);
    else
    end
    return
  end
end
v = vin;

% Short hand fields
%type = subscripts(1).type;
%subs = subscripts(1).subs;

% For each level of subscripts
numSubscripts = length(subscripts);
lastFieldSubs = '';
lastV = [];
for i=1:numSubscripts

  type = subscripts(i).type;
  subs = subscripts(i).subs;
  last = (i == numSubscripts);
  
  switch type
  
  % Parentheses
  case '()'
    try
      eval('v=v(subs{:});');
    catch me
      err = me.message;
    end
  
  % Curly bracket
  case '{}'
    try
      eval('v=v{subs{:}};');
      if last
        if nnstring.ends(lastFieldSubs,'params')
          f = lastV.([lastFieldSubs(1:(end-6)) 'Fcns']);
          eval('f=f{subs{:}};');
          v = nnetParam(f,v);
        else
          switch lastFieldSubs
            case 'inputs', v = nnetInput(v);
            case 'layers', v = nnetLayer(v);
            case 'outputs', v = nnetOutput(v);
            case 'biases', if ~isempty(v), v = nnetBias(v); end
            case 'inputWeights', if ~isempty(v), v = nnetWeight(v); end
            case 'layerWeights', if ~isempty(v), v = nnetWeight(v); end 
          end
        end
      end
    catch me
      err = me.message;
    end
  
  % Dot
  case '.'
    % NNET 5.0 Compatibility
    if strcmpi(subs,'numTargets')
      subs = 'numOutputs';
      nnerr.obs_use(mfilename,'"numTargets" is obsolete.',...
        'Use "numOutputs" to determine numbers of outputs and targets.');
    elseif strcmpi(subs,'targetConnect')
      subs = 'outputConnect';
      nnerr.obs_use(mfilename,'"targetConnect" is obsolete.',...
        'Use "outputConnect" to determine connections for outputs and targets.');
    elseif strcmpi(subs,'targets')
      subs = 'outputs';
      nnerr.obs_use(mfilename,'"targets" is obsolete.',...
        'Use "outputs" to determine properties of outputs and targets.');
    end
      
    if isa(v,'cell')
      if nn_iscellstruct_field(v,subs)
        v = nn_cellstruct_select(v,subs);
        moresubs = subscripts(i+1:end);
        if ~isempty(moresubs)
          for j=1:numel(v)
            v{j} = subsref(v{j},moresubs);
          end
        end
        return
      end
    end
    
    if isa(v,'struct') || isa(v,'network')
      subs = matchfield(subs,v);
    end

    %try
      if ~last
        lastFieldSubs = subs;
        lastV = v;
        v = v.(subs);
      elseif nnstring.ends(subs,'Param')
        f = v.([subs(1:(end-5)) 'Fcn']);
        v = v.(subs);
        v = nnetParam(f,v);
      elseif nnstring.ends(subs,'Params')
        f = v.([subs(1:(end-6)) 'Fcns']);
        v = v.(subs);
        for k=1:numel(v), v{k} = nnetParam(f{k},v{k}); end
      elseif nnstring.ends(subs,'Settings')
        nextV = v.(subs);
        if iscell(nextV)
          f = v.([subs(1:(end-8)) 'Fcns']);
          v = nextV;
          for k=1:numel(v), v{k} = nnetSetting(f{k},v{k}); end
        else
          f = v.([subs(1:(end-8)) 'Fcn']);
          v = nextV;
          v = nnetSetting(f,v);
        end
      else
        switch (subs)
          case 'inputs'
            v = v.(subs);
            for k=1:numel(v), v{k} = nnetInput(v{k}); end
          case 'layers'
            v = v.(subs);
            for k=1:numel(v), v{k} = nnetLayer(v{k}); end
          case 'outputs'
            v = v.(subs);
            for k=1:numel(v), if ~isempty(v{k}),v{k} = nnetOutput(v{k}); end, end
          case 'biases'
            v = v.(subs);
            for k=1:numel(v), if ~isempty(v{k}),v{k} = nnetBias(v{k}); end, end
          case 'inputWeights'
            v = v.(subs);
            for k=1:numel(v), if ~isempty(v{k}),v{k} = nnetWeight(v{k}); end, end
          case 'layerWeights'
            v = v.(subs);
            for k=1:numel(v), if ~isempty(v{k}),v{k} = nnetWeight(v{k}); end, end
          otherwise
            v = v.(subs);
        end
      end
      
    %catch me
    %  err = me.message;
    %end
  end
  
  % Error message
  if ~isempty(err)
    
    % Work around: remove any reference to variable V
    ind = strfind(err,' ''v''');
    if (ind)
      err(ind+(0:3)) = [];
    end
    
  nnerr.throw('Args',err)
  end
end

function field = matchstring(field,strings)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

for i=1:length(strings)
  if strcmpi(field,strings{i})
    field = strings{i};
    return;
  end
end
field = [];

function field = matchfield(field,structure)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

field = matchstring(field,fieldnames(structure));
