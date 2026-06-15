clc;
clear;
close all;

% Go to data folder
cd('C:\ECG Signal Analysis Matlab\Data')

clc;
clear;
close all;

cd('C:\ECG Signal Analysis Matlab\Data')

Fs = 360;

% Read full file
fid = fopen('100.dat','r');
raw = fread(fid, 'int16');
fclose(fid);

% IMPORTANT FIX:
% take first channel only after proper decimation
ecg = double(raw);
ecg = ecg(1:3600);   % take first 10 seconds ONLY (important)

t = (0:length(ecg)-1)/Fs;

plot(t, ecg)
title('ECG (Unprocessed but Correct Segment)')

Fs = 360;
t = (0:length(ecg)-1)/Fs;

% Plot raw ECG
figure;
plot(t, ecg)
title('Raw ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude')

% SAVE
saveas(gcf, '../results/step1_raw_ecg.png')

% Remove baseline
ecg = ecg - mean(ecg);

% Bandpass filter
Fs = 360;

bp = designfilt('bandpassiir', ...
    'FilterOrder', 4, ...
    'HalfPowerFrequency1', 0.5, ...
    'HalfPowerFrequency2', 40, ...
    'SampleRate', Fs);

ecg_filt = filtfilt(bp, ecg);

% Plot filtered signal
figure;
plot(t, ecg_filt)
title('Filtered ECG Signal')
xlabel('Time (s)')
ylabel('Amplitude')

% SAVE
saveas(gcf, '../results/step2_filtered_ecg.png')

% Detect peaks (R-peaks)
minDist = round(0.25 * Fs);  % at least 250 ms between beats

[peaks, locs] = findpeaks(ecg_filt, ...
    'MinPeakDistance', minDist, ...
    'MinPeakHeight', 0.5 * max(ecg_filt));
% Plot peaks
figure;
plot(t, ecg_filt)
hold on
plot(locs/Fs, peaks, 'ro')

title('R-Peak Detection')
xlabel('Time (s)')
ylabel('Amplitude')

% SAVE
saveas(gcf, '../results/step3_r_peaks.png')

% Heart rate calculation
RR_intervals = diff(locs) / Fs;
heart_rate = 60 / mean(RR_intervals);

