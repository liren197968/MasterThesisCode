function img = hough_detect(img)
    
    step_r = 1; step_angle = 0.1; minr = 30; maxr = 45; thresh = 0.51;
    
    [HoughSpace, HoughCircle, TempPara] = hough_circle(img, step_r, step_angle, minr, maxr, thresh);
    
    subplot(1, 3, 1), imshow(img), title('��Ե');
    subplot(1, 3, 2), imshow(HoughCircle), title('�����');
    
    CircleParaXYR = TempPara;
    fprintf(1,'\n---------------Բͳ��----------------\n');
    [r, c] = size(CircleParaXYR);                                                                                                     %r=size(CircleParaXYR,1);
    fprintf(1, '   ����%d��Բ\n', r);                                                                                                   %Բ�ĸ���
    fprintf(1, '     Բ��   �뾶\n');                                                                                                     %Բ�ĸ���
    
    for n=1 : r
        fprintf(1, '%d ��%d��%d�� %d\n', n, floor(CircleParaXYR(n,1)), floor(CircleParaXYR(n,2)), floor(CircleParaXYR(n,3)));
    end
    
    subplot(1, 3, 3), imshow(img), title('����ͼ�е�Բ'); hold on;                                                                   %���Բ
    plot(CircleParaXYR(:, 2), CircleParaXYR(:, 1), 'w+', 'LineWidth', 1);
    
    for k = 1 : size(CircleParaXYR, 1)
        t = 0 : 0.02 * pi : 2 * pi;
        x = cos(t) .* CircleParaXYR(k, 3) + CircleParaXYR(k, 2);
        y = sin(t) .* CircleParaXYR(k, 3) + CircleParaXYR(k, 1);
        plot(x, y, 'y-', 'LineWidth', 3);
    end
    
end

function [HoughSpace, HoughCircle, TempPara] = hough_circle(BW, step_r, step_angle, r_min, r_max, p)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input
% BW:��ֵͼ��
% step_r:����Բ�뾶����
% step_angle:�ǶȲ�������λΪ����
% r_min:��СԲ�뾶
% r_max:���Բ�뾶
% p:��ֵ��0��1֮����� ͨ������ֵ���Եõ�ͼ��Բ��Բ�ĺͰ뾶
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output
% HoughSpace:�����ռ䣬h(a,b,r)��ʾԲ����(a,b)�뾶Ϊr��Բ�ϵĵ���
% hough_circl:��ֵͼ�񣬼�⵽��Բ
% TempPara:��⵽��Բ��Բ�ġ��뾶

    CircleParaXYR=[];
    TempPara=[];

    [m,n] = size(BW);
    size_r = round((r_max-r_min)/step_r)+1;%��������
    size_angle = round(2*pi/step_angle);

    HoughSpace = zeros(m,n,size_r);

    [rows,cols] = find(BW);%���ҷ���Ԫ�ص���������
    ecount = size(rows);%��������ĸ���

    % Hough�任
    % ��ͼ��ռ�(x,y)��Ӧ�������ռ�(a,b,r)

    % a = x-r*cos(angle)
    % b = y-r*sin(angle)

    for i=1:ecount
        for r=1:size_r %�뾶������
            for k=1:size_angle %��һ�����Ȱ�Բ���ȷ�
                a = round(rows(i)-(r_min+(r-1)*step_r)*cos(k*step_angle));
                b = round(cols(i)-(r_min+(r-1)*step_r)*sin(k*step_angle));
                if(a>0&a<=m&b>0&b<=n)
                HoughSpace(a,b,r) = HoughSpace(a,b,r)+1;%h(a,b,r)�����꣬Բ�ĺͰ뾶
                end
            end
        end
    end


    % ����������ֵ�ľۼ��㡣���ڶ��Բ�ļ�⣬��ֵҪ���Сһ�㣡ͨ������ֵ�������������Բ��Բ�ĺͰ뾶
    max_para = max(max(max(HoughSpace)));%����ֵ���������������ֵ
    index = find(HoughSpace>=max_para*p);%һ�������У����ҵ����д���max_para*p����λ��
    length = size(index);%������ֵ�ĸ���
    HoughCircle = false(m,n);
    %HoughCircle = zeros(m,n);
    %ͨ��λ����뾶��Բ�ġ�
    for i=1:ecount
        for k=1:length
            par3 = floor(index(k)/(m*n))+1;
            par2 = floor((index(k)-(par3-1)*(m*n))/m)+1;
            par1 = index(k)-(par3-1)*(m*n)-(par2-1)*m;
            if((rows(i)-par1)^2+(cols(i)-par2)^2<(r_min+(par3-1)*step_r)^2+5&...
                    (rows(i)-par1)^2+(cols(i)-par2)^2>(r_min+(par3-1)*step_r)^2-5)
                  HoughCircle(rows(i),cols(i)) = true;   %����Բ
            end
        end
    end               

    % �ӳ�����ֵ��ֵ�еõ�
    for k=1:length
        par3 = floor(index(k)/(m*n))+1;%ȡ��
        par2 = floor((index(k)-(par3-1)*(m*n))/m)+1;
        par1 = index(k)-(par3-1)*(m*n)-(par2-1)*m;
        CircleParaXYR = [CircleParaXYR;par1,par2,par3];
        HoughCircle(par1,par2)= true; %��ʱ�õ��ö�Բ�ĺͰ뾶����ͬ��Բ��Բ�Ĵ��ۼ��ö�㣬������Ϊ������Բ���Ǳ�׼��Բ
        %fprintf(1,'test1:Center %d %d \n',par1,par2);
    end

    %�����ڸ���Բ��Բ�Ĵ��ĵ�ȡƽ�����õ����ÿ��Բ�ľ�ȷԲ�ĺͰ뾶��
    while size(CircleParaXYR,1) >= 1
        num=1;
        XYR=[];
        temp1=CircleParaXYR(1,1);
        temp2=CircleParaXYR(1,2);
        temp3=CircleParaXYR(1,3);
        c1=temp1;
        c2=temp2;
        c3=temp3;
        temp3= r_min+(temp3-1)*step_r;
       if size(CircleParaXYR,1)>1     
         for k=2:size(CircleParaXYR,1)
          if (CircleParaXYR(k,1)-temp1)^2+(CircleParaXYR(k,2)-temp2)^2 > temp3^2
             XYR=[XYR;CircleParaXYR(k,1),CircleParaXYR(k,2),CircleParaXYR(k,3)];  %����ʣ��Բ��Բ�ĺͰ뾶λ��
          else  
          c1=c1+CircleParaXYR(k,1);
          c2=c2+CircleParaXYR(k,2);
          c3=c3+CircleParaXYR(k,3);
          num=num+1;
          end 
        end
       end 
          %fprintf(1,'sum %d %d radius %d\n',c1,c2,r_min+(c3-1)*step_r);
          c1=round(c1/num);
          c2=round(c2/num);
          c3=round(c3/num);
          c3=r_min+(c3-1)*step_r;
          %fprintf(1,'num=%d\n',num)
          %fprintf(1,'Center %d %d radius %d\n',c1,c2,c3);   
          TempPara=[TempPara;c1,c2,c3]; %�������Բ��Բ�ĺͰ뾶��ֵ
          CircleParaXYR=XYR;
    end

end