function data = formatData(data,hints)

% Copyright 2012 The MathWorks, Inc.

for i=1:numel(data.X)
  data.X{i} = double(data.X{i});
end

for i=1:numel(data.Xi)
  data.Xi{i} = double(data.Xi{i});
end

for i=1:numel(data.Ai)
  data.Ai{i} = double(data.Ai{i});
end

if isfield(data,'T')
  for i=1:numel(data.T)
    data.T{i} = double(data.T{i});
  end
end

if isfield(data,'EW')
  for i=1:numel(data.EW)
    data.EW{i} = double(data.EW{i});
  end
  
  % If either X or EW have non-one Q*TS then expand EW
  % so it matches the dimensions of batched targets and outputs:
  %   Tb = [T{i,:}]
  %   Yb = output_processed([A{i,:}])
  QTS = data.Q*data.TS;
  QTSew = hints.Q_EW*hints.TS_EW;
  if (QTS ~= QTSew) && (QTSew ~= 1)
    EW = cell(hints.M_EW,data.TS);
    for i=1:hints.M_EW
      for ts=1:data.TS
        if (hints.TS_EW == 1)
          EW{i,ts} = data.EW{i,1};
        else
          EW{i,ts} = repmat(data.EW{i,ts},1,data.Q);
        end
      end
    end
    data.EW = EW;
  end
end

