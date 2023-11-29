% L314 Digital Signal Processing Assignment 4a
% HDMI Video Cable Eavesdropping
% Author = Joseph Cameron, CRSid = jmc276, MPhil ACS
% -------------------------------------------------------------------------
% AMPLITUDE DEMODULATION PART 1
% -------------------------------------------------------------------------

% SETUP GLOBAL VARIABLES

% Sampling Frequency
Fs = 64e6;

% Total resolution transmitted per HDMI frame period
res = [800, 525];

% Pixel Clock Frequency
fp = 25.175e6; % For initial image without shear alignment

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
first_frame = iq_resampled(1:(fr/fv));
first_frame = abs(first_frame); % Amplitude Demodulation

% Reshape frame into a 800 x 525 2D matrix
X = size(first_frame);
first_frame_image = reshape(first_frame, m, X(2)/m);
first_frame_image = sum(first_frame_image, 1)./m;
first_frame_image = reshape(first_frame_image, [res(1), res(2)]).';

% Display the first frame as a greyscale image
figure(1)
image(first_frame_image, 'CDataMapping', 'scaled')
colormap(gray)
title('Image of the First Frame Obtained via Amplitude Demodulation on Resampled IQ Data')