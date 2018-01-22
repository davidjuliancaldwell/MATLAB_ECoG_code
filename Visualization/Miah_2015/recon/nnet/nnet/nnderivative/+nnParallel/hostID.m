function id = hostID

% Copyright 2012 The MathWorks, Inc.

% 
savedir = cd;
cd(tempdir);
[fail,id] = system('hostname');
cd(savedir);

if (fail)
  id = '';
else
  id(id<' ') = [];
  id(id==' ') = '_';
end
