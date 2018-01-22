function [vals, key] = hmatValueForElectrodes(talairachCoords)
% function [vals, key] = hmatValueForElectrodes(talairachCoords)
%
% Given a set of electrode coordinates (Mx3) in talairach brain space
% this script returns the list of HMAT values that correspond to those
% electrodes.  If any of the electrodes are located outside of the labeled
% areas corresponding to the HMAT atlas, a value of zero is returned for
% that electrode.  The second return value, 'key', is a cell array of text
% labels corresponding to the numeric HMAT values.
%
% Author: JDW

    hmatFilepath = fullfile(fileparts(which('hmatValueForElectrodes')), 'hmat.mat');
    
    if (~exist(hmatFilepath, 'file'))
        error 'This script needs hmat.mat (contained in the same directory) to run';
    else
        load(hmatFilepath);
    end
    
    coords = talairachCoords;
    
    % reverse the y and x direction to conform to the hmat basis vectors
    coords(:,2) = -coords(:,2);
    coords(:,1) = -coords(:,1);

    coords = round(coords);
    ofcoords = coords - repmat(hdr.ORIGIN, size(coords,1), 1);
    
    vals = zeros(size(ofcoords,1),1);
    
    for d = 1:3
        bads = (ofcoords(:,d) > size(allvals, d));
        
        if (any(bads))
            warning ('at least one electrode was outside the bounds of the HMAT template, forcing fit');
            ofcoords(bads, d) = size(allvals, d);
        end
    end
        
    for c = 1:length(vals)
        vals(c) = allvals(ofcoords(c,1),ofcoords(c,2),ofcoords(c,3));
    end
    
    key = {'RM1','LM1','RS1','LS1','RSMA','LSMA','RpSMA','LpSMA','RPMd','LPMd','RPMv','LPMv'};

%     % debug purposes
%     mvals = vals;
%     mvals(mvals == 0) = NaN;
%     
%     figure
%     PlotDotsDirect('tail', talairachCoords, mvals, 'b', [1 12], 10, 'recon_colormap', [], false);
%     load('recon_colormap');
%     colormap(cm);
%     ax = colorbar;
%     set(colorbar, 'ytick', 1:12);
%     set(colorbar, 'yticklabel', key);
%     % /debug
    
end