%% genPID.m
%  jdw
%
% Changelog:
%   13APR2011 - originally written
%
% this function encodes a given subject id to a six character identifier
% that is non-descriptive and carries no intrinsic patient information.
% The first time that this script is run during any given matlab session,
% the user will be prompted to supply the conversion string that is used as
% the seed for generating the encoded patient identifiers.
%
% Parameters:
%   subjid - the subject id to encode
%
% Return Values:
%   pid - the encoded patient id
%
function pid = genPID(subjid)

    if lower(subjid(1)) == 'e' && lower(subjid(2)) == '_'
        pid = subjid(3:end);
        return;
    end

    pass = getenv('bci_encode_pass');
    if (length(pass) < 1)
        pass = input('input the bci conversion string: ', 's');
        setenv('bci_encode_pass', pass);
    end
    
    encodedIdLength = 6; % must be less than 65
    modulator = hash([subjid pass]);    
    pid = modulator(1:encodedIdLength);    
end

function h = hash(inp)
    inp=inp(:);
    % convert strings and logicals into uint8 format
    inp=uint8(inp);
    meth='SHA-256';
    x=java.security.MessageDigest.getInstance(meth);
    x.update(inp);
    h=typecast(x.digest,'uint8');
    h=dec2hex(h)';
    if(size(h,1))==1 % remote possibility: all hash bytes < 128, so pad:
        h=[repmat('0',[1 size(h,2)]);h];
    end
    h=lower(h(:)');
    clear x
end