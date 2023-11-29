% L314 Digital Signal Processing Assignment 4a
% HDMI Video Cable Eavesdropping
% Author = Joseph Cameron, CRSid = jmc276, MPhil ACS
% -------------------------------------------------------------------------
% AMPLITUDE DEMODULATION PART 5
% USE AUTO-CORRELATION TO AUTOMATE FP ESTIMATION
% -------------------------------------------------------------------------

% SETUP GLOBAL VARIABLES

% Sampling Frequency
Fs = 64e6;

% Total resolution transmitted per HDMI frame period
res = [800, 525];

% Initially use the approximate estimate of the frame rate
% to hone in on possible frame peak indexes of the auto-correlation.
fv = 60;

% -------------------------------------------------------------------------

% LOAD A DATA FILE
% Start with scene3-640x480-60-425M-64M-40M.dat

fid = fopen('scene3-640x480-60-425M-64M-40M.dat', 'r', 'ieee-le');
iq = fread(fid, [2, inf], 'single=>single');  fclose(fid);
iq = double(complex(iq(1,:), iq(2,:)));

% -------------------------------------------------------------------------

% NOTE: ALSO IMPORTANT TO GET PLOTS OF BOTH AUTO-CORRELATIONS

% AUTOMATE FP ESTIMATION (ALONG WITH FV AND FH) USING AUTO-CORRELATION

% First, the signal must be de-meaned before auto-correlation
%demeaned_iq = iq - mean(iq);
absolute_demeaned_iq = abs(iq) - mean(abs(iq));

% Taking the absolute value of the auto-correlation of the demeaned signal
%abs_auto_corr = abs(xcorr(demeaned_iq, demeaned_iq));
% Taking the auto-correlation of the absolute-value of the demeaned signal
auto_corr_abs = xcorr(absolute_demeaned_iq, absolute_demeaned_iq);

% ----------------------
% PLOT AUTO-CORRELATIONS
% plot(1:length(auto_corr_abs), auto_corr_abs)
% title('Auto-Correlation of the Absolute Value of IQ Data')
% xlabel('Samples')
% 
% plot(1:length(abs_auto_corr), abs_auto_corr)
% title('Absolute Value of the Auto-Correlation of IQ Data')
% xlabel('Samples')
% ----------------------

% Find the indexes of the peaks in the auto-correlation
[peaks, indexes] = findpeaks(auto_corr_abs, Fs, 'MinPeakDistance', 1/fv/4, 'MinPeakHeight', 0.009);

% Find the mean time between the peaks that occur for every frame
mean_time_between_frames = mean(rmoutliers(diff(indexes)));

% Use the mean time between frames to obtain the frame rate
fv = 1 / mean_time_between_frames;

% Now use frame rate to get the line rate
fh = fv * res(2);

% Now, fp can be automatically obtained from fh
fp = fh * res(1);

% -------------------------------------------------------------------------

% RESAMPLE IQ DATA AND DISPLAY A FRAME

% Change sampling frequency to an integer (m) multiple of fp
m = 3;
fr = m * fp;
iq_resampled = interp1(1:length(iq), iq, 1:Fs/fr:length(iq), "spline");

% Get the first frame as a 2D matrix and display it as a greyscale image
% To correctly align the image, an initial offset must be applied
offset = m * 210050; % 210050 gives a pixel-perfect alignment

% Get top half from top half of frame 1
top_half = iq_resampled(offset:offset+((fr/fv)/2)-1);
% Get bottom half from bottom half of frame 3
bottom_half = iq_resampled(offset+(3*(fr/fv))+((fr/fv)/2):offset+((4*(fr/fv))-1));
% Combine the two halves into one new frame
split_frame = [top_half bottom_half];
split_frame = abs(split_frame); % Amplitude Demodulation

% Reshape frame into a 800 x 525 2D matrix
X = size(split_frame);
split_frame_image = reshape(split_frame, m, X(2)/m);
split_frame_image = sum(split_frame_image, 1)./m;
split_frame_image = reshape(split_frame_image, [res(1), res(2)]).';

% Display the first frame as a greyscale image
figure(1)
image(split_frame_image, 'CDataMapping', 'scaled')
colormap(gray)
title('Top: Frame 1, Bottom: Frame 3, fp Automatically Estimated with Auto-Correlation')