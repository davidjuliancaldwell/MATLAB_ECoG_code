function str = objs2str(objs,type,netname,fieldname)

% Copyright 2010 The MathWorks, Inc.

type = lower(type(5:end));
if strcmp(type,'bias')
  plural = 'biases';
else
  plural = [type 's'];
end
  
[r,c] = size(objs);
a = active(objs);
if (a ~= 1), type = plural; end
  
rstr = num2str(r);
cstr = num2str(c);
astr = num2str(a);
str = ['{' rstr 'x' cstr ' cell array of ' astr ' ' type '}'];

%if (nargin > 2) && ~isempty(netname)
%  code = ['matlab: nndisp.' lower(fieldname) '(' netname ',''' netname ''');'];
%  str = nnlink.str2link(str,code);
%end


function n = active(x)
n = 0;
for i=1:numel(x)
  if ~isempty(x{i}), n = n + 1; end
end

