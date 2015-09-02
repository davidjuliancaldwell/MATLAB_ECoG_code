function result = nnstart()
%NNSTART Neural Network Start GUI

% Copyright 2010 The MathWorks, Inc.

if nargout > 0, result = []; end

persistent STATE;
if isempty(STATE)
  STATE.tool = nnjava.tools('nnstart');
end
  
try
  if (nargout > 0), result = []; end
  if nargin == 0, command = 'select'; end
  switch command

    case {'handle','tool'}
      if nargout > 0
        result = STATE.tool;
      end

    case 'select',
      launch(STATE.tool);
      if nargout > 0
        result = STATE.tool;
      end
      
    case {'hide','close'}
      if usejava('swing')
        STATE.tool.setVisible(false);
      end

    case 'state', result = STATE;
  end
  
catch me
  errmsg = me.message;
  errmsg(errmsg<32) = ',';
  errmsg = nnjava.tools('string',errmsg);
  result = nnjava.tools('error',errmsg);
end
