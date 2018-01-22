%Normalization (normalization) function parameter
%
%  <a href="matlab:doc nnparam.normalization">normalization</a> is a <a href="matlab:doc nnperformance">performance function</a> parameter.
%  It must be 'none', 'standard' or 'percent'.
%
%  <a href="matlab:doc nnparam.normalization">normalization</a> is the kind of error normalization relative to%
%  target ranges.
%
%  If it is set to 'none' then the error is used unchanged.
%
%  If it is set to 'standard' then errors are mapped to the range [-2,2]
%  which is the result of mapping output and target ranges to [-1,1]
%  relative to the ranges of the original target data.
%
%  If it is set to 'percent' then percentage errors are used, relative to
%  the ranges of the original target data, and errors will be mapped to
%  the range [-1,1].
%
%  This parameter is used by <a href="matlab:doc mae">mae</a>, <a href="matlab:doc mse">mse</a>, <a href="matlab:doc sae">sae</a> and <a href="matlab:doc sse">sse</a>.
 
