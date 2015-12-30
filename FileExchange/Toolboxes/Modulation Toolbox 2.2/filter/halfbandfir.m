function b = halfbandfir(N,fp,varargin)
%
% HALFBANDFIR  Halfband FIR filter design.
%   B = HALFBANDFIR(N,Fp) designs a lowpass N-th order
%   halfband FIR filter with an equiripple characteristic.
%
%   The filter order N is an element of {2,6,10,14,18,..., n,n+4,...}.
%   Fp determines the passband edge frequency that must satisfy
%   0 < Fp < 1/2 where 1/2 corresponds to pi/2 [rad/sample].
%
%   B = HALFBANDFIR('minorder',Fp,Dev) designs the minimum
%   order halfband FIR filter, with passband edge Fp and ripple Dev.
%   Dev is a passband ripple that must satisfy 0<Dev (linear)<1/2
%   or stopband attenuation that must satisfy Dev (dB) > 6.2
% 
%   B = HALFBANDFIR(...'high') returns a highpass halfband filter.
%
%   EXAMPLE: Design a minimum order halfband filter with the given max ripple
%      b=halfbandfir('minorder',.45,0.0001);
%
%   Authors: Miroslav Lutovac  and  Ljiljana Milic
%   lutovac@kondor.etf.bg.ac.yu     milic@kondor.imp.bg.ac.yu
%   http://kondor.etf.bg.ac.yu/~lutovac
%   http://galeb.etf.bg.ac.yu/~milic
%   Copyright (c) 2003 Miroslav Lutovac and Ljiljana Milic
%   $Revision: 2.1 $  $Date: 2003/04/02 12:22:33 $

% This file is part of EMF toolbox for MATLAB.
% Refer to the file LICENSE.TXT for full details.
%                        
% EMF version 2.1, Copyright (c) 2003 M. Lutovac and Lj. Milic
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; see LICENSE.TXT for details.
%                       
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%                       
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc.,  59 Temple Place,  Suite 330,  Boston,
% MA  02111-1307  USA,  http://www.fsf.org/

error(nargchk(2,4,nargin));

[minOrderFlag,lowpassFlag,msg] = validateParseInput(N,fp,varargin{:});
error(msg);

if minOrderFlag,
  if varargin{1} <1
    delta = varargin{1};
  else
    delta = 10^(-varargin{1}/20);
  end
  N = estimateOrder(fp,delta);
end

if N < 2, N = 2; end
if N == 2
  a = 1/(1+cos(pi*fp))/2;
  b = [a 0.5 a];
elseif N == 6
  t = cos(pi*fp);
  c = (3*(-9*t-9*t^2+2*3^(1/2)*((1+t+t^2)^3)^(1/2)))/(4*(-2+t+t^2)^2);
  a = (-9+3^(1/2)*((3-4*c)^3)^(1/2)+18*c-6*c^2)/(-36 + 54*c);
  b = [a 0 c 1 c 0 a]/2;
elseif N == 10
  xp = hbfp2xp(fp/2);
  ri = xp^2:(1-xp^2)/10^3:1;
  for ind = 1: length(ri)
    xpi(ind) = hbfr2xp(ri(ind));
  end
  [minR,indR] = min(abs(xpi-xp));
  indRmin = 1; indRmax = length(ri);
  if indR > 1,   indRmin = indR-1; end
  if indR < length(ri),   indRmax = indR+1; end
  ri = ri(indRmin):(ri(indRmax)-ri(indRmin))/10^3:ri(indRmax);
  for ind = 1: length(ri)
    xpi(ind) = hbfr2xp(ri(ind));
  end
  [minR,indR] = min(abs(xpi-xp));
  indRmin = 1;indRmax = length(ri);
  if indR > 1,   indRmin = indR-1; end
  if indR < length(ri),   indRmax = indR+1; end
  ri = ri(indRmin):(ri(indRmax)-ri(indRmin))/10^3:ri(indRmax);
  for ind = 1: length(ri)
    xpi(ind) = hbfr2xp(ri(ind));
  end
  [minR,indR] = min(abs(xpi-xp));
  r = ri(indR);
  [xp,q] = hbfr2xp(r);
  f1 = acos(sqrt(r))/(2*pi);
  f2 = acos(sqrt(q))/(2*pi);
  m5 = fliplr([0 15*q*r 0 (-5*q-5*r) 0 3]);
  m5max = polyval(m5,1);
  m5min = polyval(m5,sqrt(q));
  M5 = m5/(m5max+m5min);
  a  = M5(1)/16;
  d  = (M5(3) + 20*a)/4;
  c  = M5(5) - 5*a + 3*d;
  b  = [a 0 d 0 c 1 c 0 d 0 a]/2;
else
  b = remezDesign(N,fp);
end

% Convert to highpass
if ~lowpassFlag,
  b = b.*((-(ones(size(b)))).^(1:length(b)));
end

if minOrderFlag,
  h1 = min(abs(sum(b)),abs(1-abs(sum(b))));
  if h1 > varargin{1};
    msg = ['Dev_designed=' num2str(h1) ' > Dev_specified=' ...
           num2str(varargin{1}) ', increase order or Dev'];
    error(msg);
  end
end

%-------------------------------------------------------------
function N = estimateOrder(fp,Dev)
  N = remezOrder(fp,Dev);
  N = adjustOrder(N);
  b = halfbandfir(N,fp);
  h1 = min(abs(sum(b)),abs(1-abs(sum(b))));
  if h1 > Dev;
    N = N+4;
  end
	
%-------------------------------------------------------------
function N = adjustOrder(N)
  while ((N+2) ~= 4*fix((N+2)/4)),
    N = N + 1;
  end

%-------------------------------------------------------------
function b = remezDesign(N,fp)
% Design of Optimal Halfband FIR Filter
  if version('-release')>=14, 
    b = firpm(N,[0 fp 1-fp 1],[1 1 0 0]);
  else
    b = remez(N,[0 fp 1-fp 1],[1 1 0 0]);
  end;
  b(2:2:end) = 0;
  b(N/2+1) = 1/2;

%-------------------------------------------------------------
function [minOrderFlag,lowpassFlag,msg] = validateParseInput(N,fp,varargin)
  msg = '';
  minOrderFlag = 0;
  lowpassFlag = 1;

  if nargin > 2 & ischar(varargin{end}),
    stringOpts = {'low','high'};
    lpindx = strmatch(lower(varargin{end}),stringOpts);
    if ~isempty(lpindx) & lpindx == 2,
      lowpassFlag = 0;
    end
  end
  if ischar(N),
    ordindx = strmatch(lower(N),'minorder');
    if ~isempty(ordindx),
      minOrderFlag = 1;
      if nargin < 3,
        msg = 'Peak ripple, Dev, must be specified for minimum order design.';
        return
      end
      if ~isValidScalar(varargin{1}),
        msg = 'Peak ripple must be a scalar.';
        return
      elseif varargin{1} <= 0 | ((varargin{1} >= 0.5)&(varargin{1} <= 6.2)) ,
        msg = ['Dev=' num2str(varargin{1}) ', it must be 0<Dev(linear)<0.5, or Dev (dB) >6.2'];
        return
      end
    else
      msg = 'Specified unrecognized order.';
      return
    end
  elseif ~isValidScalar(N),
    msg = 'Specified unrecognized order.';
    return
  else
    if ((N+2) ~= 4*fix((N+2)/4)),
      msg = ['N=' num2str(N) ', order must be element of {2,6,10,14,18,...,n,n+4,...}'];
      return
    end
    if nargin > 2 & ~ischar(varargin{1}),
      msg = 'Peak ripple, Dev, can be specified for minimum order design, only.';
      return
    end
  end
  if length(fp) ~= 1,
    msg = ['Length of Fp = ' num2str(length(fp)) ', length must be 1.'];
    return
  else,
    if ~isValidScalar(fp),
      msg = 'Passband edge frequency must be a scalar, 0<Fp<1/2.';
      return
    end
    if fp <= 0 | fp >= 0.5,
      msg = ['Fp=' num2str(fp) ', passband edge frequency must satisfy 0<Fp<1/2.'];
      return
    end
  end

%------------------------------------------------------------------------
function bol = isValidScalar(a)
  bol = 1;
  if ~isnumeric(a) | isnan(a) | isinf(a) | isempty(a) | length(a) > 1,
    bol = 0;
  end

%------------------------------------------------------------------------
function [xp,q] = hbfr2xp(r)
  q= 3/5 + (2*r/5)*((2+sqrt(r))/(1+2*sqrt(r)));
  P = r/q;
  xp = sqrt(q)/3*(-2 + 5^(1/3)*(6*P-1-sqrt(-5*P^3+(6*P-1)^2))^(1/3)+...
                     5^(1/3)*(6*P-1+sqrt(-5*P^3+(6*P-1)^2))^(1/3));

%------------------------------------------------------------------------
function xp = hbfp2xp(fp)
  xp = cos(2*fp*pi);

%------------------------------------------------------------------------
function N = remezOrder(fp,Dev);
A = abs(log10(abs(Dev)));
N = fix(1-11.01217*(0.5-fp)+(-0.005309*(A)^3+0.06848*(A)^2+1.0702*A-0.4278)/(0.5-fp));

% ------- [EOF] ---------------------------------------------------------
