function flag = is_text_ext(ext)

% Copyright 2010-2012 The MathWorks, Inc.

if ~isempty(ext) && (ext(1) == '.')
  ext(1) = [];
end

flag = ~isempty(nnstring.first_match(ext,...
  {'csv','ixf','java','m','mdl','m_template','mtf','phl','txt','xml','cpp','cu','h','xml','ptx'}));
