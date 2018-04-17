clc, clear all;

tic

OriginImage = imread('1.png');
OriginImage = padarray(OriginImage, [5 5], 255, 'both');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%找出外轮廓%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w = fspecial('laplacian', 0.5);
EnhanceImage = imfilter(OriginImage, w, 'replicate');
LapBorderImage = im2bw(EnhanceImage, 0.9);
% hough_detect(LapBorderImage);                                             %霍夫变换找圆

BorderImage = ~LapBorderImage;
[BorderImage, BorderArea]= convex_hull(BorderImage);                        %凸包连接轮廓

[LabelMatrix, LabelNum] = bwlabel(BorderImage, 8);

[Row, Column] = find(LabelMatrix == 0);
CentreRow = floor(mean(Row));
CentreColumn = floor(mean(Column));

fprintf(1, '原始轮廓中心位置为：（%.2f，%.2f）；图像轮廓中心位置为：（%.2f，%.2f）；误差为:（%.2f，%.2f）\n', 45, 45, CentreRow, CentreColumn, 100 * (CentreRow - 45) / 45, 100 * (CentreColumn - 45) / 45);
fprintf(1, '原始轮廓面积为：%.2f；图像轮廓面积为：%.2f；误差为:（%.2f）\n', 1600 * pi, BorderArea, 100 * (BorderArea - 1600 * pi) / (1600 * pi));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%找出缺陷轮廓%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%去除外轮廓%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CannyImage = edge(OriginImage, 'canny', [0.04 0.2], 2.4);
% DefectImage = bwmorph(CannyImage, 'skel', 1);
DefectImage = CannyImage;

[LabelMatrix, LabelNum] = bwlabel(DefectImage, 8);

[Row, Column] = find(LabelMatrix == 1);
Length = length(Row);
for i = 1 : Length
    DefectImage(Row(i), Column(i)) = 0;
end

[Row, Column] = find(LabelMatrix == 2);
Length = length(Row);
for i = 1 : Length
    DefectImage(Row(i), Column(i)) = 0;
end

[Row, Column] = find(LabelMatrix == 3);
Length = length(Row);
for i = 1 : Length
    DefectImage(Row(i), Column(i)) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%去除伪影缺陷%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MaskImage = im2bw(OriginImage, 110 / 255);

BreakDefectImage = DefectImage & MaskImage;
subplot(1, 3, 2), imshow(BreakDefectImage);

[LabelMatrix, LabelNum] = bwlabel(BreakDefectImage, 8);

[Row, Column] = find(LabelMatrix == 1);
Length = length(Row);
for i = 1 : Length
    BreakDefectImage(Row(i), Column(i)) = 0;
end

[DefectImage, DefectArea] = convex_hull(~BreakDefectImage);
[LabelMatrix, LabelNum] = bwlabel(~DefectImage, 8);

[Row, Column] = find(LabelMatrix == 1);
CentreRow = floor(mean(Row));
CentreColumn = floor(mean(Column));

fprintf(1, '原始的缺陷中心位置为：（%.2f，%.2f）；图像缺陷中心位置为：（%.2f，%.2f）；误差为:（%.2f，%.2f）\n', 45 - 13.6, 45 + 13.6, CentreRow, CentreColumn, 100 * (CentreRow - 31.4) / 31.4, 100 * (CentreColumn - 58.6) / 58.6);
fprintf(1, '原始缺陷面积为：%.2f；图像缺陷面积为：%.2f；误差为:（%.2f）\n', 78.816, DefectArea, 100 * (DefectArea - 78.816) / 78.816);

FinalImage = BorderImage & DefectImage;

% DefectImage = DefectImage & ~endpoints(DefectImage);
% FilterTemplet = strel('rectangle', [2 1]);
% DilateImage = imerode(DefectImage, FilterTemplet);
% FilterTemplet = strel('rectangle', [12 13]);
% DilateImage = imdilate(LapBorderImage, FilterTemplet);
% DilateImage = bwmorph(LapBorderImage, 'clean', 2);
% DilateImage = bwmorph(DilateImage, 'thin', 2);
% DefectImage = bwmorph(CannyImage, 'skel', 5);
% FilterTemplet = strel('rectangle', [12 11]);
% DilateImage = imerode(DilateImage, FilterTemplet);
% w = fspecial('laplacian', 0.8);
% DilateImage = imfilter(DilateImage, w, 'replicate');
% MergeImage = splitmerge(LapBorderImage, 2, @predicate);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
subplot(1, 3, 1), imshow(OriginImage), title('原始图像', 'Color', 'm', 'FontSize', 20);
subplot(1, 3, 2), imshow(DefectImage), title('识别的缺陷', 'Color', 'm', 'FontSize', 20);
subplot(1, 3, 3), imshow(FinalImage), title('完整的缺陷图像', 'Color', 'm', 'FontSize', 20);imwrite(FinalImage, '2_1.png');
hold on, plot(CentreColumn, CentreRow, 'Marker', 'o', 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'b', 'MarkerSize', 10);
figure;
subplot(1, 1, 1), imshow(OriginImage);
figure;
subplot(1, 1, 1), imshow(FinalImage);

toc