function flag = is_text_file(file)

% Copyright 2010-2011 The MathWorks, Inc.

name = nnpath.name(file);
flag = ~isempty(nnstring.first_match(name,...
  {'Makefile','TEST_LIST','chart','JAVA_LIST','MAKEFILE_LIST',...
  'DEPENDS.pcode'}));
