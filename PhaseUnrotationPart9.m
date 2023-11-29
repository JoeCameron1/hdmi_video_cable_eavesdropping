% L314 Digital Signal Processing Assignment 4a
% HDMI Video Cable Eavesdropping
% Author = Joseph Cameron, CRSid = jmc276, MPhil ACS
% -------------------------------------------------------------------------
% PHASE UNROTATION PART 9
% PLOT SPECTROGRAMS TO OBTAIN A MORE ACCURATE FU FOR PHASE UNROTATION
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

% PLOT A SPECTROGRAM OF IQ DATA

figure(1)
% Look at the first 50,000 iq samples
spectrogram(iq(1:50000), 512, 128, 1024, Fs, 'centered')
title('Spectrogram of IQ Data')

% -------------------------------------------------------------------------

% UNROTATE PERIODIC PHASE BASED ON SPECTROGRAM

% From the spectrogram plot, it can be seen that fu must equal:
% abs(16*fp-fc) (fc = 425e6, 425e6 is the centre frequency for this iq).
% This is because the strongest values on the spectrogram occur at the
% 16th integer multiple of the pixel clock frequency fp.
fu = abs(16 * fp - fc);

phasor = exp(2 * pi * 1j * (1:length(iq)) * fu/Fs);
unrotated_iq = iq .* phasor;

% -------------------------------------------------------------------------

% CONFIRM THAT THE UNROTATION PHASOR MOVES THE PEAKS TO 0 HZ
% BY PLOTTING ANOTHER SPECTROGRAM

figure(2)
% Look at the first 50,000 unrotated iq samples
spectrogram(unrotated_iq(1:50000), 512, 128, 1024, Fs, 'centered')
title('Spectrogram of Unrotated IQ Data')

% -------------------------------------------------------------------------

% RESAMPLE IQ DATA AND DISPLAY FIRST FRAME AS AN RGB IMAGE WHERE
% THE RED CHANNEL = REAL PART, AND THE GREEN CHANNEL = IMAGINARY PART

% Change sampling frequency to an integer (m) multiple of fp
m = 3;
fr = m * fp;
unrotated_iq_resampled = interp1(1:length(unrotated_iq), unrotated_iq, 1:Fs/fr:length(unrotated_iq), "spline");

% Get the first frame as a 2D matrix and display it as a greyscale image
% To correctly align the image, an initial offset must be applied
offset = m * 210050; % 210050 gives a pixel-perfect alignment
first_frame = unrotated_iq_resampled(offset:offset+(fr/fv)-1);

% Turn first frame into a vector and downsample x3
X = size(first_frame);
first_frame_image = reshape(first_frame, m, X(2)/m);
first_frame_image = sum(first_frame_image, 1)./m;

% Real part in red channel
red_channel = real(first_frame_image);
% Imaginary part in green channel
green_channel = imag(first_frame_image);
% Blue channel is zeros (no info)
blue_channel = zeros(size(first_frame_image));

% Rescale red and green channels to improve visibility
red_channel = rescale(red_channel);
green_channel = rescale(green_channel);

% Reshape the r,g,b channels into 800 x 525 2D matrices
red_channel = reshape(red_channel, [res(1), res(2)]).';
green_channel = reshape(green_channel, [res(1), res(2)]).';
blue_channel = reshape(blue_channel, [res(1), res(2)]).';

% Concatenate the three r,g,b channels together for rgb image
rgb_image = cat(3, red_channel, green_channel, blue_channel);

% Display the first frame as an rgb image
figure(3)
image(rgb_image, 'CDataMapping', 'scaled')
title('Unrotated Phase in First Frame where r = Real Part, g = Imaginary Part')

% -------------------------------------------------------------------------

% DISPLAY FIRST FRAME IN HSV COLOUR COORDINATES

% Get Polar Coordinates
[hue, brightness] = cart2pol(real(first_frame_image), imag(first_frame_image));

% Rescale hue and brightness for better visibility
hue = rescale(hue);
brightness = rescale(brightness);

% Set saturation to full saturation (all 1s)
saturation = ones(size(first_frame_image));

% Reshape the hue, saturation, and brightness (value) components
% into 800 x 525 2D matrices.
hue = reshape(hue, [res(1), res(2)]).';
saturation = reshape(saturation, [res(1), res(2)]).';
brightness = reshape(brightness, [res(1), res(2)]).';

% Concatenate the three h,s,v components together for hsv image
% To display, hsv must be converted to rgb
hsv_image = hsv2rgb(cat(3, hue, saturation, brightness));
% Display the hsv image
figure(4)
image(hsv_image, 'CDataMapping', 'scaled')
title('Unrotated Phase in First Frame where h = Real Part, v = Imaginary Part')
