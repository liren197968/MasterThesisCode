function [BorderImage, PolygonArea] = convex_hull(BorderImage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%Grahamɨ�跨%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PolygonArea = 0;

    [m, n] = size(BorderImage);

    index = 0;                                                                                                                              %��ȡͼ�������
    for i = 1 : 1 : m
        for j = 1 : 1 : n
            if BorderImage(i, j) == 0
                index = index + 1;
                x(index, 1) = i;
                y(index, 1) = j;
            end
        end
    end

    if index == 0
        for i = 1 : 1 : m
            for j = 1 : 1 : n
                BorderImage(i, j) = 1;
            end
        end
        
        PolygonArea = 0;
        
        return;
    else
        n = length(x); p = [];
        for i = 1 : n
           p = [p; x(i) y(i)];                                                                                                                  %���ж�͹���ĵ㼯
        end
    end
    
    index = 1;                                                                                                                              %�ҵ�y���ĵ������
    for i = 2 : 1 : n
        if (p(i, 2) > p(index, 2)) || ( (p(i, 2) == p(index, 2)) && (p(i, 1) < p(index, 1) ) ) 
            index = i;
        end
    end

    TempP = p(index, :);                                                                                                                    %�ҵ�y���ĵ�
    TempHP = [TempP(1) + 0.30, TempP(2)];                                                                                                   %��һ����y���ĵ�ƽ�еĵ�

    for i = 1 : n
        VectorAngle(i) = multiply_angle(TempHP, p(i, :), TempP);                                                                            %��ÿ�����y���ĵ�ļнǣ��Լ����Լ��н�NAN
    end

    VectorAngle = VectorAngle';
    p = [p VectorAngle];
    p = sortrows(p, 3);                                                                                                                     %�����������򣬵������ǼнǶ���

    StackSpace{1} = p(n, 1 : 2);                                                                                                            %re�൱��ջ
    StackSpace{2} = p(1, 1 : 2);
    StackSpace{3} = p(2, 1 : 2);
    StackTopValue = 3;                                                                                                                      %ָ��ջ����ָ��

    for i = 3 : n - 1
        while multiply_vector(p(i, 1 : 2), StackSpace{StackTopValue - 1}, StackSpace{StackTopValue}) >= 0                                   %���Ϊ��                      
            BorderImage(StackSpace{StackTopValue}(1), StackSpace{StackTopValue}(2)) = 1;
            StackTopValue = StackTopValue - 1;                                                                                              %���ݳ�ջ
            
            if StackTopValue == 1
                break;
            end
        end
        
        StackTopValue = StackTopValue + 1;
        StackSpace{StackTopValue} = p(i, 1 : 2);
    end
    
    for i= 2 : StackTopValue                                                                                                                %��͹���ϵĵ��������
       BorderImage = draw_line(BorderImage, StackSpace{i - 1}(1), StackSpace{i - 1}(2), StackSpace{i}(1), StackSpace{i}(2));
    end
    
    BorderImage = draw_line(BorderImage, StackSpace{1}(1), StackSpace{1}(2), StackSpace{StackTopValue}(1), StackSpace{StackTopValue}(2));

    for i = 2 : StackTopValue
        PolygonArea = PolygonArea + StackSpace{i - 1}(1) * StackSpace{i}(2) - StackSpace{i}(1) * StackSpace{i -1}(2);
    end
    
    PolygonArea = PolygonArea  + StackSpace{StackTopValue}(1) * StackSpace{1}(2) - StackSpace{1}(1) * StackSpace{StackTopValue}(2);
    PolygonArea = abs(PolygonArea) / 2;
  
end

function img = draw_line(img, y1, x1, y2, x2)                                                                                               %��Ϊͼ���������ѧ��������y�ᳯ���෴��������������y����ȡ�෴��
    if y1 == y2
        mi = min(x1, x2);
        ma = max(x1, x2);
        for i = mi : ma
            img(y2, i) = 0;
        end
    else
        if x1 == x2
            mi = min(y1, y2);
            ma = max(y1, y2);
            for i = mi : ma
               img(i, x2) = 0;
            end            
        else
            y1 = -y1;
            y2 = -y2;
            k = (y2 - y1) / (x2 - x1);
            b = y1 - k * x1;

            mi = min(x1, x2);
            ma = max(x1, x2);
            for i = mi : ma
               img(-round(i * k + b), i) = 0;
            end

            mi = min(y1, y2);
            ma = max(y1, y2);
            for i = mi : ma
               img(-i, round((i - b) / k) ) = 0;
            end
        end
    end
    
end

function re = multiply_angle(p1, p2, p0)                                                                                                    %�ж�<p10,p20>�нǣ�Ϊ������׼��
    vec1 = p1 - p0;
    vec2 = p2 - p0;
    re = acos(dot(vec1, vec2) / (norm(vec1) * norm(vec2))) * 180 / pi;
end

function re = multiply_vector(p1, p2, p0)                                                                                                   %p10,p20�������ȡ������Ϊ����ջ����ֵ��Ϊ͹���ϵĵ㣬Ϊ����Ϊ͹���ϵĵ�
    x=1;
    y=2;
   
   re=(p1(x) - p0(x)) * (p2(y) - p0(y)) - (p1(y) - p0(y)) * (p2(x) - p0(x));

end

function distance = point_distance(point1, point2)
    distance = ( (point1(1, 1) - point2(1, 1)) .^ 2 + (point1(1, 2) - point2(1, 2)) .^ 2) .^ 0.5;

end
