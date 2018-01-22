function result = trodesToTalairach(subjid)
% function result = trodesToTalairach(subjid)
%
% This script transforms electrode locations for a subject (argument:
% subjid) into talairach space.  It does this by collecting the talairach
% transform matrix that is generated during the reconstruction process.  If
% you don't have internet access to the reconstruction server on which
% this subject was subject's recon was completed, this script will fail
% because of an inability to fetch the talairach transform.
%
% After collecting the transform, this script generates all talairach
% electrode coordinates and projects them down to the talairach hull using
% the same methodology as is used for standard cortical recons [Hermes et
% al. JNS 2010].
%
% To run this script, you will need to know hemisphere of coverage, as well
% as implanted element dimensions (i.e. grid, strip, or depth).  Typically
% this information can be found in <SUBJDIR>/images/
%
% Author: JDW

    curdir = pwd;
    root = fileparts(which('trodesToTalairach'));
    
    %% setup parameters
   
    if (exist('subjid', 'var') == false)
        error('subject id is required');
    end
    
    TouchDir(fullfile(root,'temp'));
    xfmFilepath = fullfile(root, 'temp', 'talairach.xfm');
    
    %% get the talairach transform from freesurfer
    if(exist(xfmFilepath,'file'))
        delete(xfmFilepath);
    end
    
    fprintf('Retreving talairach transform matrix...\n');
    
    if (ispc()) % PC Version
        cmd = BuildRemoteToLocalTransfer('mri/transforms/talairach.xfm', xfmFilepath, subjid);
        status = RunCmd(cmd,1);
    else % MAYBE a working mac version
        warning('Kurt/Hai, i''ve never run this code, you''ll have to check it on your own.  But this is the general idea.');
        uname = input('enter your username on appserver: ', 's');
        maccmd = sprintf('scp %s@appserver.cs.washington.edu:/warehouse/freesurfer/subjects/%s/mri/transforms/talairach.xfm temp/talairach.xfm', uname, subjid);
        [status, result] = system(maccmd);
    end
        

    if (strfind(status, 'no such file or directory'))
        result = 0;
        cd(curdir);
        return;
    end
    
    fid = fopen(xfmFilepath);
    
    for c = 1:8
        line = fgetl(fid);
        
        if (c >= 6)
            A = sscanf(line, '%f %f %f');
            transform(c-5, :) = A;
        end
    end
    
    fclose(fid);
    delete(xfmFilepath);
    
%     delete('temp\talairach.xfm');
%     save(fullfile('temp', ['talairach_transform_' subjid]), 'transform');

    %% transform the electrodes in trodes.mat to talairach space
    % kurt start macify here
    subjdir = [myGetenv('subject_dir') filesep subjid];
    
    TouchDir(fullfile(subjdir, 'other'));
    save(fullfile(subjdir, 'other', 'talairach_transform.mat'), 'transform');
    
    load([subjdir filesep 'trodes.mat']);
    
    for trode = TrodeNames
        trode = trode{:};
        
        eval(sprintf('ptemp = %s;', trode));
        ptemp = cat(2, ptemp, ones(size(ptemp, 1), 1));
        ptemp = ptemp * transform';
        eval(sprintf('%s = ptemp;', trode));
        clear ptemp;
    end
    
%     AllTrodes = cat(2, AllTrodes, ones(size(AllTrodes, 1), 1));
%     AllTrodes = AllTrodes * transform';
    
    temp = TrodeNames;
    
    
    %% project, if necessary on to the template hull
    
    for arrayName = TrodeNames
        eval(sprintf('target = %s;', arrayName{:}));
        
        hemi = [];
        fprintf('Processing ''%s''...\n',arrayName{:});
        while isempty(hemi)
            fprintf('  Hemisphere (r/l): \n');
            choice = input('    => ','s');
            switch choice
            case 'r'
                hemi = 'r';
            case 'l'
                hemi = 'l';
            otherwise
                error('  Bad choice\n');
            end
        end

        fprintf('  Type of grid:\n',arrayName{:});
        fprintf('    %5i - M X N - Grid\n',1);
%         fprintf('%5i - 2 x N - Wide Strip\n',2);

        fprintf('    %5i - 1 X N - Thin Strip\n',2);
        fprintf('    %5i - 1 X N - Depth\n',3);
        choice = input('  => ');

        switch choice
            case 1
                index = 5;
                checkDistance = 1;
            case 2
                index = 0;
                checkDistance = 2;
            case 3
                continue;
            otherwise
                error('  Bad choice\n');
        end

        gs = getHull(hemi);
        gs = gs.vert;
        
        out_els = [];

        ignoreEls = [];

        while(1)
            out_els=p_zoom(target,gs,index,checkDistance, ignoreEls);

            if hemi=='l'
                view(240, 30);     
            elseif hemi=='r'
                view(60, 30);      
            end
            
            fprintf('Options:\n');
            fprintf('  1. Projected positions\n');
            fprintf('  2. Original Positions\n');
            fprintf('  3. Smooth electrodes and re-project\n');
            fprintf('  4. Change origin offset\n');
            fprintf('  5. Ignore projection for subset of eletrodes\n');
            fprintf('  6. Manually set electrode position\n');
            choice = lower(input('Default [1] => ','s'));

            if isempty(choice)
                choice = '1';
            end
            

            switch choice
                case '1'
                    eval(sprintf('%s = out_els;', arrayName{:}));
                    break;
                case '2'
                    fprintf('Ignoring projection.\n');
                    break;
                case '4'
                    originOffset = input('Change origin offset: \','s');
                    originOffset = str2num(originOffset);
                case '3'
                    fprintf('Smoothing electrodes...\n');

                    temp = target;
                    target = zeros(size(temp));
                    
                    if (1)
                        fprintf('Enter Grid Dimensions.  i.e. [8 8] or [6 8], listing the 1,2,3... dim first etc\n');
                        dims = input('=> ','s');                        
                        eval(sprintf('dimensions = %s;', dims));
                        
                        rtemp = reshape(temp, [dimensions 3]);
                        rtarget = zeros(size(rtemp));
                        for i = 1:size(rtemp,1)
                            for j = 1:size(rtemp,2)
                                if ((i == 1 || i == size(rtemp,1)) && (j == 1 || j == size(rtemp,2))) 
                                    rtarget(i,j,:) = rtemp(i,j,:);
                                elseif (i == 1 || i == size(rtemp,1)) % isxedge, copy from edges
                                    rtarget(i,j,:) = mean(rtemp(i,[j-1 j+1],:),2);
                                elseif (j == 1 || j == size(rtemp,2)) % isyedge
                                    rtarget(i,j,:) = mean(rtemp([i-1 i+1],j,:),1);
                                else % is middle, copy from surrounding
                                    rtarget(i,j,:) = mean(mean(rtemp([i-1 i+1],[j-1 j+1],:),1),2);
                                end
                            end
                        end
                        
                        target = reshape(rtarget, size(temp));
                        
%                         c = [1 dimensions(1) dimensions(1)*(dimensions(2)-1)+1 dimensions(1)*dimensions(2)];
%                         
%                         target(c(1),:) = temp(c(1),:); target(c(2),:) = temp(c(2),:); target(c(3),:) = temp(c(3),:); target(c(4),:) = temp(c(4),:);
%                         
% %                         target(1,:) = temp(1,:); target(8,:) = temp(8,:); target(57,:) = temp(57,:); target(64,:) = temp(64,:);
% 
%                         % smooth edges
%                         for i=c(1)+1:c(2)-1; target(i,:) = (temp(i-1,:) + temp(i+1,:)) ./ 2; end
%                         for i=c(3)+1:c(4)-1; target(i,:) = (temp(i-1,:) + temp(i+1,:)) ./ 2; end
%                         for i=c(1)+1:c(2)-1; target(i*c(2),:) = (temp((i-1)*c(2),:) + temp((i+1)*c(2),:)) ./ 2; end
%                         for i=c(1)+1:c(2)-1; target(i*c(2)-c(2)+1,:) = (temp((i-1)*c(2)-c(2)+1,:) + temp((i+1)*c(2)-c(2)+1,:)) ./ 2; end
% 
%                         % smooth middle
%                         for row=2:7; for col=2:7; target(((row-1)*8)+col,:) = (temp(((row-2)*8)+col,:) + temp(((row)*8)+col,:) + temp(((row-1)*8)+col+1,:) + temp(((row-1)*8)+col-1,:)) ./ 4; end; end
                        
%                     elseif (checkDistance == 2) % working with a strip
%                         target(1,:) = temp(1,:);
%                         target(end,:) = temp(end,:);
%                         
%                         for c = 2:(size(target,1)-1)
%                             target(c,:) = (temp(c-1,:) + temp(c+1,:)) ./ 2; 
%                         end
                    else
                        fprintf(' .. couldn''t smooth\n');
                    end
                    
                case '5'
                    fprintf('Add electrodes to be ignored in vector format.  i.e. [1 2 4] or [1:5 8:11] etc\n');
                    elecsChosen = input('=> ','s');
                    eval(sprintf('ignoreEls = unique(union(%s, ignoreEls));',elecsChosen));
                case '6'
                    fprintf('Enter electrode index: \n');
                    trodeIdx = input('=>', 's');
                    trodeIdx = str2num(trodeIdx);
                    
                    fprintf('Enter new coordinates i.e. [20 -14.3 7.8]: \n');
                    coords = input('=>', 's');
                    eval(sprintf('target(%d,:) = [%s];', trodeIdx, coords));
                otherwise
                    fprintf('Bad choice\n');
            end
            close all;
        end
        close all;
    end

    AllTrodes = [];
    for name = TrodeNames
        name = name{1};
        eval(sprintf('AllTrodes = cat(1,AllTrodes,%s);', name));
    end
        
    %% show off your handiwork
    figure;
    plotHull(hemi);
    hold on;
    
    colors = 'bgrcmyk';
    ctr = 1;
    
    labels = [];
    
    for name = TrodeNames
        name = name{:};
        
        color = colors(ctr+1);
        ctr = mod((ctr + 1), length(colors));
        
        eval(sprintf('plot3(%s(:, 1), %s(:, 2), %s(:, 3), ''%so'');', name, name, name, color));
        
        eval(sprintf('labels = [labels 1:size(%s, 1)];', name));
    end
    
    %% save the tal_trodes.mat file

    temp = TrodeNames;
    temp{end+1} = 'AllTrodes';
    temp{end+1} = 'TrodeNames';
    
    fprintf('saving output to: %s\n', [subjdir filesep 'other' filesep 'tail_trodes.mat']);    
    save([subjdir filesep 'other' filesep 'tail_trodes.mat'], temp{:});

    figure;
    PlotDotsDirect('tail',AllTrodes,ones(size(AllTrodes,1)),hemi,[0 1], 20, 'jet', labels);
    
    cd(curdir);
    result = 1;
end

function gs = getHull(hemi)
    if (exist('hemi', 'var'))
        
        switch hemi
            case 'r'
                load ('blurred_right.mat');
                gs = brain;
            case 'l'
                load ('blurred_left.mat');
                gs = brain;
            otherwise
                error('incorrect hemi designation');
        end
    else
        error('full brain not supported'); 
    end
end

function plotHull(hemi)
    load('loc_colormap');
    
    if (exist('hemi', 'var'))
        
        switch hemi
            case 'r'
                load ('blurred_right.mat');
                cortex = brain;
            case 'l'
                load ('blurred_left.mat');
                cortex = brain;
            otherwise
                error('incorrect hemi designation');
        end
    else
        error('full brain not supported');
    end

    c = cortex.vert;
    
    plot3(c(:,1),c(:,2),c(:,3), 'k.');
    axis equal;
end

function fullCmd = BuildRemoteToLocalTransfer(remoteFile, localFile, subjid)

    
    load(fullfile(myGetenv('matlab_devel_dir'), 'Visualization', 'Recon', 'reconConfig.mat'));
%     exedir = [ strrep(myGetenv('matlab_devel_dir'), '\', '/')
%     '/Visualization/Recon/' ];
    exedir = fullfile(myGetenv('matlab_devel_dir'), 'Visualization', 'Recon');
    plinkpath = fullfile(exedir, 'plink.exe');
    pscppath  = fullfile(exedir, 'pscp.exe');
    puttyprivpath = fullfile(exedir, config.PrivateKeyFile);

     
    pscppath = strrep(pscppath, '\', '\\');
    puttyprivpath = strrep(puttyprivpath, '\', '\\');
    fullCmd = sprintf([pscppath ' -i ' puttyprivpath ' %s@%s:%s/subjects/%s/%s %s'],...
        config.LinuxServerLoginName, ...
        config.LinuxServerUrl, ...
        config.LinuxServerRemoteFreesurferDirectory,...
        subjid, ...
        remoteFile, ...
        localFile);
end

function result = RunCmd(fullCmd, displayResult)
    [a result] = system(fullCmd);
    if exist('displayResult')
        fprintf('%s\n', result);
    end
end