function [condPtsPos,condPtsNeg,testPts] = extract_testPulse(stims)

testPts = stims(3,:) == 0;

condPtsPos = stims(3,:)==1 & stims(8,:)==1;
condPtsNeg = stims(3,:)==1 & stims(8,:)==0;

end

