function varargout = defaults(args,varargin)
%NNDEFAULTS Replaces undefined arguments with default values.
%
%  [A1,A2,...,AN] = NNDEFAULTS(ARGS,V1,V2,...,VN) sets A1 to
%  ARGS{1}, A2 to ARGS{2}, etc., for as many elements as are in ARGS.
%  After that Ai = Vi, etc.

% Copyright 2010 The MathWorks, Inc.

nargs = length(varargin);
varargout = cell(1,nargs);
for i=1:length(args)
  varargout{i} = args{i};
end
for i=(length(args)+1):nargs
  varargout{i} = varargin{i};
end
