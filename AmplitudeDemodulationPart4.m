% L314 Digital Signal Processing Assignment 4a
% HDMI Video Cable Eavesdropping
% Author = Joseph Cameron, CRSid = jmc276, MPhil ACS
% -------------------------------------------------------------------------
% AMPLITUDE DEMODULATION PART 4
% GENERATE AN IMAGE WITH TOP HALF FROM FRAME 1 AND BOTTOM HALF FROM FRAME 3
% -------------------------------------------------------------------------

% SETUP GLOBAL VARIABLES

% Sampling Frequency
Fs = 64e6;

% Total resolution transmitted per HDMI frame period
res = [800, 525];

% Pixel Clock Frequency
fp = 25.2e6; % For correcting the sideways shear

% Line Rate
fh = fp / res(1);

% Frame Rate
fv = fh / res(2);

% -------------------------------------------------------------------------

% LOAD A DATA FILE
% Start with scene3-640x480-60-425M-64M-40M.dat

fid = fopen('scene3-640x480-60-425M-64M-40M.dat', 'r', 'ieee-le');
iq = fread(fid, [2, inf], 'single=>single');  fclose(fid);
iq = double(complex(iq(1,:), iq(2,:)));

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
title('Top Half From Frame 1, Bottom Half From Frame 3')