function ReconstructCorticalSurface(patientCode)


    % dataPath = 'c:\research\data\patients\';
    dataPath = [myGetenv('subject_dir') '\'];

    files = dir([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);

    if isempty(files) 
        config = CreateConfig();
        save([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat'],'config')
%     else
%         load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat'],'config')        
    end


    if ~exist('patientCode')
        % HARDCODE
        patientCode = input('Patient code (i.e. ''apra11'', will be encoded): ','s');
%         patientCode = '*DEBUG';
%         patientCode = 'augb11';
    end

%     patientCode = genPID(patientCode);
    setenv('recon_patientCode',patientCode);
    fprintf('Current patient data path: %s\n', dataPath);



    baseDir = [dataPath getenv('recon_patientCode') '\'];
    mriDir = [dataPath getenv('recon_patientCode') '\mri\'];
    ctDir = [dataPath getenv('recon_patientCode') '\ct\'];
    surfDir = [dataPath getenv('recon_patientCode') '\surf\'];

    %Test to see if process has been started already
    file = dir([mriDir getenv('recon_patientCode') '_orig.nii']);
    freesurferStarted = ~isempty(file);
    
    % Has freesurfer been started yet?
%     warning('freesurferStarted forced to 0');
%     freesurferStarted=0;
    if freesurferStarted == 0
        %Start freesurfer up
        BeginFreesurfer(baseDir, mriDir, ctDir, surfDir);
        fprintf('Freesurfer has started. This will take a while (4-12 hours, depending on quality of MRI).  If it takes longer than 24 hours, there is most likely a problem with your MRI\n');
    end

    
    file = dir([mriDir 'lh.dpial.ribbon.nii']);
    freesurferCompleted = ~isempty(file);
    % DEBUG
    freesurferCompleted = 0;

    %If freesurfer was started but not completed, check to see if it's
    %still going
    if freesurferStarted == 1 && freesurferCompleted == 0
        freesurferCompleted = PollFreesurferComplete();
        if freesurferCompleted == 1
            GetFreesurferResults(mriDir);
            fprintf('Freesurfer reconstruction complete!\n');
        end  
    end
    
    if freesurferCompleted == 0
        fprintf('Freesurfer is running. Run this script again in a while to check if has completed\n');
        if HasGeneratedBISTrodes(baseDir) == 0
            fprintf('\n\n**NOTE**\n In the meantime, make sure you generate the electrode positions for the CT scan:\n  %s/ct/r%s_ct_reoriented.hdr \nusing BioImage Suite and export them as:\n %s/bis_trodes.txt\n',[dataPath getenv('recon_patientCode')], getenv('recon_patientCode'),[dataPath getenv('recon_patientCode')]);
        end
        return;
    end
    
    if HasGeneratedBISTrodes(baseDir) == 0
        fprintf('\n\n**NOTE**\n Please generate the electrode positions using BioImage Suite and export them as %s/bis_trodes.txt\n',[dataPath getenv('recon_patientCode')]);
        return;
    end
    
    % Now create surfaces
    
    
    eval(['cd ' baseDir]);
    
    GenerateNeededSurfaces(baseDir);
        
    file = dir([baseDir 'trodes.mat']);
    electrodesProjected = ~isempty(file);
    
    if electrodesProjected == 0
        ProjectElectrodes(baseDir);
    end
        
    
    
    fprintf('Completely finished reconstructions! All surfaces have been generated!\n');
end

function ProjectElectrodes(subjDir )
    BioImageToMatlab(getenv('recon_patientCode'));

    load(fullfile(subjDir, 'bis_trodes.mat'));

    hemi = 'r';

    originOffset = [0 0 0];

    for arrayName = TrodeNames
        eval(sprintf('target = %s;', arrayName{:}));
        
        hemi = [];
        fprintf('Processing ''%s''...\n',arrayName{:});
        while isempty(hemi)
            fprintf('  Hemisphere (r/l): \n');
            choice = input('    => ','s');
            switch choice
            case 'r'
                hemi = 'rh';
            case 'l'
                hemi = 'lh';
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

        load([subjDir '/surf/' getenv('recon_patientCode') '_cortex_' hemi '_hires.mat']);

        [x,y,z]=ind2sub(size(brainHull),find(brainHull>0)); 
        % from indices 2 native
        gs=([x y z]*transformMat(1:3,1:3)')+repmat(transformMat(1:3,4),1,length(x))'; 
    %     fprintf('LOWRES HACK IN EFFECT!!!!\n');
    %     gs=([x y z]*transformMat(1:3,1:3)')+repmat(transformMat(1:3,4),1,length(x))'; 
    %     gs = [x z y];
        out_els = [];

        ignoreEls = [];

        while(1)
            out_els=p_zoom(target,gs,index,checkDistance, ignoreEls);
    %         out_els(ignoreEls,:) = target(ignoreEls,:);
    %         out_els=p_zoom(target + repmat(originOffset,size(target,1),1),gs,index,checkDistance);

            if hemi=='l'
                view(240, 30);     
            elseif hemi=='r'
                view(60, 30);      
            end

            % errors = sqrt((out_els(:,1) - Grid(:,1)).^2 + (out_els(:,2) - Grid(:,2)).^2 + (out_els(:,3) - Grid(:,3)).^2);
            % bad = find((errors - mean(errors)) ./ std(errors) > 2);

        %     ctmr_gauss_plot(cortex,[0 0 0],0,hemi); 
        %     hold on;
        %     plot3(target(:,1),target(:,2),target(:,3),'markersize',20,'linestyle','none','marker','.','color','r');
        %     plot3(out_els(:,1),out_els(:,2),out_els(:,3),'markersize',20,'linestyle','none','marker','.','color','g');

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
                    
                    if (checkDistance == 1) % working with a grid, % THIS ASSUMES 8x8!!
                        target(1,:) = temp(1,:); target(8,:) = temp(8,:); target(57,:) = temp(57,:); target(64,:) = temp(64,:);

                        % smooth edges
                        for i=2:7; target(i,:) = (temp(i-1,:) + temp(i+1,:)) ./ 2; end
                        for i=58:63; target(i,:) = (temp(i-1,:) + temp(i+1,:)) ./ 2; end
                        for i=2:7; target(i*8,:) = (temp((i-1)*8,:) + temp((i+1)*8,:)) ./ 2; end
                        for i=2:7; target(i*8-7,:) = (temp((i-1)*8-7,:) + temp((i+1)*8-7,:)) ./ 2; end

                        % smooth middle
                        for row=2:7; for col=2:7; target(((row-1)*8)+col,:) = (temp(((row-2)*8)+col,:) + temp(((row)*8)+col,:) + temp(((row-1)*8)+col+1,:) + temp(((row-1)*8)+col-1,:)) ./ 4; end; end
                        
                    elseif (checkDistance == 2) % working with a strip
                        target(1,:) = temp(1,:);
                        target(end,:) = temp(end,:);
                        
                        for c = 2:(size(target,1)-1)
                            target(c,:) = (temp(c-1,:) + temp(c+1,:)) ./ 2; 
                        end
                    else
                        fprintf(' .. couldn''t smooth\n');
                    end
                    
                    % here's the old way, this assumed an 8 x 8 grid
%                     temp = target;
%                     target = zeros(size(temp));
%                     target(1,:) = temp(1,:); target(8,:) = temp(8,:); target(57,:) = temp(57,:); target(64,:) = temp(64,:);
% 
%                     % smooth edges
%                     for i=2:7; target(i,:) = (temp(i-1,:) + temp(i+1,:)) ./ 2; end
%                     for i=58:63; target(i,:) = (temp(i-1,:) + temp(i+1,:)) ./ 2; end
%                     for i=2:7; target(i*8,:) = (temp((i-1)*8,:) + temp((i+1)*8,:)) ./ 2; end
%                     for i=2:7; target(i*8-7,:) = (temp((i-1)*8-7,:) + temp((i+1)*8-7,:)) ./ 2; end
% 
%                     % smooth middle
%                     for row=2:7; for col=2:7; target(((row-1)*8)+col,:) = (temp(((row-2)*8)+col,:) + temp(((row)*8)+col,:) + temp(((row-1)*8)+col+1,:) + temp(((row-1)*8)+col-1,:)) ./ 4; end; end
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

    cmd = ['save ' subjDir 'trodes.mat AllTrodes TrodeNames '];
    for name = TrodeNames
        name = name{1};
        cmd = [cmd name ' '];
    end

    cmd = [cmd ';'];
    eval(cmd);
end

function GenerateNeededSurfaces(baseDir)

    for side = {'lh','rh','both'}
        for type = {'hires','printable','lowres'}
            fileName = ['surf/' getenv('recon_patientCode') '_cortex_' side{:} '_' type{:}  '.mat'];
            isThere = TestFileExists(fileName,baseDir);
            
            if isThere == 1
                continue;
            end
            fprintf('Generating surface file ''%s''...\n', fileName);
            
            switch side{:}
                case 'both'
                    switch type{:}
                        case 'hires'
                            fprintf('  Combining left and right hi-res OBJ\n');
                            
                            meshLabExe = fullfile(myGetenv('gridlab_ext_dir'), 'external', 'MeshLab', 'meshlabserver.exe');
                            inLeft = [baseDir 'surf\obj\lh.obj'];
                            inRight = [baseDir 'surf\obj\rh.obj'];
                            bothFile = [baseDir 'surf\obj\both.obj'];
                            scriptFile = fullfile(myGetenv('matlab_devel_dir'), 'Visualization', 'Recon', 'merge_lr.mlx');
                            [resulta result] = system(sprintf('%s -i %s %s -s %s -o %s -om vn', meshLabExe, inLeft, inRight,scriptFile, bothFile));
                            clear resulta result
                            
                            fprintf('  Loading combined hi-res OBJ (this may take a few minutes)\n');
                            [cortex.vertices cortex.faces cortex.normals] = load_tobj(bothFile);
                            cortex.facevertexcdata = zeros(size(cortex.vertices,1),1);

                            fprintf('  Saving\n');
                            eval(['save ' fileName ' cortex']);
                            clear cortex;
                        case 'lowres'
                            fprintf('  Combining left and right low-res OBJ\n');
                            
                            meshLabExe = [myGetenv('gridlab_ext_dir') '\external\MeshLab\meshlabserver.exe'];
                            inLeft = [baseDir 'surf/obj/lh_lowres.obj'];
                            inRight = [baseDir 'surf/obj/rh_lowres.obj'];
                            bothFile = [baseDir 'surf/obj/both_lowres.obj'];
                            scriptFile = [myGetenv('matlab_devel_dir') 'Visualization\Recon\merge_lr.mlx'];
                            
                            [resulta result] = system(sprintf('%s -i %s %s -s %s -o %s -om vn', meshLabExe, inLeft, inRight,scriptFile, bothFile));
                            clear resulta result
                            
                            fprintf('  Loading combined hi-res OBJ (this may take a few minutes)\n');
                            [lowres_cortex.vertices lowres_cortex.faces lowres_cortex.normals] = load_tobj(bothFile);
                            lowres_cortex.facevertexcdata = zeros(size(lowres_cortex.vertices,1),1);

                            fprintf('  Saving\n');
                            eval(['save ' fileName ' lowres_cortex']);
                            clear lowres_cortex;
                        case 'printable'
                            
                            fprintf('  Exporting lh printable OBJ\n');
                            load([baseDir 'surf/' getenv('recon_patientCode') '_cortex_lh_printable.mat']);
                            write_obj([baseDir 'surf/obj/lh_printable.obj'],cortex.vertices,cortex.faces);
                            fprintf('  Exporting rh printable OBJ\n');
                            load([baseDir 'surf/' getenv('recon_patientCode') '_cortex_rh_printable.mat']);
                            write_obj([baseDir 'surf/obj/rh_printable.obj'],cortex.vertices,cortex.faces);
                            
                            fprintf('  Combining left and right printable OBJ\n');
                            
                            meshLabExe = [myGetenv('gridlab_ext_dir') '\external\MeshLab\meshlabserver.exe'];
                            inLeft = [baseDir 'surf/obj/lh_printable.obj'];
                            inRight = [baseDir 'surf/obj/rh_printable.obj'];
                            bothFile = [baseDir 'surf/obj/both.obj'];
                            scriptFile = [myGetenv('matlab_devel_dir') 'Visualization\Recon\merge_lr.mlx'];
                            [resulta result] = system(sprintf('%s -i %s %s -s %s -o %s -om vn', meshLabExe, inLeft, inRight,scriptFile, bothFile));
                            clear resulta result
                            
                            fprintf('  Loading combined printable OBJ (this may take a few minutes)\n');
                            [cortex.vertices cortex.faces cortex.normals] = load_tobj(bothFile);
                            cortex.facevertexcdata = zeros(size(cortex.vertices,1),1);

                            fprintf('  Saving\n');
                            eval(['save ' fileName ' cortex']);
                            clear cortex;
                    end

                otherwise
                    switch type{:}
                        case 'hires'
                            threshold = 0.1;
                            GenSurfFromMRI([baseDir '/mri/' side{:} '.dpial.ribbon.nii'], [baseDir fileName], threshold);
                        case 'printable'
                            threshold = -1;
                            GenSurfFromMRI([baseDir '/mri/' side{:} '.dpial.ribbon.nii'], [baseDir fileName], threshold);
                        case 'lowres'
                            %Note: needs to be run AFTER hires, since it assumes
                            %the hires file exists
                            clear cortex;
                            [a b c] = mkdir([baseDir 'surf/obj']);
                            clear a b c;
                            fprintf('  Loading hires surface\n');
                            eval(sprintf('load %s;', ['surf/' getenv('recon_patientCode') '_cortex_' side{:} '_hires.mat']));

                            fprintf('  Exporting to OBJ\n');
                            write_obj([baseDir 'surf/obj/' side{:} '.obj'],cortex.vertices,cortex.faces);
                            fprintf('  Executing meshlab surface decimation\n');

                            % HARDCODED
                            meshLabExe = [myGetenv('gridlab_ext_dir') '\external\MeshLab\meshlabserver.exe'];
                            inputFile = [baseDir 'surf/obj/' side{:} '.obj'];
                            scriptFile = [myGetenv('matlab_devel_dir') '\Visualization\Recon\create_lowpoly.mlx'];
                            outputFile = [baseDir 'surf/obj/' side{:} '_lowres.obj'];
                            [resulta result] = system(sprintf('%s -i %s -s %s -o %s -om vn', meshLabExe, inputFile, scriptFile, outputFile));
                            clear resulta result

                            fprintf('  Loading low poly OBJ\n');
                            [lowres_cortex.vertices lowres_cortex.faces lowres_cortex.normals] = load_tobj(outputFile);
                            lowres_cortex.facevertexcdata = zeros(size(lowres_cortex.vertices,1),1);

                            fprintf('  Saving\n');
                            eval(['save ' fileName ' lowres_cortex']);
                            clear lowres_cortex;
                    end
            end
        end
    end
end

function GenSurfFromMRI(fullName, destName, threshold)
    brain_info = spm_vol(fullName);
    brainVol = double(brain_info.private.dat);
    fprintf('  Creating surface\n');
    transformMat = brain_info.mat;
    temp1 = isosurface(brainVol,threshold);
    temp2 = isonormals(smooth3(brainVol),temp1.vertices);

    cortex = temp1;
    cortex.vertexnormals  = temp2;
    cortex.facevertexcdata = zeros(size(cortex.vertices,1),1);
    rotMat = brain_info.mat(1:3,1:3)';

    newRot = [[0 1 0];[1 0 0];[0 0 1]];
    cortex.vertices = cortex.vertices * newRot;
    cortex.vertexnormals = cortex.vertexnormals * newRot;

    cortex.vertices=(cortex.vertices*transformMat(1:3,1:3)')+repmat(transformMat(1:3,4),1,length(cortex.vertices))'; 
    cortex.vertexnormals=(cortex.vertexnormals*rotMat);

    cortex.vertexnormals=cortex.vertexnormals ./ repmat(sqrt(sum((cortex.vertexnormals .* cortex.vertexnormals),2)),1,3);
    
    %%

    fprintf('  Loading volume for hull generation\n');
    brain_info=spm_vol(fullName); 
    [brainHull]=spm_read_vols(brain_info);

    %threshold like the isosurf does
    brainHull = (brainHull > threshold);

    %create the convex hull
    fprintf('  Creating the convex hull\n');
    for i=1:size(brainHull,3)
        [x y] = find(brainHull(:,:,i) > 0);
        if length(x) < 3 || length(y) < 3
            continue;
        end
        if length(unique(x)) < 2 || length(unique(y)) < 2
            continue;
        end
        out = convhull(x,y);
        brainHull(:,:,i) = roipoly(brainHull(:,:,i), y(out),x(out));
    end

    %blur the convex hull a little
    brainHull = sm_filt(brainHull,1);
    %get every pixel that is above threshold into the hull
    brainHull = (brainHull > 0);
    %hollow out the hull
    brainHull = hollow_brain(brainHull);

    transformMat = brain_info.mat;

    fprintf('  Saving results\n');
    eval(sprintf('save %s cortex brainHull transformMat;',destName));
end

function out = TestFileExists(relativePath, baseDir)
    testedFile = dir([baseDir relativePath]);
    out = ~isempty(testedFile);
end

function GetFreesurferResults(mriDir)
    cd(mriDir);
    fprintf('Zipping results...\n');
    
    load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/; mri_convert mri/lh.dpial.ribbon.mgz out/lh.dpial.ribbon.nii.gz', config.LinuxServerRemoteFreesurferDirectory,getenv('recon_patientCode')));
    result = RunCmd(cmd,1);
    
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/; mri_convert mri/rh.dpial.ribbon.mgz out/rh.dpial.ribbon.nii.gz', config.LinuxServerRemoteFreesurferDirectory,getenv('recon_patientCode')));
    result = RunCmd(cmd,1);

    fprintf('Retreving cortical ribbon plots...\n');
    cmd = BuildRemoteToLocalTransfer(['out/lh.dpial.ribbon.nii.gz'], 'lh.dpial.ribbon.nii.gz');
    result = RunCmd(cmd,1);
    cmd = BuildRemoteToLocalTransfer(['out/rh.dpial.ribbon.nii.gz'], 'rh.dpial.ribbon.nii.gz');
    result = RunCmd(cmd,1);

    fprintf('Unzipping...\n');
    gunzip(sprintf('lh.dpial.ribbon.nii.gz',getenv('recon_patientCode')));
    gunzip(sprintf('rh.dpial.ribbon.nii.gz',getenv('recon_patientCode')));
end

function out = HasGeneratedBISTrodes(baseDir)
    file = dir(fullfile(baseDir, 'other', 'bis_trodes.txt'));
    out = ~isempty(file);
end
    
function complete = PollFreesurferComplete()
    
    fprintf('Querying if freesurfer has completed...\n');
    
    load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/; tail output.txt', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode')));
    result = RunCmd(cmd);
    
    successfulFreesurfer = strfind(result,'without error');
    failedFreesurfer = strfind(result,'error');
    if ~isempty(successfulFreesurfer)
        fprintf('Recon complete!\n');
        complete = 1;
    elseif ~isempty(failedFreesurfer)
        fprintf('ERROR during Freesurfer recon\n');
        complete = 0;
    else
        complete = 0;
        fprintf('Freesurfer still running!\nMost recent freesurfer message:\n---\n%s\n---\n',result);
    end

end

function fullCmd = BuildRemoteCmd(cmd)

    load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);

    exedir = [ strrep(myGetenv('matlab_devel_dir'), '\', '/') '/Visualization/Recon/' ];
    plinkpath = [exedir 'plink.exe'];
    pscppath  = [exedir 'pscp.exe'];
    puttyprivpath = [exedir config.PrivateKeyFile];

    fullCmd = sprintf([plinkpath ' %s@%s -i ' puttyprivpath ' "%s"'], config.LinuxServerLoginName, ...
        config.LinuxServerUrl, ...
        cmd );
end

function fullCmd = BuildLocalToRemoteTransfer(localFile, remoteFile)

    load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);

    exedir = [ strrep(myGetenv('matlab_devel_dir'), '\', '/') '/Visualization/Recon/' ];
    plinkpath = [exedir 'plink.exe'];
    pscppath  = [exedir 'pscp.exe'];
    puttyprivpath = [exedir config.PrivateKeyFile];

    fullCmd = sprintf([pscppath ' -i ' puttyprivpath ' %s %s@%s:%s/subjects/%s/%s'],...
        localFile,...
        config.LinuxServerLoginName, ...
        config.LinuxServerUrl, ...
        config.LinuxServerRemoteFreesurferDirectory, ...
        getenv('recon_patientCode'),...
        remoteFile);
end

function fullCmd = BuildRemoteToLocalTransfer(remoteFile, localFile)

    
    load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);
    exedir = [ strrep(myGetenv('matlab_devel_dir'), '\', '/') '/Visualization/Recon/' ];
    plinkpath = [exedir 'plink.exe'];
    pscppath  = [exedir 'pscp.exe'];
    puttyprivpath = [exedir config.PrivateKeyFile];

     
    fullCmd = sprintf([pscppath ' -i ' puttyprivpath ' %s@%s:%s/subjects/%s/%s %s'],...
        config.LinuxServerLoginName, ...
        config.LinuxServerUrl, ...
        config.LinuxServerRemoteFreesurferDirectory,...
        getenv('recon_patientCode'), ...
        remoteFile, ...
        localFile);
end

function result = RunCmd(fullCmd, displayResult)
    [a result] = system(fullCmd);
    if exist('displayResult')
        fprintf('%s\n', result);
    end
end

function BeginFreesurfer(baseDir, mriDir, ctDir, surfDir)
    try 
        [a b c] = mkdir(baseDir); catch e; end;
    try [a b c] = mkdir(surfDir); catch e; end;
    try [a b c] = mkdir(mriDir); catch e; end;
    try [a b c] = mkdir(ctDir); catch e; end;
    
%     load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat'],'config')        


    %%%%%%%%%%%%%%%%%%%%%%
    %    PROCESS MRI
    %%%%%%%%%%%%%%%%%%%%%%
    fprintf('** Processing MRI\n');
    curDir = pwd;
    cd([mriDir '\rawdicom\']);
    % mriFile = uigetfile('*.dcm');
    dicomFiles = dir('*.*');


    dicomFiles = {dicomFiles.name}';

    dicomFiles = dicomFiles(3:end);
    
    fileType = lower(dicomFiles{1}(find(dicomFiles{1} == '.', 1, 'last')+1:end));

    switch fileType
        case 'dcm'
            %dicom slices
            fprintf('Dicom file\n');

            dicomFiles = sortrows(dicomFiles([2:13 1 14:end]));
            for i=1:size(dicomFiles,1)
                dicomFiles(i) = {[[mriDir '\rawdicom\'] dicomFiles{i}]};
            end

            cd(mriDir);     %To make sure we're in the MRI directory once we read/save the file
            fprintf('Reading dicom header\n');
            hdr = spm_dicom_headers(strvcat(dicomFiles), true);
            fprintf('Concatenating dicom files\n');
            dicomOut = spm_dicom_convert(hdr,'all','flat','img');


            fprintf('Rename file\n');
            movefile(dicomOut.files{1},[getenv('recon_patientCode') '_mri.img']);
            movefile([dicomOut.files{1}(1:find(dicomOut.files{1} == '.',1, 'last')) 'hdr'], [getenv('recon_patientCode') '_mri.hdr']);
        case 'gz'
            %assumes file.nii.gz
            gunzip([mriDir '\rawdicom\' dicomFiles{1}]);
            niiFile = dir('*.nii');
            volume = spm_vol([mriDir '\rawdicom\' niiFile.name]);
            volume.fname = [mriDir '\' getenv('recon_patientCode') '_mri.img'];
            spm_write_vol(volume,volume.private.dat(:,:,:));
        case 'nii'
            %straight up nifti file
            fprintf('Converting from Nifti to HDR format\n');
            niiFile = dir('*.nii');
            volume = spm_vol([mriDir '\rawdicom\' niiFile.name]);
            volume.fname = [mriDir '\' getenv('recon_patientCode') '_mri.img'];
            spm_write_vol(volume,volume.private.dat(:,:,:));
        otherwise
            fprintf('Type %s not supported\n', fileType);
    end
    
    
    fprintf('Reorienting origin to center of MRI image\n');
    volFile = spm_vol([mriDir '\' getenv('recon_patientCode') '_mri.img']);
    X = spm_read_vols(volFile);
    volFile.mat(1:3,4) = -(volFile.mat(1:3,1:3) * (volFile.dim ./2)');
    volFile.fname = [mriDir '\' getenv('recon_patientCode') '_mri_reoriented.img'];
    spm_write_vol(volFile,X);

    cd(curDir);

    %%%%%%%%%%%%%%%%%%%%%%
    %     Set up freesurfer space
    %  note, if we fail during the putty calls, and the system appears to
    %  hang it is probably the case that putty is getting stuck because of
    %  the fact that no connection has been made previously between your
    %  computer and the recon server.  try manually logging in via putty to
    %  the recon server
    %%%%%%%%%%%%%%%%%%%%%%
    %%
    fprintf('** Setting up freesurfer workspace\n');


    cd(mriDir);
    

    
    fprintf('Creating remote directory...\n');
    load([myGetenv('matlab_devel_dir') '\Visualization\Recon\reconConfig.mat']);
    
    cmd = BuildRemoteCmd(sprintf('mkdir -p %s/subjects/%s/mri/orig', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode')));
    result = RunCmd(cmd,1);
    
    cmd = BuildRemoteCmd(sprintf(' mkdir -p %s/subjects/%s/out', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode')));
    result = RunCmd(cmd,1);
    

    fprintf('Copying local file to server...\n');
    
     cmd = BuildLocalToRemoteTransfer([getenv('recon_patientCode') '_mri.hdr'], ['mri/orig/' getenv('recon_patientCode') '_mri.hdr']);
    result = RunCmd(cmd,1);
    cmd = BuildLocalToRemoteTransfer([getenv('recon_patientCode') '_mri.img'], ['mri/orig/' getenv('recon_patientCode') '_mri.img']);
    result = RunCmd(cmd,1);
    
    fprintf('Converting to mgz format...\n');
    
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/mri/orig/; mri_convert %s 001.mgz', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode'), [getenv('recon_patientCode') '_mri.hdr']));
    result = RunCmd(cmd,1);
    

    fprintf('Starting reconstruction job...\n');
    useGpu = '-use-gpu';
    if (...
            strcmpi(config.FreesurferUseCUDA,'yes') ~= 1 & ...
            strcmpi(config.FreesurferUseCUDA,'y') ~= 1 & ...
            strcmpi(config.FreesurferUseCUDA,'1') ~= 1)
        useGpu = '';
    end
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/; nohup recon-all -autorecon-all %s -subjid %s > output.txt &', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode'), useGpu, getenv('recon_patientCode')));
    result = RunCmd(cmd,1);   

    fprintf('Polling for orig.mgz...\n');
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/mri/; ls', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode')));
    result = RunCmd(cmd);
    origIsComplete = strfind(result,'orig.mgz');

    while isempty(origIsComplete);
        fprintf('  trying again in 3s...\n');
        pause(3);
        result = RunCmd(cmd);
        origIsComplete = strfind(result,'orig.mgz');
    end

    fprintf('Waiting 10s for orig.mgz to be written...\n');
    pause(10);

    fprintf('Zipping result...\n');
    cmd = BuildRemoteCmd(sprintf('cd %s/subjects/%s/; mri_convert mri/orig.mgz out/%s_orig.nii.gz', config.LinuxServerRemoteFreesurferDirectory, getenv('recon_patientCode'), getenv('recon_patientCode')));
    result = RunCmd(cmd,1);

    fprintf('Retreving aligned mri...\n');
    fprintf('Copying server file to local...\n');
    cmd = BuildRemoteToLocalTransfer(['out/' getenv('recon_patientCode') '_orig.nii.gz'], [ getenv('recon_patientCode') '_orig.nii.gz']);
    result = RunCmd(cmd,1);

    fprintf('Unzipping orig.nii...\n');
    gunzip(sprintf('%s_orig.nii.gz',getenv('recon_patientCode')));

    %%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Align CT to MRI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('** Processing CT\n');

    cd([ctDir '\rawdicom\']);
    % [ctFile ctDirectory] = uigetfile('*.dcm');
    dicomFiles = dir('*.*');
    cd(ctDir);

    dicomFiles = {dicomFiles.name}';

    dicomFiles = dicomFiles(3:end);
    
    fileType = lower(dicomFiles{1}(find(dicomFiles{1} == '.', 1, 'last')+1:end));

    fprintf('Converting to HDR format\n');
    switch fileType
        case 'dcm'
            fprintf('Dicom file\n');

            dicomFiles = sortrows(dicomFiles([2:13 1 14:end]));
            for i=1:size(dicomFiles,1)
                dicomFiles(i) = {[[ctDir '\rawdicom\'] dicomFiles{i}]};
            end
            fprintf('Reading dicom header\n');
            hdr = spm_dicom_headers(strvcat(dicomFiles), true);
            fprintf('Concatenating dicom files\n');
            dicomOut = spm_dicom_convert(hdr,'all','flat','img');

            movefile(dicomOut.files{1},[getenv('recon_patientCode') '_ct.img']);
            movefile([dicomOut.files{1}(1:find(dicomOut.files{1} == '.',1, 'last')) 'hdr'], [getenv('recon_patientCode') '_ct.hdr']);

        case 'nii'
            cd([ctDir '\rawdicom\']);
            niiFile = dir('*.nii');
            volume = spm_vol([ctDir '\rawdicom\' niiFile.name]);
            volume.fname = [ctDir '\' getenv('recon_patientCode') '_ct.img'];
            spm_write_vol(volume,volume.private.dat(:,:,:));
        otherwise
            fprintf('Type %s not supported\n', fileType);
    end
    cd(ctDir);
    
    fprintf('Reorienting origin to center of CT image\n');
    volFile = spm_vol([ctDir '\' getenv('recon_patientCode') '_ct.img']);
    X = spm_read_vols(volFile);
    volFile.mat(1:3,4) = -(volFile.mat(1:3,1:3) * (volFile.dim ./2)');
    volFile.fname = [ctDir '\' getenv('recon_patientCode') '_ct_reoriented.img'];
    spm_write_vol(volFile,X);
    
    
    fprintf('Coregistering\n');
    refImg = [mriDir getenv('recon_patientCode') '_orig.nii'];
    resliceImg = [getenv('recon_patientCode') '_ct_reoriented.img'];
    options.cost_fun = 'nmi';
    options.sep = [4 2 1];
    options.tol = [0.0200    0.0200    0.0200    0.0010    0.0010    0.0010    0.0100    0.0100    0.0100    0.0010    0.0010    0.0010];
    options.fwhm = [7 7];
    coregOut = spm_coreg(refImg, resliceImg, options);

    fprintf('Recalibrating header\n');
    MM = spm_get_space(resliceImg);        
    M  = inv(spm_matrix(coregOut));
    spm_get_space(resliceImg, M*MM);

    fprintf('Reslicing\n');
    P = strvcat(refImg,resliceImg);
    flags.mask = 0;
    flags.mean = 0;
    flags.interp = 1;
    flags.which = 1;
    flags.wrap = [0 0 0];
    flags.prefix = 'r';

    spm_reslice(P,flags);
    ctfile = [ctDir 'r' getenv('recon_patientCode') '_ct_reoriented.hdr,1'];
    mrifile = [mriDir getenv('recon_patientCode') '_orig.nii,1'];
    regFiles = char({mrifile,ctfile});
    
    spm_check_registration(regFiles);
     
    fprintf('\nFreesurfer is processing.  Please use the following registered CT to get electrode positions:\n');
    fprintf('Registered CT:   %s\n', [ctDir 'r' getenv('recon_patientCode') '_ct.hdr']);
    return
end