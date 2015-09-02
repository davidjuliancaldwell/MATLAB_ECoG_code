classdef mSVM < handle
    properties
        pathToModel;
        
        LIBSVM_TEST_EXE_STRING = [fullfile(myGetenv('gridlab_ext_dir'), 'external', 'libsvm-3.17', 'windows') ...
            filesep 'svm-predict.exe -q -b 1'];
        
    end
    methods
        function self = mSVM()
            x = 5;
        end        
        function loadModel(self, newPathToModel)
            self.pathToModel = newPathToModel;            
        end
        function [label, probability] = predict(self, features)
            % write out the test feature file in a libsvm friendly format
            libsvmwrite('test.txt', zeros(size(features,1),1), sparse(features));
            
            % perform prediction
            result = system([self.LIBSVM_TEST_EXE_STRING ' test.txt ' self.pathToModel ' out.txt']);
            
            h = fopen('out.txt', 'r');
            
            % assume two class svm
            labels = sscanf(fgetl(h), 'labels %d %d'); 
            
            label = [];
            probability = [];
            
            line = fgetl(h);
            while(line > 0)
                res = sscanf(line, '%d %f %f');
                label(end+1) = res(1);
                probability(end+1) = res(res(1)+2);
                line = fgetl(h); 
            end
            
            fclose(h);
            
            delete test.txt out.txt;
        end
    end
end