function PlotAll(sid, hemi)
    % hemi is optional
    if (~exist('hemi','var'))
        hemi = determineHemisphereOfCoverage(sid);
    end
    
    PlotCortex(sid, hemi);
    PlotElectrodes(sid);
end