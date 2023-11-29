% L314 Digital Signal Processing Assignment 4a
% HDMI Video Cable Eavesdropping
% Author = Joseph Cameron, CRSid = jmc276, MPhil ACS
% -------------------------------------------------------------------------
% PHASE UNROTATION PART 10
% COHERENT PERIODIC AVERAGING
% -------------------------------------------------------------------------

% SETUP GLOBAL VARIABLES

% Sampling Frequency
Fs = 64e6;

% Total resolution transmitted per HDMI frame period
res = [800, 525];

% Frame Rate From Previous Part (Part 6) of the Project
fv = 60.000230085628083;

% Line Rate
fh = fv * res(2);

% Pixel Clock Frequency
fp = fh * res(1);

% -------------------------------------------------------------------------

% LOAD A DATA FILE
% Start with scene3-640x480-60-425M-64M-40M.dat

fid = fopen('scene3-640x480-60-425M-64M-40M.dat', 'r', 'ieee-le');
iq = fread(fid, [2, inf], 'single=>single');  fclose(fid);
iq = double(complex(iq(1,:), iq(2,:)));

% The centre frequency for this file
fc = 425e6;

% -------------------------------------------------------------------------

% UNROTATE PERIODIC PHASE BASED ON SPECTROGRAM FROM PART 9

% From the spectrogram plots in part 9, it can be seen that fu must equal:
% abs(16*fp-fc) (fc = 425e6, 425e6 is the centre frequency for this iq).
% This is because the strongest values on the spectrogram occur at the
% 16th integer multiple of the pixel clock frequency fp.
fu = abs(16 * fp - fc);

phasor = exp(2 * pi * 1j * (1:length(iq)) * fu/Fs);
unrotated_iq = iq .* phasor;

% -------------------------------------------------------------------------

% RESAMPLE IQ DATA AND DISPLAY AVERAGED FRAME AS AN RGB IMAGE WHERE
% THE RED CHANNEL = REAL PART, AND THE GREEN CHANNEL = IMAGINARY PART

% Change sampling frequency to an integer (m) multiple of fp
m = 3;
fr = m * fp;
unrotated_iq_resampled = interp1(1:length(unrotated_iq), unrotated_iq, 1:Fs/fr:length(unrotated_iq), "spline");

% Get the first frame as a 2D matrix and display it as a greyscale image
% To correctly align the image, an initial offset must be applied
offset = m * 210050; % 210050 gives a pixel-perfect alignment

% COHERENT PERIODIC AVERAGING
% Initialise matrix that stores frames
frames = zeros(59, (fr/fv));

% Collect all frames in the recording
for i = 1:59
    frames(i, 1:(fr/fv)) = unrotated_iq_resampled(offset+(i-1)*(fr/fv):offset+i*(fr/fv)-1);
end

% Average over all the frames to get an average frame
averaged_frame = mean(frames);

% Turn average frame into a vector and downsample x3
X = size(averaged_frame);
averaged_frame_image = reshape(averaged_frame, m, X(2)/m);
averaged_frame_image = sum(averaged_frame_image, 1)./m;

% Real part in red channel
red_channel = real(averaged_frame_image);
% Imaginary part in green channel
green_channel = imag(averaged_frame_image);
% Blue channel is zeros (no info)
blue_channel = zeros(size(averaged_frame_image));

% Rescale red and green channels to improve visibility
red_channel = rescale(red_channel);
green_channel = rescale(green_channel);

% Reshape the r,g,b channels into 800 x 525 2D matrices
red_channel = reshape(red_channel, [res(1), res(2)]).';
green_channel = reshape(green_channel, [res(1), res(2)]).';
blue_channel = reshape(blue_channel, [res(1), res(2)]).';

% Concatenate the three r,g,b channels together for rgb image
rgb_image = cat(3, red_channel, green_channel, blue_channel);

% Display the average frame as an rgb image
figure(1)
image(rgb_image, 'CDataMapping', 'scaled')
title('Coherent Periodic Averaging Over All 59 Frames (r = Real Part, g = Imaginary Part)')

% -------------------------------------------------------------------------

% DISPLAY FIRST FRAME IN HSV COLOUR COORDINATES

% Get Polar Coordinates
[hue, brightness] = cart2pol(real(averaged_frame_image), imag(averaged_frame_image));

% Rescale hue and brightness for better visibility
hue = rescale(hue);
brightness = rescale(brightness);

% Set saturation to full saturation (all 1s)
saturation = ones(size(averaged_frame_image));

% Reshape the hue, saturation, and brightness (value) components
% into 800 x 525 2D matrices.
hue = reshape(hue, [res(1), res(2)]).';
saturation = reshape(saturation, [res(1), res(2)]).';
brightness = reshape(brightness, [res(1), res(2)]).';

% Concatenate the three h,s,v components together for hsv image
% To display, hsv must be converted to rgb
hsv_image = hsv2rgb(cat(3, hue, saturation, brightness));
% Display the hsv image
figure(2)
image(hsv_image, 'CDataMapping', 'scaled')
title('Coherent Periodic Averaging Over All 59 Frames (h = Real Part, v = Imaginary Part)')

% -------------------------------------------------------------------------

% DISPLAY IMAGE WITH AM DEMODULATION

% Amplitude Demodulation
am_demodulated_averaged_frame = abs(averaged_frame);

% Turn average frame into a 800 x 525 2D matrix
am_X = size(am_demodulated_averaged_frame);
am_averaged_frame_image = reshape(am_demodulated_averaged_frame, m, am_X(2)/m);
am_averaged_frame_image = sum(am_averaged_frame_image, 1)./m;
am_averaged_frame_image = reshape(am_averaged_frame_image, [res(1), res(2)]).';

% Display the averaged frame as a greyscale image
figure(3)
image(am_averaged_frame_image, 'CDataMapping', 'scaled')
colormap(gray)
title('Coherent Periodic Averaging Over All 59 Frames, AM Demodulation')
