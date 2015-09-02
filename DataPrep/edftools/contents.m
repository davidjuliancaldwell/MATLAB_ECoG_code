% SIESTA EDF toolbox for Matlab. 
% Version 0.83,  21th Sep 2001
%
% University of Technology Graz, AUSTRIA.
% Copyright © 1996-2001 by Alois Schloegl
% a.schloegl@ieee.org
%
% High-level EDF-tools
%   EDF2EDF.M  converts EDF data (sampled with 100, 200 or 256Hz) into EDF data with a sampling rate of 100 or 200Hz. 
%   ASC2EDF.M  converts ASCII data to EDF (currently only 1 channel is implemented)
%
% Routines for accessing files in EDF-file [1]
%   SDFOPEN    opens EDF file and generates struct with the EDF-header information
%   SDFREAD    reads EDF data
%   SDFWRITE   writes EDF data
%   SDFCLOSE   closes and EDF file
%   SDFEOF     checks End-Of-File
%   SDFREWIND  sets Fileposition pointer to the start
%   SDFSEEK    sets fileposition point to a certain block number
%   SDFTELL    re-calls the file position in number of EDF-blocks
%   SDFERROR   error handling routine	
%
% The toolbox supports the following features: 
%    - re-referencing, 
%    - re-sampling (to a different sampling rate) on the fly [2] 
%    - Notch filtering (currently for 50Hz only) (#)
%    - filtering on-the-fly (#)
%    - support of minimizing the ECG artifact in the EEG with regression method and template removal [2,3] (#)
%    - adaptive FIR filter routines [4] from Mikko Koivuluoma, Tampere University of Technology are included. (#) 
%    - Random access of data (block limits are hidded) 
%    - support of efficient data access (optimize for speed or memory)
%    - overflow (saturation check)
%    - failing electrode detection in slepp EEG (#)   
%
% (#) These features require an internal buffer; then, a sequential access of the data is recommended (otherwise, undefined state)
%
% Future: 
%    - Failing electrode detector, based on overflow detection and flat line detector, method optimized by the artifact database [5]
%    - 
%
%
% REFERENCES:
% [1] Bob Kemp, Alpo Värri, Agostinho C. Rosa, Kim D. Nielsen and John Gade
%     A simple format for exchange of digitized polygraphic recordings"
%     Electroencephalography and Clinical Neurophysiology, 82 (1992) 391-393.
% [2] A. Schloegl (2000) 
%     The electroencephalogram and the adaptive autoregressive model: theory and applications. 
%     [a] PhD-thesis, University of Technology Graz, Austria.
%     [b] ISBN 3-8265-7640-3, Shaker Verlag, Aachen, Germany. 
% [3] K. C. Harke, A. Schlögl, P. Anderer, G. Pfurtscheller (1999) 
%     Cardiac field artifact in sleep EEG, 
%     Proceedings EMBEC'99, Part I, pp.482-483, 4-7. Nov. 1999, Vienna, Austria. 
% [4] Sahul, Z., Black, J., Widrow, B. and Guilleminault, C. 
%     EKG artifact cancellation from sleep EEG using adaptive filtering. 
%     Sleep Research, 24A: 486, 1995.
% [5] A. Schlögl, P. Anderer, M.-J. Barbanoj, G. Klösch, G. Gruber, J.L. Lorenzo, O. Filz, M. Koivuluoma, I. Rezek, S.J. Roberts, A. Värri, P. Rappelsberger, G. Pfurtscheller, G. Dorffner 
%     Artifact processing of the sleep EEG in the "SIESTA"-project, 
%     Proceedings EMBEC'99, Part II, pp.1644-1645, 4-7. Nov. 1999, Vienna, Austria. 
% [6] A. Schlögl, P. Anderer, M.-J. Barbanoj, G. Dorffner,  G. Gruber, G. Klösch, J.L. Lorenzo, P. Rappelsberger, G. Pfurtscheller. 
%     Artifacts in the sleep EEG - A database for the evaluation of automated processing methods. 
%     Sleep Research Online 1999;2 (Supplement 1) p.586.  
%

