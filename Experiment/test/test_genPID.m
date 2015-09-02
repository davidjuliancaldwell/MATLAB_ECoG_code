%% test_genPID.m
%  jdw
%
% Changelog:
%   13APR2011 - originally written
%
% this is a testing function for genPID.m
%
% Parameters:
%   none
%
% Return Values:
%   none
%

function test_genPID

    monthMax = 12;
    letterMax = 26;
    yearMin = 11;
    yearMax = 30;

    results = char(zeros([monthMax letterMax yearMax-yearMin+1 6]));
    tests   = char(zeros([monthMax letterMax yearMax-yearMin+1 6]));
    
    for month = 1:monthMax
        for letter = 1:letterMax
            for year = yearMin:yearMax
                id = generateSubjId(month,letter,year);
                hashed = genPID(id);

                % for debugging purposes only
                % fprintf('testing %s, hash is %s\n', id, hashed);
                
                [res, x, y, z] = inResults(results, hashed);
                
                results(month, letter, year-yearMin+1, :) = hashed;
                tests  (month, letter, year-yearMin+1, :) = id;
                
                if (res == true)
                    warning(['collision - strings were ' tests(x,y,z,1) tests(x,y,z,2) tests(x,y,z,3) tests(x,y,z,4) tests(x,y,z,5) tests(x,y,z,6) ' & ' id]);
                end                
            end
        end
    end
    
    fprintf('finished.  if there were no warnings the test passed\n');
end

function [is, x, y, z] = inResults(results, test)
    is = false;
    for x = size(results,1)
        for y = size(results,2)
            for z = size(results,3)
                is = strcmp(results(x,y,z,:), test);
                if (is == true) 
                    
                    return;
                end
            end
        end
    end
    x = 0;
    y = 0;
    z = 0;
end

function id = generateSubjId(month, letter, year)
    letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', ...
      'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};

    months = {'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', ...
              'sep', 'oct', 'nov', 'dec'};
          
    id = strcat(months{month}, letters{letter}, num2str(year));
end