%Measures the difference between two Gaussian PDFs
%based on the work in:
%"Designing a Metric for the Difference Between Gaussian Densities"
%Karim T. Abou–Moustafa, Fernando De La Torre and Frank P. Ferrie

function distance = gaussianDistanceNd(mean1,mean2,cov1,cov2)
    EVs = eig(cov1,cov2);
    
    S = (cov1+cov2)/2;
    
    meanDiff = mean1-mean2;
    meanDist = meanDiff * (S \ meanDiff');  %using division is due to the INV function sucking in Matlab apparently
    
    LogEVs = log(EVs);
    covDist = sqrt(dot(LogEVs,LogEVs));
    
    distance = meanDist;% + covDist;   <---use Mahalanobis only
end
