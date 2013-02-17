function Hd = CH20
%CH20 Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.14 and the Signal Processing Toolbox 6.17.
%
% Generated on: 04-Dec-2012 10:49:14
%

% Chebyshev Type II Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = 128;  % Sampling Frequency

N      = 4;   % Order
Fstop1 = 10;  % First Stopband Frequency
Fstop2 = 13;  % Second Stopband Frequency
Astop  = 20;  % Stopband Attenuation (dB)

% Construct an FDESIGN object and call its CHEBY2 method.
h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, Fs);
Hd = design(h, 'cheby2');

% [EOF]
