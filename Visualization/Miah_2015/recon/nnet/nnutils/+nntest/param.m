function out1 = param(paramInfoArray,parameters)
%TEST_PARAM Test parameters for type and constraints.

% Copyright 2010-2012 The MathWorks, Inc.

  err = do_test(paramInfoArray,parameters);
  if nargout > 0
    out1 = err;
  elseif ~isempty(err)
    nnerr.throw('Parameter',err);
  end
end

function err = do_test(paramInfoArray,parameters)

 if isempty(paramInfoArray)
   err = '';
   return
 end
 
 if ~isstruct(parameters)
   if isa(parameters,'nnetParam')
     parameters = struct(parameters);
   else
     err = 'VALUE is not a parameter structure.';
     return
   end
 end
 
 % Check that parameter fields exist and have correct type
 numParam = length(paramInfoArray);
 for i=1:numParam
    paramInfo = paramInfoArray(i);
    paramName = paramInfo.fieldname;
    if ~isfield(parameters,paramName)
      err = ['VALUE.' paramName ' is not defined.'];
      return
    end
    paramType = paramInfo.type;
    paramValue = parameters.(paramName);
    err = feval(paramType,'check',paramValue);
    if ~isempty(err)
      err = nnerr.value(err,['VALUE.' paramName]);
      return
    end
 end
 
 % Check that there are no extra parameter fields
 fieldNames = fieldnames(parameters);
 numFields = length(fieldNames);
 if numParam < numFields
   paramNames = { paramInfoArray.fieldname };
   for i=1:numFields
     fieldName = fieldNames{i};
     if isempty(nnstring.first_match(fieldName,{'lr','mc','epochs','mu','mu_inc','mu_dec'}))
       % TODO - Remove above exceptions after MBC update
       if strcmp(fieldName,'mem_reduc')
         warning('nnet:Properties',...
           'NET.trainParam.mem_reduc is obsolete. Use NET.efficiency.memoryReduction.');
       elseif isempty(nnstring.first_match(fieldName,{'scale_tol','alpha','beta','delta','gama',...
         'low_lim','up_lim','max_step','min_step','bmax'}))
         if isempty(nnstring.first_match(fieldName,paramNames))
           warning('net:Parameter:IllegalParameter',['''' fieldName ''' is not a legal parameter.']);
           err = '';
           return
         end
       end
     end
   end
 end
 
 err = '';
 
end
