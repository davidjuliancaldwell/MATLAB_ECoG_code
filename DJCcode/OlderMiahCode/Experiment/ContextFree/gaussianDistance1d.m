%Measures the difference between two Gaussian PDFs
%based on the work in:
%"Designing a Metric for the Difference Between Gaussian Densities"
%Karim T. Abou–Moustafa, Fernando De La Torre and Frank P. Ferrie

function distance = gaussianDistance1d(mean1,mean2,var1,var2)    
    S = (var1+var2)/2;
    
    meanDiff = mean1-mean2;
    meanDist = abs(meanDiff) / S;
    
    
    covDist = sqrt((log(var1/var2))^2);
    
    distance = meanDist + covDist;
end
