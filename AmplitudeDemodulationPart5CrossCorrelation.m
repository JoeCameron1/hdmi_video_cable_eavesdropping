% L314 Digital Signal Processing Assignment 4a
% HDMI Video Cable Eavesdropping
% Author = Joseph Cameron, CRSid = jmc276, MPhil ACS
% -------------------------------------------------------------------------
% AMPLITUDE DEMODULATION PART 5
% USE CROSS-CORRELATION TO AUTOMATE FP ESTIMATION
% -------------------------------------------------------------------------

% SETUP GLOBAL VARIABLES

% Sampling Frequency
Fs = 64e6;

% Total resolution transmitted per HDMI frame period
res = [800, 525];

% Initially use the approximate estimate of the frame rate
% to hone in on possible frame peak indexes of the auto-correlation.
fv = 60.0002;

% -------------------------------------------------------------------------

% LOAD A DATA FILE
% Start with scene3-640x480-60-425M-64M-40M.dat

fid = fopen('scene3-640x480-60-425M-64M-40M.dat', 'r', 'ieee-le');
iq = fread(fid, [2, inf], 'single=>single');  fclose(fid);
iq = double(complex(iq(1,:), iq(2,:)));

% -------------------------------------------------------------------------

% AUTOMATE FP ESTIMATION (ALONG WITH FV AND FH) USING CROSS-CORRELATION
% BETWEEN FIRST FRAME AND LAST FRAME

% Get the first and last frames
first_frame = iq(1:round(Fs/fv));
last_frame = iq(length(iq)-round(Fs/fv)+1:end);

% The frame signals must be de-meaned before cross-correlation
first_frame_abs_demeaned_iq = abs(first_frame) - mean(abs(first_frame));
last_frame_abs_demeaned_iq = abs(last_frame) - mean(abs(last_frame));

% Take the cross-correlation between the first and last frames
cross_corr = xcorr(first_frame_abs_demeaned_iq, last_frame_abs_demeaned_iq);

% PLOT CROSS-CORRELATION
figure(1)
plot(1:length(cross_corr), cross_corr)
title('Cross-Correlation Between First Frame and Last Frame')

% Find the index of the maximum (middle) peak in the cross-correlation
[cross_corr_max, peak_index] = max(cross_corr);

% Get samples difference between the peak index and the middle of the graph
diff = peak_index - round((length(cross_corr)-1)/2);

% Find out the index number of the last frame
last_frame_index = round(fv * ((length(iq)-round(Fs/fv)+1)/Fs));

% Use the sample difference between the first and last frames
% to obtain the more accurate frame rate.
fv = (Fs * last_frame_index) / ((length(iq)-round(Fs/fv)+1)-diff);

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
% Get bottom half from bottom half of frame 57
bottom_half = iq_resampled(offset+(57*(fr/fv))+((fr/fv)/2):offset+((58*(fr/fv))-1));
% Combine the two halves into one new frame
split_frame = [top_half bottom_half];
split_frame = abs(split_frame); % Amplitude Demodulation

% Reshape frame into a 800 x 525 2D matrix
X = size(split_frame);
split_frame_image = reshape(split_frame, m, X(2)/m);
split_frame_image = sum(split_frame_image, 1)./m;
split_frame_image = reshape(split_frame_image, [res(1), res(2)]).';

% Display the first frame as a greyscale image
figure(2)
image(split_frame_image, 'CDataMapping', 'scaled')
colormap(gray)
title('Top: Frame 1, Bottom: Frame 57, fp Automatically Estimated with Cross-Correlation')