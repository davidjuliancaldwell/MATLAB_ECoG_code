function result = ntstool(command,varargin)
%NFTool Neural Network Time Series Tool
%
%  Syntax
%    
%    ntstool
%    ntstool('close')
%    
%  Description
%    
%    NTSTOOL launches the neural network time series wizard and leads
%    the user through solving a fitting problem using a two-layer
%    feed-forward network.
%
%    NFTOOL('close') closes the window.

% Copyright 2007-2011 The MathWorks, Inc.

if (nargin==1) && ischar(command) && strcmp(command,'info')
  result = nnfcnWizard(mfilename,'Time Series',7.0);
  return
end

if nargout > 0, result = []; end

persistent STATE;
if isempty(STATE)
  mlock
  STATE.tool = nnjava.tools('ntstool');
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

    otherwise
      nnerr.throw(['Unrecognized command: ' command]);
  end
catch me
  errmsg = me.message;
  errmsg(errmsg<32) = ',';
  errmsg = nnjava.tools('string',errmsg);
  result = nnjava.tools('error',errmsg);
end
