function x = nndata(elements,samples,timesteps,value)
%NNDATA Create neural network data.
%
%  <a href="matlab:doc nndata">nndata</a> creates data in the cell array data format used by
%  Neural Network Toolbox software.
%
%  Neural network cell data consists of a cell array which has as many rows
%  as there are signals and as many columns as there are timesteps.
%  Each element {i,j} of the cell array is a matrix which has as many rows
%  as the ith signal has elements and as many columns as there are samples.  
%
%  <a href="matlab:doc nndata">nndata</a>(N,Q,TS) returns random neural network data in cell array form.
%  It takes an M-element row vector N of element sizes for M signals,
%  the number of samples Q and number of timesteps TS.  If any of these
%  arguments are not provided their default value is 1.
%
%  The returned value is an MxTS cell array where each {i,ts} element
%  is an N(i)xQ matrix.
%
%  <a href="matlab:doc nndata">nndata</a>(N,Q,TS,V) returns neural network data consisting of the scalar
%  value V.
%
%  Here four samples of five timesteps, for a 2-element signal consisting
%  of zero values is created:
%
%    x = <a href="matlab:doc nndata">nndata</a>(2,4,5,0)
%
%  To create random data with the same dimensions:
%
%    x = <a href="matlab:doc nndata">nndata</a>(2,4,5)
%
%  Here static (1 timestep) data of 12 samples of 4 elements is created.
%
%    x = <a href="matlab:doc nndata">nndata</a>(4,12)
%
%  You can access subsets of neural network data with <a href="matlab:doc getelements">getelements</a>,
%  <a href="matlab:doc getsamples">getsamples</a>, <a href="matlab:doc gettimesteps">gettimesteps</a>, and <a href="matlab:doc getsignals">getsignals</a>.
%
%  You can set subsets of neural network data with <a href="matlab:doc setelements">setelements</a>,
%  <a href="matlab:doc setsamples">setsamples</a>, <a href="matlab:doc settimesteps">settimesteps</a>, and <a href="matlab:doc setsignals">setsignals</a>.
%
%  You can concatenate subsets of neural network data with <a href="matlab:doc catelements">catelements</a>,
%  <a href="matlab:doc catsamples">catsamples</a>, <a href="matlab:doc cattimesteps">cattimesteps</a>, and <a href="matlab:doc catsignals">catsignals</a>.
%
%  See also TONNDATA, FROMNNDATA, NNSIZE.

% Copyright 2010-2012 The MathWorks, Inc.

if nargin < 1, elements = 1; end
if nargin < 2, samples = 1; end
if nargin < 3, timesteps = 1; end
nntype.pos_int_vector('check',elements,'Number of elements');
nntype.pos_int_scalar('check',samples,'Number of samples');
nntype.pos_int_scalar('check',timesteps,'Number of timesteps');

signals = length(elements);
if (nargin < 4) || isempty(value)
  x = cell(signals,timesteps);
  for i=1:signals
    for j=1:timesteps
      x{i,j} = rand(elements(i),samples);
    end
  end
else
  x = cell(signals,1);
  for i=1:signals
    x{i,1} = value + zeros(elements(i),samples);
  end
  x = x(:,ones(1,timesteps));
end
