function s=con2seq(b,ts)
%CON2SEQ Convert concurrent vectors to sequential vectors.
%
%  <a href="matlab:doc con2seq">con2seq</a>(X) takes a matrix of Q column vectors and returns the same
%  vectors as elements of a row cell array.  X can also be a single
%  column cell array of Q column matrices.
%
%  In neural network data terms, this replaces N static of concurrent
%  vectors with N sequential vectors.
%
%  <a href="matlab:doc con2seq">con2seq</a>(X,TS) divides the columns of matrix (or matrices) X evenly
%  into a cell array with TS columns.  If TS is the number of matrix
%  columns this is equivalent to <a href="matlab:doc con2seq">con2seq</a>(x).
%
%  Here three static values are reformatted as a time series.
%
%    x1 = [1 4 2]
%    x2 = <a href="matlab:doc con2seq">con2seq</a>(x1)
%
%  Here the matrices in a column cell array are converted to 2 separate
%  cell array columns.
%
%    x1 = {[1 3 4 5; 1 1 7 4]; [7 3 4 4; 6 9 4 1]}
%    x2 = <a href="matlab:doc con2seq">con2seq</a>(x1,2)
%
%  See also SEQ2CON, CONCUR.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $

% Format & Check
nnassert.minargs(nargin,1);
b = nntype.data('format',b,'B'); % TODO - nntype_static_data
if size(b,2) ~= 1,
  error(message('nnet:NNData:NotStatic'));
end
if nargin < 2, ts = size(b{1},2); end
q1 = size(b{1},2);
q2 = q1/ts;
if (q2 ~= abs(q2))
  error(message('nnet:con2seq:CantDivideMatrixB'));
end

n = size(b,1);
s = cell(n,ts);
for i=1:n
  for j=1:ts
    s{i,j} = b{i}(:,(1:q2)+(j-1)*q2);
  end
end
