function config = CreateDataserverConfig()
    
    fprintf('One-time Configuration for dataserver access:\n');

    config = struct;

    config = PromptIfConfigIsNeeded(config,'DataServerUrl','Server URL');
    config = PromptIfConfigIsNeeded(config,'DataServerLoginName','Login name');
    config = PromptIfConfigIsNeeded(config,'DataServerRemoteDirectory','Location of data files on server (e.g. /m-gridlab/gridlab/subjects/)');    
    
    fprintf('Removing Putty warning\n');
    config = RemoveWarning(config);
    
    fprintf('Testing public/private key pair\n')
    config = CreatePrivateKeyPair(config);
    
    fprintf('\n\n Done! Data server script configured successfully\n');
end

function fullCmd = BuildNonPPKRemoteCmd(cmd, config, pass)
    exedir = [ myGetenv('matlab_devel_dir') '/Visualization/Recon/' ];
    exedir = strrep(exedir,'\','/');
    plinkpath = [exedir 'plink.exe'];
    pscppath  = [exedir 'pscp.exe'];
    puttyprivpath = [exedir 'puttypriv.ppk'];

    fullCmd = sprintf([plinkpath ' ' config.DataServerLoginName '@' config.DataServerUrl ' -pw ' pass ' "%s"'], cmd );
end

function fullCmd = BuildRemoteCmd(cmd, config)
    exedir = [ myGetenv('matlab_devel_dir') '/Visualization/Recon/' ];
    exedir = strrep(exedir,'\','/');
    plinkpath = [exedir 'plink.exe'];
    pscppath  = [exedir 'pscp.exe'];
    puttyprivpath = [exedir 'puttypriv.ppk'];

    fullCmd = sprintf([plinkpath ' ' config.DataServerLoginName '@' config.DataServerUrl ' -i ' config.PrivateKeyFile ' "%s"'], cmd );
end

function out = PromptIfConfigIsNeeded(config, fieldName, promptName)

    out = config;

    fieldExists = sum(ismember(fields(config),fieldName)) >= 1;
    
    if fieldExists
        fprintf('  %10s - %s\n', fieldName, config.(fieldName));
        return;
    end
    
    out.(fieldName) = input(sprintf('  %s => ',promptName),'s');
end

function out = RemoveWarning(config) 
    out = config;

    fieldExists = sum(ismember(fields(config),'RemovedWarning')) >= 1;
    
    if fieldExists 
        return
    end
    
    exedir = [ myGetenv('matlab_devel_dir') '/Visualization/Recon/' ];
    file = fopen([exedir 'removeWarning.bat'],'w');
    fprintf(file, 'echo y | %splink %s@%s', strrep([ myGetenv('matlab_devel_dir') '/Visualization/Recon/'],'/','\'),config.DataServerLoginName, config.DataServerUrl);
    fclose(file);
    [a b] = system([exedir 'removeWarning.bat']);
    out = config;
    out.RemovedWarning = 1;
end

function fullCmd = BuildNonPPKRemoteHomeToLocalTransfer(remoteFile, localFile, config, pass)

    

    exedir = [ myGetenv('matlab_devel_dir') '/Visualization/Recon/' ];
    exedir = strrep(exedir,'\','/');
    plinkpath = [exedir 'plink.exe'];
    pscppath  = [exedir 'pscp.exe'];
 
    fullCmd = sprintf([pscppath ' -pw ' pass ' ' config.DataServerLoginName '@' config.DataServerUrl ':./%s %s'], remoteFile, localFile);
end

function out = CreatePrivateKeyPair(config)
    out = config;

    fieldExists = sum(ismember(fields(config),'CreatedPrivateKeyPair')) >= 1;
    
    if fieldExists 
        return
    end
    
    pass = input(sprintf('Remote password for %s (note: not stored locally) =>',config.DataServerLoginName),'s');
    
%     fprintf('HARDCODED!!!\n');
%     pass = char('jbnfoefs2"' - 1); 
    
    privateKeyFile = floor(rand(1,1) * 100000);
    
    fprintf(' Generating remote keypair\n');
    cmd = sprintf('ssh-keygen -t rsa -P \\\"\\\" -f %i.privatekey', privateKeyFile);
    [a b] = system(BuildNonPPKRemoteCmd(cmd,config, pass));
    
    cmd = sprintf('mkdir ~/.ssh');
    [a b] = system(BuildNonPPKRemoteCmd(cmd,config, pass));
    
    fprintf(' Adding public key to .ssh authorized_keys\n');
    cmd = sprintf('cat %i.privatekey.pub >> ~/.ssh/authorized_keys', privateKeyFile);
    [a b] = system(BuildNonPPKRemoteCmd(cmd, config, pass));

    fprintf(' Retrieving private key\n');
    cmd = BuildNonPPKRemoteHomeToLocalTransfer(sprintf('%i.privatekey',privateKeyFile), sprintf('%i.privatekey',privateKeyFile), config, pass);
    [a b] = system(cmd);

    keyCreated = 0;
    while ~keyCreated

        response = '';
        
        ppkFile = strrep([myGetenv('matlab_devel_dir') '/Experiment/dataserver.ppk'], '/', '\');

        while(strcmp(response,lower('yes')) ~= 1 & strcmp(response,lower('"yes"')) ~= 1 & strcmp(response,lower('''yes''')) ~= 1) 
            
            fprintf('\n *********************************************************************\n');
            fprintf('\n');
            fprintf('              ATTENTION!!\n');
            fprintf('\n');
            fprintf(' *********************************************************************\n');
            beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);
            beep;pause(0.5);
            beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);beep;pause(0.2);
            fprintf(' * This step CANNOT be automated, so you must follow the directions! \n');
            fprintf(' *                                                                   \n');
            fprintf(' * You''ll be prompted with a window saying "imported successfully". \n');
            fprintf(' * You need to click okay. When the next window open, click          \n');
            fprintf(' *             "SAVE PRIVATE KEY"                                    \n');
            fprintf(' * It will prompt you to save the file.  When it asks to save without\n');
            fprintf(' * a passphrase, click yes. Save it as:                              \n');
            fprintf(' * %s \n', ppkFile);
            fprintf(' * Once it is saved, click "save", then close out of that program.   \n');
            fprintf(' *********************************************************************\n');
            fprintf('\n');

            response = input(' Confirm you have read this by typing "yes" here => ','s');
        end
        
        fprintf('Opening program\n');
        
        system(sprintf('%s\\Visualization\\Recon\\puttygen %i.privatekey',myGetenv('matlab_devel_dir'),privateKeyFile ));  
        
        files = dir([myGetenv('matlab_devel_dir') '/Experiment/dataserver.ppk']);

        if ~isempty(files) 
            keyCreated = 1;
            fprintf('Successfully created key!\n');
        else
            fprintf('\n\n\n\n******  FAILED TO FIND KEY FILE!  ******\n\n\t\tDid you make sure to save it as "recon" in the current directory?\n\n');
        end
    end
    
    
    out.PrivateKeyFile = 'dataserver.ppk';
    out.CreatedPrivateKeyPair = true;
end