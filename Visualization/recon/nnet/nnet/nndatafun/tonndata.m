function [x,wasMatrix,err] = tonndata(x,columnSamples,cellTime)
%TONNDATA Convert data to standard neural network cell array form.
%
%  <a href="matlab:doc tonndata">tonndata</a> and <a href="matlab:doc fromnndata">fromnndata</a> convert data from and to standard neural
%  network form.
%
%  Standard neural network cell array data consists of a cell array which
%  has as many rows as there are signals and as many columns as there are
%  timesteps. Each i,jth element of the cell array is a matrix which has
%  as many rows as the ith signal has elements and as many columns as
%  there are samples.
%
%  [Y,wasMatrix] = <a href="matlab:doc tonndata">tonndata</a>(x,columnSamples,cellTime) takes matrix or cell
%  array data X and converts it to standard neural network cell data Y. 
%  
%  If columnSamples is false, then matrix X or matrices in cell array X
%  will be transposed, so row samples will now be stored as column vectors.
%
%  If cellTime is false, then matrix samples will be separated into columns
%  of a cell array so time originally represented as vectors in a matrix
%  will now be represented as columns of a cell array.
%
%  The returned value wasMatrix can be used by FROMNNDATA to reverse the
%  transformation.
%
%  Here data consisting of six timesteps of 5-element vectors is originally
%  represented as a matrix with six columns is converted to standard
%  neural network representation and back.
%
%    x = rand(5,6)
%    [y,wasMatrix] = <a href="matlab:doc tonndata">tonndata</a>(x,true,false)
%    x2 = <a href="matlab:doc fromnndata">fromnndata</a>(y,wasMatrix,columnSamples,cellTime)
%
%  Here data is defined in standard neural network data cell form.
%  Converting this data does not change it.  The data consists of three
%  time series samples of 2-element signals over 3 timesteps.
%
%  See also FROMNNDATA

% Copyright 2010 The MathWorks, Inc.

if nargin < 1,error(message('nnet:Args:NotEnough'));end
if nargin < 2, columnSamples = true; end
if nargin < 3, cellTime = true; end
nntype.bool_scalar('check',columnSamples,'Argument columnSamples');
nntype.bool_scalar('check',cellTime,'Argument cellTime');

wasMatrix = ~iscell(x);
if wasMatrix
  if ~columnSamples
    x = x';
  end
  if ~cellTime
    x = con2seq(x);
  else
    x = {x};
  end
else
  if ~columnSamples
    for i=1:numel(x)
      x{i} = x{i}';
    end
  end
  if ~cellTime
    numSignals = size(x,1);
    y = cell(numSignals,1);
    for i=1:numSignals
      y{i} = [x{i,:}];
    end
    numTimesteps = size(y{1},2);
    x = cell(numSignals,numTimesteps);
    for i=1:numSignals
      x{i,:} = con2seq(y{i});
    end
  end
end

[x,err] = nntype.data('format',x);
if ~isempty(err),nnerr.throw('Args',nnerr.value(err,'Transformed X')); end
