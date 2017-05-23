function A = morsearea(C,ga,be)
%MORSEAREA  Time-frequency concentration area of Morse wavelets. [with F. Rekibi]
%
%   A=MORSEAREA(C,GAMMA,BETA) calculates the area of time/frequency
%   concentration region for the generalized Morse wavelets specified by
%   parameters C, GAMMA, and BETA. 
%  
%   The input parameters may either be arrays of the same size, or some
%   may be arrays and the others scalars.  
% 
%   MORSEAREA uses the area formula of Olhede and Walden (2002),
%   "Generalized Morse Wavelets", at the bottom right of page 2664, 
%   multiplied by a factor of 1/2 to obtain a "one-sided" version.  
%
%   See also MORSECFUN, MORSEREGION.
%
%   'morsearea --f' generates a sample figure.
%
%   Usage: A = morsearea(C,ga,be);
%   _________________________________________________________________
%   This is part of JLAB --- type 'help jlab' for more information
%   (C) 2004--2016 F. Rekibi and J. M. Lilly 
%                         --- type 'help jlab_license' for details  

if strcmpi(C,'--f')
  type makefigs_morsearea
  makefigs_morsearea;
  return
end

r=((2*be)+1)./ga;
A=pi*(C-1).*gamma(r+1-(1./ga)).*gamma(r+(1./ga))./(ga.*gamma(r).^2);

%omtilde=frac(1,2.^(1./ga)).*frac(gamma((2*be+2)./ga),gamma((2*be+1)./ga));
%ttilde=frac(2.^(1./ga),2).*frac(gamma((2*be+ga)./ga),gamma((2*be+1)./ga));
%A2=2*pi*(C-1)./ga.*omtilde.*ttilde;
%aresame(A,A2,1e-8)

%Note this differs from Olhede and Walden by a factor of 1/2

