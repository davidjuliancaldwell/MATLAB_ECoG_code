function transfer_boiler(fcn1,fcn2)
%TRANSFER_BOILER Transfer boilerplate code between functions.

% Copyright 2010 The MathWorks, Inc.

text1 = nntext.load(nnpath.fcn2file(fcn1));
[start1,stop1] = nncode.find_boiler(text1);
if start1 == 0
  disp(['WARNING: No boiler: ' fcn1]);
  return;
end

text2 = nntext.load(nnpath.fcn2file(fcn2));
[start2,stop2] = nncode.find_boiler(text2);
if start2 == 0
  disp(['WARNING: No boiler: ' fcn2]);
  return;
end

% Replace Function Interface
text2{1} = nnstring.replace(fcn1,fcn2,text1{1});

% Replace Boiler
text2 = [text2(1:(start2-1)); text1(start1:stop1); text2((stop2+1):end)]; 

% Replace Subfunction Interfaces
% TODO

% Save
nntext.save(nnpath.fcn2file(fcn2),text2);
clear(fcn2)
disp(['Updated boiler: ' fcn2])
