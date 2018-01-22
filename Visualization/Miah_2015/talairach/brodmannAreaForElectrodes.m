function areas = brodmannAreaForElectrodes(trodes, runLocal)
    if (~exist('runLocal','var'))
        runLocal = false;
    end
    
    root = fileparts(which('brodmannAreaForElectrodes'));    
    tempfile = fullfile(root, 'rawlocs.txt');
    
    fid = fopen(tempfile, 'w');

    for c = 1:size(trodes,1)
        fwrite(fid, sprintf('%f\t%f\t%f\n', trodes(c,1), trodes(c,2), trodes(c,3)));
    end

    fclose(fid);

    % run the client
    jarpath = fullfile(fileparts(which('brodmannAreaForElectrodes')), 'TalairachClient', 'TalairachClient', 'talairach.jar');
%     jarpath = fullfile('d:\Dropbox\code\me\sandbox\talairach', 'TalairachClient', 'TalairachClient', 'talairach.jar');

    % figure out where the jre is located on this machine (i'm sure there's
    % a better way to do this)
    foo = which('cd');
    res = regexpi(foo, '\((.*?)toolbox.*\)', 'tokens');
    javapath = fullfile(res{1}{1}, 'sys', 'java', 'jre', computer('arch'), 'jre', 'bin', 'java.exe');
    
    if (runLocal)
        warning('if the talairach daemon is not running locally on your machine this code will fail.  You can probably execute it by running the batch file in %s', fileparts(jarpath));
        
        clicmd = sprintf('"%s" -cp %s org.talairach.ExcelToTD 4, %s host=localhost:1600', javapath, jarpath, tempfile);
    %     [~, ~] = system(cmd); % silenced
        system(clicmd)
        
    else
%         cmd = sprintf('c:\\windows\\sysWOW64\\java -cp %s org.talairach.ExcelToTD 4, %s', jarpath, tempfile);
        clicmd = sprintf('"%s" -cp %s org.talairach.ExcelToTD 4, %s', javapath, jarpath, tempfile);
    %     [~, ~] = system(cmd); % silenced
        system(clicmd)
    end
    
    pause(.5); % wait for file to be written
    
    % read in the result
    retfile = [tempfile '.td'];
    fid = fopen(retfile, 'r');

    tline = fgetl(fid);
    counter = 0;

    while ischar(tline)
        counter = counter + 1;
        [~,~,~,d] = regexp(tline, 'Brodmann area (\d+)', 'match');

        if (~isempty(d))
            areas(counter) = str2num(tline(d{:}(1):d{:}(2)));
        else
            areas(counter) = NaN;
        end

        tline = fgetl(fid);
    end

    fclose(fid);
    
    delete(tempfile, retfile);
end