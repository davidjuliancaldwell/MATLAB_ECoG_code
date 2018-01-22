function flag = same_files(file1,file2)

% Copyright 2010 The MathWorks, Inc.

ext1 = nnpath.extension(file1);
ext2 = nnpath.extension(file2);
if ~strcmp(ext1,ext2)
  flag = false;
  return
end
  
if nnpath.is_text_ext(ext1) || nnpath.is_text_file(file1)
  text1 = nntext.load(file1);
  text2 = nntext.load(file2);
  if length(text1) ~= length(text2)
    flag = false;
    return
  end
  for i=1:length(text1)
    t1 = text1{i};
    t2 = text2{i};
    if (~isempty(strfind(t1,'$Revision'))) && (~isempty(strfind(t2,'$Revision')))
      continue;
    end
    if (~isempty(strfind(t1,'Copyright'))) && (~isempty(strfind(t2,'Copyright')))
      continue;
    end
    if length(t1) ~= length(t2)
      flag = false;
      return
    end
    if any(t1 ~= t2)
      flag = false;
      return
    end
  end
  flag = true;

% BINARY
elseif nnpath.is_binary_ext(ext1)
  dir1 = dir(file1);
  dir2 = dir(file2);
  if dir1.bytes ~= dir2.bytes
    flag = false;
    return
  end
  fid1 = fopen(file1,'r');
  bin1 = fread(fid1);
  fclose(fid1);
  fid2 = fopen(file2,'r');
  bin2 = fread(fid2);
  fclose(fid2);
  if length(bin1) ~= length(bin2)
    flag = false;
    return;
  end
  if any(bin1 ~= bin2)
    flag = false;
    return;
  end
  flag = true;

% UNRECOGNIZED
else
  file1
  file2
  nnerr.throw(['Unrecognized extension: ' ext1])
end
