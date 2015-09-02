function x = fromnndata(x,toMatrix,columnSamples,cellTime)
%FROMNNDATA Convert data from standard neural network cell array form.
%
%  FROMNNDATA converts data not formated as neural network data and
%  converts it to that format given arguments defining the whether the
%  result is to be in matrix form, the orientation of sample vectors,
%  and whether matrix columns are to be formated as samples or timesteps.
%
%  <a href="matlab:doc fromnndata">fromnndata</a>(x,toMatrix,columnsample,cellTime) takes two additional arguments,
%    toMatrix - whether to convert final result to matrix. (This may only
%      be true for data with 1 timestep or if cellTime is false. It must
%      be true if cell time is false.)
%    columnSamples - true if samples are to be arranged as matrix columns,
%      or false if they are to be arranged as rows.
%    cellTime - true if timesteps are to be the columns of a cell array,
%      or false if timsteps are arranged in a single matrix. (This may
%      only be false for data with a single time series sample.)
%   and returns Y the converted data.
%
%  Here time-series data is converted from a matrix representation to
%  standard cell array representation , and back. The original data
%  consists of a 5x6 matrix representing one time-series sample
%  consisting of a 5-element vector over 6 timesteps arranged in a matrix
%  with the samples as columns.
%
%    x = <a href="matlab:doc rands">rands</a>(5,6)
%    columnSamples = true; % samples are by columns.
%    cellTime = false; % time-steps represented by a matrix, not cell.
%    [y,wasMatrix] = <a href="matlab:doc tonndata">tonndata</a>(x,columnSamples,cellTime)
%    x2 = <a href="matlab:doc fromnndata">fromnndata</a>(y,wasMatrix,columnSamples,cellTime)
%
%  Here data is defined in standard neural network data cell form.
%  Converting this data does not change it.  The data consists of three
%  time series samples of 2-element signals over 3 timesteps.
%
%    x = {<a href="matlab:doc rands">rands</a>(2,3); <a href="matlab:doc rands">rands</a>(2,3); <a href="matlab:doc rands">rands</a>(2,3)}
%    columnSamples = true;
%    cellTime = true;
%    [y,wasMatrix] = <a href="matlab:doc tonndata">tonndata</a>(x)
%    x2 = <a href="matlab:doc fromnndata">fromnndata</a>(y,wasMatrix,columnSamples)
%
%  See also TONNDATA.

% Copyright 2010-2011 The MathWorks, Inc.

if nargin < 1, error(message('nnet:Args:NotEnough')), end
if nargin < 2, toMatrix = false; end
if nargin < 3, columnSamples = true; end
if nargin < 4, cellTime = true; end

if ~cellTime
  
  if ~toMatrix
    error(message('nnet:fromnndata:ToMatrixNotTrue'))
  end
  if size(x{1,1},2) > 1
    error(message('nnet:fromnndata:CannotConvertMultiSample'))
  end
  x = cell2mat(x);
  if ~columnSamples
    x = x';
  end
  
else
  
  if ~columnSamples
    [r,c] = size(x);
    for i=1:r
      for j=1:c
        xij = x{i,j};
        if ~((islogical(xij) || isnumeric(xij)) && (ndims(xij)==2))
          error(message('nnet:fromnndata:ElementsMustBeMatrix'));
        end
        
        x{i,j} = xij';
      end
    end
  end
  
  if toMatrix
    if size(x,2) > 1
      error(message('nnet:fromnndata:CannotConvertMultiTimestep'));
    end
    x = cell2mat(x);
  end

end

