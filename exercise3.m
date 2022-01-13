close all; clear all;   % clear all plots and variables
%
% create the test signal
%
fs=4000;                % sample frequency
xfa=[80 0.5; 100 -1i];  % signal frequencies and phasor amplitudes
vfa=[210 1; 280 0.5];   % tonal noise frequencies and phasor amplitudes
snr=-8;                	% white noise SNR in dB
nt=round(4*fs);         % 4 seconds worth of samples 
[y,t,x,v]=mb1_testsig(xfa,vfa,snr,nt,fs); % y=test signal, t=time axis, x=clean signal, v=noise signal
[snr0,att,ett,ztt,xtt]=mb1_snrtone(y,xfa,fs); % Find the SNR of the noisy signal
%
% plot the signal and its power spectrum
%
fplot=300;              % max frequency to plot
fax=linspace(0,fplot,100); % frequncy axis for magnitude responses
iplot=0.1*fs:0.2*fs;    % samples to plot 
% 
% now design a butterworth IIR filter
%
rp=0.1;                 % target passband ripple (dB)
rs=35;                  % target stopband attenuation (dB)
ftr=[100 200];          % transition frequency range: 100 to 200 Hz
[n2,wp2]=ellipord(2*ftr(1)/fs,2*ftr(2)/fs,rp,rs); % determine order and f0
fprintf('The order of the filter is %d\n',n2);
[b2,a2]=ellip(n2,rp,rs,wp2); % design a elliptic filter

z1=filter(b2,a2,y);     % filter the noisy signal, y
[snr2,ax2,e2,v2]=mb1_snrtone(z1,xfa,fs);  % find the filtered SNR, gain errors and residual noise
fprintf('The resultant SNR after filtering is %.2fdB \n',snr2);
%% pz plot
figure()
zplane(b2,a2); % plot zeros and poles
title(sprintf('Poles and Zeros for elliptic filter with order %d',n2));
%% Phase response and group delay
[h2,w2] = freqz(b2,a2,fax*2*pi/fs); %define BW filter
angle_unwrap = unwrap(angle(h2)); % unwrap
figure()
subplot (2,1,1)
plot(fax, angle_unwrap); 
title(sprintf('Elliptic Filter Order %d, SNR = %.1f dB',n2,snr2));
grid on
xlabel('Frequency (Hz)');
ylabel('Phase (radian)');
set(gca,'yTick',[-4*pi:pi/2:0])
set(gca,'ytickLabel',{'-4¦Ð','-7/2¦Ð','-3¦Ð','-5/2¦Ð','-2¦Ð','-3/2¦Ð','-¦Ð','-¦Ð/2','0'})
subplot(2,1,2);
grpdelay(b2, a2, fax*2*pi/fs); % plot the group delay

%% PSD and magnitude response
figure();
subplot(2,1,2);
mb1_plotpsd(v2,fplot,fs);           % plot PSD of residual noise
axis([fax(1) fax(end) -90 -20]);      % limit the gain range to -60 dB
texthvc(0.02,0.1,['Gains:' sprintf('\n%.0fHz: %+.1fdB \\angle%+.0f^\\circ',[xfa(:,1) e2(:,1) e2(:,2)*180/pi]')],'LBk');
ylabel('Noise PSD (dB)');
subplot(2,1,1);
plot(fax,20*log10(abs(freqz(b2,a2,fax*2*pi/fs)))); % plot the magnitude response
axis([fax(1) fax(end) -85 4]);      % limit the gain range to -60 dB
xlabel('Frequency (Hz)');
ylabel('Gain (dB)');
title(sprintf('Elliptic Filter Order %d, SNR = %.1f dB',n2,snr2));
%
tilefigs([0 0.5 0.8 0.5]);   % display all the figures in the top half of the screen