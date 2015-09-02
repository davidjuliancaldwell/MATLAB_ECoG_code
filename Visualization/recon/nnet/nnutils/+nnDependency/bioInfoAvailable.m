function flag = available()
%AVAILABLE True if Bioinformatics Toolbox is installed and licensed

% Copyright 2010-2012 The MathWorks, Inc.

flag = ~isempty(ver('bioinfo')) && license('test','Bioinformatics_Toolbox');
