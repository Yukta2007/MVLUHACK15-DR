function exudateMask = detectExudates(imagePath)
% detectExudates
% Detects candidate exudate regions in a retinal fundus image.
%
% Input:
%   imagePath - path to retinal image
%
% Output:
%   exudateMask - binary candidate exudate mask

%% Read image
img = imread(imagePath);

% Convert grayscale to RGB
if size(img,3) == 1
    img = repmat(img,[1 1 3]);
end

% Convert to double
img = im2double(img);

% Resize
img = imresize(img,[512 512]);

%% Extract channels
red = img(:,:,1);
green = img(:,:,2);

%% Improve green-channel contrast
greenEnhanced = adapthisteq(green, ...
    'ClipLimit',0.01, ...
    'Distribution','rayleigh');

%% Detect bright retinal regions
brightImage = mat2gray( ...
    0.6 * greenEnhanced + 0.4 * red);

%% Threshold bright regions
threshold = graythresh(brightImage);

exudateMask = imbinarize( ...
    brightImage,threshold);

%% Remove small noise
exudateMask = bwareaopen( ...
    exudateMask,30);

%% Remove extremely large regions
exudateMask = bwareafilt( ...
    exudateMask,[30 5000]);

%% Morphological cleanup
exudateMask = imopen( ...
    exudateMask,strel('disk',2));

%% Fill small gaps
exudateMask = imclose( ...
    exudateMask,strel('disk',2));

end