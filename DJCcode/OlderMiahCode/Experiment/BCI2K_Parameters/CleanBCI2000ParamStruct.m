function params = CleanBCI2000ParamStruct(parms)

flds = fieldnames(parms);
    for i=flds';
        try
            tempField = parms.(i{1});
        %         fprintf('%s ',tempField.Type);
            switch tempField.Type
                case 'string'
                    eval(sprintf('params.%s = tempField.Value;',i{1}));
                case 'matrix'
                    eval(sprintf('params.%s = tempField.Value;',i{1}));
                otherwise
                    numVal = double(tempField.NumericValue);
                    eval(sprintf('params.%s = numVal;',i{1}));
            end
        catch
            bad = cell2mat(i);
            fprintf('  ignoring params.%s, not numerical\n', bad);
        end
    end