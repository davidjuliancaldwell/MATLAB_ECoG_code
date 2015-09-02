function unencodedId = reverseEncoding(encodedId)

    months = {'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'};
    letters = ['abcdefghijklmnopqrstuvwxyz'];
    years = 8:30;

    for year = years
        for letter = letters
            for month = months
                unencodedId = [month{:} letter zeropad(num2str(year), 2)];

%                 fprintf('compare %s : %s\n'
                if (strcmpi(encodedId, genPID(unencodedId)) == 1)
                    if nargout == 0
                        fprintf('match found! unencoded PID = %s\n', unencodedId);
                    end
                    return;
                end                
            end
        end
    end
    
    unencodedId = '';
end

function padded = zeropad(input, len)

    while (length(input) < len)
        input = ['0' input];
    end
    
    padded = input;
end
