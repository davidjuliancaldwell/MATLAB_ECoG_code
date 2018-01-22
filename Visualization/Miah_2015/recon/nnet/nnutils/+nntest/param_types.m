function [out1,out2] = param_types(paramInfoArray,param)
%PARAM_TYPES Test parameter field types.

% Copyright 2010 The MathWorks, Inc.

  [err,param] = do_test(paramInfoArray,param);
  if nargout > 0
    out1 = err;
    if nargout > 1, out2 = param; end
  elseif ~isempty(err)
    nnerr.throw('Type',err,'Parameters');
  end
end

function [err,param] = do_test(paramInfoArray,param)

 if isempty(paramInfoArray)
   err = '';
   return
 end
 
 if ~isstruct(param)
   if isa(param,'nnetParam')
     param = struct(param);
   else
     err = 'VALUE is not a parameter structure.';
     return
   end
 end
 
 for i=1:length(paramInfoArray)
    paramInfo = paramInfoArray(i);
    paramName = paramInfo.fieldname;
    if ~isfield(param,paramName)
      err = ['VALUE.' paramName ' is not defined.'];
      return
    end
    paramType = paramInfo.type;
    paramValue = param.(paramName);
    [param.(paramName),err] = feval(paramType,'format',paramValue);
    if ~isempty(err)
      err = nnerr.value(err,['VALUE.' paramName]);
      return
    end
 end
 err = '';
 
end
