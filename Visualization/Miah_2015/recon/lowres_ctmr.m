function lowres_ctmr(patientCode, brainExtractComplete)

fprintf('WARNING WARNING! - Outdated, not guaranteed to work...');
if ~exist('patientCode')
    patientCode = input('Patient code: ','s');
end
baseDir = ['c:\research\data\patients\' patientCode '\'];
mriDir = ['c:\research\data\patients\' patientCode '\mri\'];
ctDir = ['c:\research\data\patients\' patientCode '\ct\'];
surfDir = ['c:\research\data\patients\' patientCode '\surf\'];

try mkdir(basedir); catch e; end;
try mkdir(surfDir); catch e; end;


if ~exist('brainExtractComplete') || brainExtractComplete == 0
    %%%%%%%%%%%%%%%%%%%%%%
    %    PROCESS MRI
    %%%%%%%%%%%%%%%%%%%%%%
    fprintf('** Processing MRI\n');
    % % c:\research\data\patients\kai_email\
    curDir = pwd;
    cd([mriDir '\rawdicom\']);
    % mriFile = uigetfile('*.dcm');
    dicomFiles = dir('*.dcm');
    
    
    dicomFiles = {dicomFiles.name}';
    
    fileType = lower(dicomFiles{1}(find(dicomFiles{1} == '.', 1, 'last')+1:end));
    
    switch fileType
        case 'dcm'
            fprintf('Dicom file\n');
            
            dicomFiles = sortrows(dicomFiles([2:13 1 14:end]));
            for i=1:size(dicomFiles,1)
                dicomFiles(i) = {[[mriDir '\rawdicom\'] dicomFiles{i}]};
            end
            
            cd(mriDir);     %To make sure we're in the MRI directory once we read/save the file
            fprintf('Reading dicom header\n');
            hdr = spm_dicom_headers(strvcat(dicomFiles), true);
            fprintf('Concateniating dicom files\n');
            dicomOut = spm_dicom_convert(hdr,'all','flat','img');
            
            movefile(dicomOut.files{1},[patientCode '_mri.img']);
            movefile([dicomOut.files{1}(1:find(dicomOut.files{1} == '.',1, 'last')) 'hdr'], [patientCode '_mri.hdr']);
            
            fprintf('Coregistering\n');
            refImg = 'c:\research\data\patients\janb10c\mri\orig.nii';
            resliceImg = [patientCode '_mri.hdr'];
            options.cost_fun = 'nmi';
            options.sep = [4]; %FIXME - should be [4 2 1], just using 4 for speed
            options.tol = [0.0200    0.0200    0.0200    0.0010    0.0010    0.0010    0.0100    0.0100    0.0100    0.0010    0.0010    0.0010];
            options.fwhm = [7 7];
            coregOut = spm_coreg(refImg, resliceImg, options);
            
            fprintf('Recalibrating header\n');
            MM = spm_get_space(resliceImg);        
    %         M  = inv(spm_matrix(coregOut));
    %         spm_get_space(resliceImg, M*MM);
            M  = spm_matrix(coregOut);
            spm_get_space(resliceImg, M\MM);        
            
            
            fprintf('Reslicing\n');
            P = strvcat(refImg,resliceImg);
            flags.mask = 0;
            flags.mean = 0;
            flags.interp = 1;
            flags.which = 1;
            flags.wrap = [0 0 0];
            flags.prefix = 'r';
            
            spm_reslice(P,flags);
            
        otherwise
            fprintf('Type %s not supported\n', fileType);
    end
    
    cd(curDir);

    %%%%%%%%%%%%%%%%%%%%%%
    %     NU SCALING
    %%%%%%%%%%%%%%%%%%%%%%
    fprintf('** Performing NU Scaling\n');

    cd(mriDir);
    fprintf('Creating remote directory...\n');
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\plink.exe -load "auto_nrs" mkdir /warehouse/freesurfer/autoscript/%s', patientCode);
    [a b] = system(cmd);fprintf('%s',b);
    fprintf('Copying local file to server...\n');
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\pscp.exe -load "auto_nrs" %s appserver.cs.washington.edu:/warehouse/freesurfer/autoscript/%s/%s',['r' patientCode '_mri.hdr'], patientCode, ['r' patientCode '_mri.hdr']);
    [a b] = system(cmd);fprintf('%s',b);
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\pscp.exe -load "auto_nrs" %s appserver.cs.washington.edu:/warehouse/freesurfer/autoscript/%s/%s',['r' patientCode '_mri.img'], patientCode, ['r' patientCode '_mri.img']);
    [a b] = system(cmd);fprintf('%s',b);
    fprintf('Converting to mgz format...\n');
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\plink.exe -load "auto_nrs" cd /warehouse/freesurfer/autoscript/%s/; mri_convert %s %s', patientCode, ['r' patientCode '_mri.hdr'], ['r' patientCode '_mri.mgz']);
    [a b] = system(cmd);fprintf('%s',b);
    fprintf('Running NU correction (may take a while)...\n');
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\plink.exe -load "auto_nrs" cd /warehouse/freesurfer/autoscript/%s/; mri_nu_correct.mni --i %s --o %s_mri_nu.mgz --n 2', patientCode, ['r' patientCode '_mri.mgz'], patientCode);
    [a b] = system(cmd);fprintf('%s',b);
    fprintf('Zipping result...\n');
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\plink.exe -load "auto_nrs" cd /warehouse/freesurfer/autoscript/%s/; mri_convert %s_mri_nu.mgz %s -odt int', patientCode, patientCode, ['r' patientCode '_mri_nu.nii.gz']);
    [a b] = system(cmd);fprintf('%s',b);
    fprintf('Fetching result...\n');
    cmd = sprintf('C:\\Research\\Scripts\\External\\ssh\\pscp.exe -load "auto_nrs" appserver.cs.washington.edu:/warehouse/freesurfer/autoscript/%s/%s %s',patientCode, ['r' patientCode '_mri_nu.nii.gz'], ['r' patientCode '_mri_nu.nii.gz']);
    [a b] = system(cmd);fprintf('%s',b);
    fprintf('Unzipping...\n');
    gunzip(['r' patientCode '_mri_nu.nii.gz']);
    fprintf('Successfully performed NU scaling\n');
    cd(curDir);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     NEED TO EXTRACT BRAIN
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('Please extract the brain using BioImage suite.\n 1. Histogram brain to make skull/brain separation more obvious\n 2. Use BET\nIMPORTANT: Do not change the expected filenames!!\n');
    beep; pause(0.3); beep;
    return;
end

copyfile([mriDir 'Histeq_r' patientCode '_mri_nu_stripped.nii'], [mriDir patientCode '_brain.nii']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Create Surface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('** Showing example surface...\n');
% 
% brainVol = spm_vol([mriDir patientCode '_brain.nii']);
% brainVol = double(brainVol.private.dat);
% cortex = isosurface(brainVol,0);
% cortex.vertexnormals  = isonormals(smooth3(brainVol),cortex.vertices);
% cortex.facevertexcdata = zeros(size(cortex.vertexnormals,1),1);
% cortex.vertices = cortex.vertices(:,[2 3 1]) * [1 0 0; 0 -1 0; 0 0 -1];
% cortex.vertexnormals = cortex.vertexnormals(:,[2 3 1]) * [1 0 0; 0 -1 0; 0 0 -1];
% %
% figure; 
% patch(cortex,'edgecolor','none','facecolor','interp'); 
% axis equal; 
% camlight('headlight');
% view(90, 0);
% load('loc_colormap');
% colormap(cm);
% % eval(sprintf('save %s%s_cortex.mat cortex', surfDir, patientCode));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Align CT to MRI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('** Processing CT\n');

cd([ctDir '\rawdicom\']);
% [ctFile ctDirectory] = uigetfile('*.dcm');
dicomFiles = dir('*.dcm');
cd(ctDir);

dicomFiles = {dicomFiles.name}';

fileType = lower(dicomFiles{1}(find(dicomFiles{1} == '.', 1, 'last')+1:end));

switch fileType
    case 'dcm'
        fprintf('Dicom file\n');
        
        dicomFiles = sortrows(dicomFiles([2:13 1 14:end]));
        for i=1:size(dicomFiles,1)
            dicomFiles(i) = {[[ctDir '\rawdicom\'] dicomFiles{i}]};
        end
        fprintf('Reading dicom header\n');
        hdr = spm_dicom_headers(strvcat(dicomFiles), true);
        fprintf('Concateniating dicom files\n');
        dicomOut = spm_dicom_convert(hdr,'all','flat','img');
        
        movefile(dicomOut.files{1},[patientCode '_ct.img']);
        movefile([dicomOut.files{1}(1:find(dicomOut.files{1} == '.',1, 'last')) 'hdr'], [patientCode '_ct.hdr']);
    
        fprintf('Coregistering\n');
        refImg = [mriDir 'r' patientCode '_mri_nu.nii'];
        resliceImg = [patientCode '_ct.img'];
        options.cost_fun = 'nmi';
        options.sep = [4];
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
        
    otherwise
        fprintf('Type %s not supported\n', fileType);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     COMPLETE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Script completed!!!\n');
fprintf('Best MRI:        %s\n', [mriDir 'r' patientCode '_mri_nu.nii']);
fprintf('Registered CT:   %s\n', [ctDir 'r' patientCode '_ct.nii']);
fprintf('Extracted brain: %s\n', [mriDir patientCode '_brain.nii']);
