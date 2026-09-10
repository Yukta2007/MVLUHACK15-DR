function showDRVisualization(imagePath)

% Read original image
img = imread(imagePath);

% Preprocess
enhancedImage = preprocessImage(imagePath);

% Segmentation
vesselMask = segmentVessels(imagePath);
microMask = detectMicroaneurysms(imagePath);
exudateMask = detectExudates(imagePath);
hemorrhageMask = detectHemorrhages(imagePath);

% Optic disc
[opticDiscMask, centerX, centerY, radius] = locateOpticDisc(imagePath);

% Resize original for consistent display
original = im2double(img);

if size(original,3) == 1
    original = repmat(original,[1 1 3]);
end

original = imresize(original,[512 512]);

% Create figure
figure('Name','Diabetic Retinopathy Screening Visualization',...
    'NumberTitle','off',...
    'Color','white');

% Original
subplot(2,4,1);
imshow(original);
title('Original Image');

% Preprocessed
subplot(2,4,2);
imshow(enhancedImage);
title('Preprocessed');

% Blood vessels
subplot(2,4,3);
imshow(vesselMask);
title('Blood Vessels');

% Microaneurysms
subplot(2,4,4);
imshow(microMask);
title('Microaneurysms');

% Exudates
subplot(2,4,5);
imshow(exudateMask);
title('Exudates');

% Hemorrhages
subplot(2,4,6);
imshow(hemorrhageMask);
title('Hemorrhages');

% Optic disc
subplot(2,4,7);
imshow(opticDiscMask);
title('Optic Disc');

% Overlay
subplot(2,4,8);
imshow(original);
hold on;

if any(opticDiscMask(:))
    contour(opticDiscMask,[0.5 0.5],'LineWidth',2);
end

hold off;
title('Optic Disc Overlay');

sgtitle('Diabetic Retinopathy Image Analysis');

% Display feature summary
fprintf('\n===== DR IMAGE ANALYSIS =====\n');

fprintf('Vessel pixels       : %d\n',sum(vesselMask(:)));
fprintf('Microaneurysm pixels: %d\n',sum(microMask(:)));
fprintf('Exudate pixels      : %d\n',sum(exudateMask(:)));
fprintf('Hemorrhage pixels   : %d\n',sum(hemorrhageMask(:)));

if ~isnan(centerX)
    fprintf('Optic disc center   : (%.1f, %.1f)\n',centerX,centerY);
    fprintf('Optic disc radius   : %.1f pixels\n',radius);
else
    fprintf('Optic disc           : Not detected\n');
end

fprintf('==============================\n');

    % Create output folder
    outputFolder = fullfile('gui', 'public', 'results');

    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    % Save visualization images
    imwrite(original, ...
        fullfile(outputFolder, 'original.png'));

    imwrite(enhancedImage, ...
        fullfile(outputFolder, 'preprocessed.png'));

    imwrite(vesselMask, ...
        fullfile(outputFolder, 'vessels.png'));

    imwrite(microMask, ...
        fullfile(outputFolder, 'microaneurysms.png'));

    imwrite(exudateMask, ...
        fullfile(outputFolder, 'exudates.png'));

    imwrite(hemorrhageMask, ...
        fullfile(outputFolder, 'hemorrhages.png'));

    imwrite(opticDiscMask, ...
        fullfile(outputFolder, 'optic_disc.png'));

    % Save complete visualization
    exportgraphics(gcf, ...
        fullfile(outputFolder, 'dr_analysis.png'));

    % Create output folder
    outputFolder = fullfile('gui', 'public', 'results');

    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    % Save visualization images
    imwrite(original, ...
        fullfile(outputFolder, 'original.png'));

    imwrite(enhancedImage, ...
        fullfile(outputFolder, 'preprocessed.png'));

    imwrite(vesselMask, ...
        fullfile(outputFolder, 'vessels.png'));

    imwrite(microMask, ...
        fullfile(outputFolder, 'microaneurysms.png'));

    imwrite(exudateMask, ...
        fullfile(outputFolder, 'exudates.png'));

    imwrite(hemorrhageMask, ...
        fullfile(outputFolder, 'hemorrhages.png'));

    imwrite(opticDiscMask, ...
        fullfile(outputFolder, 'optic_disc.png'));

    % Save complete visualization
    exportgraphics(gcf, ...
        fullfile(outputFolder, 'dr_analysis.png'));

end