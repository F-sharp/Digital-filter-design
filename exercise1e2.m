close all; clear all;   % clear all plots and variables
%
% create the test signal
%
fs=4000;                % sample frequency
xfa=[80 0.5; 100 -1i];  % signal frequencies and phasor amplitudes
vfa=[210 1; 280 0.5];   % tonal noise frequencies and phasor amplitudes
snr=-8;                	% white noise SNR in dB
nt=round(4*fs);         % 4 seconds worth of samples 
snrf = 0;
for i = 1:300
    [y,t,x,v]=mb1_testsig(xfa,vfa,snr,nt,fs); % y=test signal, t=time axis, x=clean signal, v=noise signal

%% filter y
n = size(y,1);
attenuation_factor = 0.362;
Y = fftshift(fft(y));
index = (-n/2:n/2-1)*(fs/n);
filterBP = zeros(n,1)+ attenuation_factor;
filterBP(find(index == -100):find(index == 100))= ones(n/fs*200+1,1);
filterBP(find(index == -80)+1:find(index == 80)-1)= zeros(n/fs*160-1,1);
Y_filtered = Y.*filterBP;
y_filtered = ifft(ifftshift(Y_filtered));

%% Calculate SNR
snrBP=mb1_snrtone(y_filtered,xfa,fs);
snrf = snrf+snrBP;
end
snrf = snrf/300;
attenuation_factor_dB = mag2db(attenuation_factor)