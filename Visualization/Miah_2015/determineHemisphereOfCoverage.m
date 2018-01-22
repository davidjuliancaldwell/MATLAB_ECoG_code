function hemi = determineHemisphereOfCoverage(varargin)
    switch (nargin)
        case 1
            % NARGIN = 1
            % single arg is subjid
        
            % since we just have a subject ID, we'll hunt for the
            % trodes.mat file
            subjDir = getSubjDir(varargin{1});
            
            if (exist(fullfile(subjDir, 'trodes.mat'), 'file'))
                load(fullfile(subjDir, 'trodes.mat'), 'AllTrodes');
            elseif (exist(fullfile(subjDir, 'other', 'trodes.mat'), 'file'))
                load(fullfile(subjDir, 'other', 'trodes.mat'), 'AllTrodes');
            else
                error('trodes.mat not found for %s', varargin{1});
            end
            
            locs = AllTrodes;
            
            % now load the cortex
            newCtx = fullfile(subjDir, 'surf', sprintf('%s_cortex_both_hires.mat', varargin{1}));
            oldCtx = fullfile(subjDir, 'surf', sprintf('%s_cortex.mat', varargin{1}));
            if (exist(newCtx, 'file'))
                load(newCtx);
            elseif (exist(oldCtx, 'file'))
                load(oldCtx);
            else
                error('no cortex file found for %s', varargin{1});
            end
            
            vertices = cortex.vertices;
                
        case 2
            % NARGIN = 2
            % first arg is vertex locations of cortex, second is the electrode
            % locations

            vertices = varargin{1};
            locs = varargin{2};
            
        otherwise
            error('see usage requirements, only accepts 1 or 2 arguments');
    end
    
    % SWAG function to make a guess at the appropriate coverage hemisphere
    % based on trode location and center of "mass" of the cortex in the L-R
    % dimension

    % first, look for a hemi.mat file for the subject
    if (exist('subjDir', 'var') && exist(fullfile(subjDir, 'other', 'hemi.mat'), 'file'))
        load(fullfile(subjDir, 'other', 'hemi.mat'));
        return;
    else
    
    % the L-R dimension is 1 of 3
    
    % determine L-R cortex min, max, and mean
    hullMin = min(vertices(:,1));
    hullMax = max(vertices(:,1));
    hullMean = mean(vertices(:,1));
    
    % some simple error checking
    if (abs(hullMean) > 20)
        % recon potentially only single hemi
        
        warning('it looks like the recon for this subject is only a single hemisphere, plotting to verify.  If this is the case, you can always save a file, <SDIR>/other/hemi.mat with the variable hemi as either ''l''/''r''/''both''');
        figure;
        plot3(vertices(:,1), vertices(:,2), vertices(:,3), '.');
    end
    
    % determine the mean x location of electrode placements
    locMean = mean(locs(:,1));
    
    if (locMean < (hullMean - 0.2*(hullMax - hullMin)))
        hemi = 'l';
    elseif (locMean > (hullMean + 0.2*(hullMax-hullMin)))
        hemi = 'r';
    else
        hemi = 'b';
    end
end