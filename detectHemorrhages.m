function hemorrhageMask = detectHemorrhages(imagePath)
% detectHemorrhages
% Detects candidate hemorrhage regions in a retinal fundus image.
%
% Input:
%   imagePath - path to retinal image
%
% Output:
%   hemorrhageMask - binary candidate hemorrhage mask

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

%% Extract RGB channels
red = img(:,:,1);
green = img(:,:,2);

%% Create red-dominance image
% Hemorrhagic regions can appear darker/redder than surrounding tissue
redDominance = red - green;

redDominance = mat2gray(redDominance);

%% Enhance local contrast
redDominance = adapthisteq(redDominance, ...
    'ClipLimit',0.01, ...
    'Distribution','rayleigh');

%% Detect dark/red candidate regions
darkComponent = imbothat(redDominance, ...
    strel('disk',6));

darkComponent = mat2gray(darkComponent);

%% Automatic threshold
threshold = graythresh(darkComponent);

hemorrhageMask = imbinarize( ...
    darkComponent,threshold);

%% Remove tiny noise
hemorrhageMask = bwareaopen( ...
    hemorrhageMask,20);

%% Keep reasonable-sized regions
hemorrhageMask = bwareafilt( ...
    hemorrhageMask,[20 3000]);

%% Morphological cleanup
hemorrhageMask = imopen( ...
    hemorrhageMask,strel('disk',1));

hemorrhageMask = imclose( ...
    hemorrhageMask,strel('disk',2));

end