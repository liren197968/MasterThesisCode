clc, clear all;

tic

OriginImage = imread('1.png');
OriginImage = padarray(OriginImage, [5 5], 255, 'both');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ҳ�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w = fspecial('laplacian', 0.5);
EnhanceImage = imfilter(OriginImage, w, 'replicate');
LapBorderImage = im2bw(EnhanceImage, 0.9);
% hough_detect(LapBorderImage);                                             %����任��Բ

BorderImage = ~LapBorderImage;
[BorderImage, BorderArea]= convex_hull(BorderImage);                        %͹����������

[LabelMatrix, LabelNum] = bwlabel(BorderImage, 8);

[Row, Column] = find(LabelMatrix == 0);
CentreRow = floor(mean(Row));
CentreColumn = floor(mean(Column));

fprintf(1, 'ԭʼ��������λ��Ϊ����%.2f��%.2f����ͼ����������λ��Ϊ����%.2f��%.2f�������Ϊ:��%.2f��%.2f��\n', 45, 45, CentreRow, CentreColumn, 100 * (CentreRow - 45) / 45, 100 * (CentreColumn - 45) / 45);
fprintf(1, 'ԭʼ�������Ϊ��%.2f��ͼ���������Ϊ��%.2f�����Ϊ:��%.2f��\n', 1600 * pi, BorderArea, 100 * (BorderArea - 1600 * pi) / (1600 * pi));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ҳ�ȱ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȥ��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%ȥ��αӰȱ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

fprintf(1, 'ԭʼ��ȱ������λ��Ϊ����%.2f��%.2f����ͼ��ȱ������λ��Ϊ����%.2f��%.2f�������Ϊ:��%.2f��%.2f��\n', 45 - 13.6, 45 + 13.6, CentreRow, CentreColumn, 100 * (CentreRow - 31.4) / 31.4, 100 * (CentreColumn - 58.6) / 58.6);
fprintf(1, 'ԭʼȱ�����Ϊ��%.2f��ͼ��ȱ�����Ϊ��%.2f�����Ϊ:��%.2f��\n', 78.816, DefectArea, 100 * (DefectArea - 78.816) / 78.816);

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
subplot(1, 3, 1), imshow(OriginImage), title('ԭʼͼ��', 'Color', 'm', 'FontSize', 20);
subplot(1, 3, 2), imshow(DefectImage), title('ʶ���ȱ��', 'Color', 'm', 'FontSize', 20);
subplot(1, 3, 3), imshow(FinalImage), title('������ȱ��ͼ��', 'Color', 'm', 'FontSize', 20);imwrite(FinalImage, '2_1.png');
hold on, plot(CentreColumn, CentreRow, 'Marker', 'o', 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'b', 'MarkerSize', 10);
figure;
subplot(1, 1, 1), imshow(OriginImage);
figure;
subplot(1, 1, 1), imshow(FinalImage);

toc