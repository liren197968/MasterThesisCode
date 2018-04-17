function img = hough_detect(img)
    
    step_r = 1; step_angle = 0.1; minr = 30; maxr = 45; thresh = 0.51;
    
    [HoughSpace, HoughCircle, TempPara] = hough_circle(img, step_r, step_angle, minr, maxr, thresh);
    
    subplot(1, 3, 1), imshow(img), title('边缘');
    subplot(1, 3, 2), imshow(HoughCircle), title('检测结果');
    
    CircleParaXYR = TempPara;
    fprintf(1,'\n---------------圆统计----------------\n');
    [r, c] = size(CircleParaXYR);                                                                                                     %r=size(CircleParaXYR,1);
    fprintf(1, '   检测出%d个圆\n', r);                                                                                                   %圆的个数
    fprintf(1, '     圆心   半径\n');                                                                                                     %圆的个数
    
    for n=1 : r
        fprintf(1, '%d （%d，%d） %d\n', n, floor(CircleParaXYR(n,1)), floor(CircleParaXYR(n,2)), floor(CircleParaXYR(n,3)));
    end
    
    subplot(1, 3, 3), imshow(img), title('检测出图中的圆'); hold on;                                                                   %标出圆
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
% BW:二值图像；
% step_r:检测的圆半径步长
% step_angle:角度步长，单位为弧度
% r_min:最小圆半径
% r_max:最大圆半径
% p:阈值，0，1之间的数 通过调此值可以得到图中圆的圆心和半径
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output
% HoughSpace:参数空间，h(a,b,r)表示圆心在(a,b)半径为r的圆上的点数
% hough_circl:二值图像，检测到的圆
% TempPara:检测到的圆的圆心、半径

    CircleParaXYR=[];
    TempPara=[];

    [m,n] = size(BW);
    size_r = round((r_max-r_min)/step_r)+1;%四舍五入
    size_angle = round(2*pi/step_angle);

    HoughSpace = zeros(m,n,size_r);

    [rows,cols] = find(BW);%查找非零元素的行列坐标
    ecount = size(rows);%非零坐标的个数

    % Hough变换
    % 将图像空间(x,y)对应到参数空间(a,b,r)

    % a = x-r*cos(angle)
    % b = y-r*sin(angle)

    for i=1:ecount
        for r=1:size_r %半径步长数
            for k=1:size_angle %按一定弧度把圆几等分
                a = round(rows(i)-(r_min+(r-1)*step_r)*cos(k*step_angle));
                b = round(cols(i)-(r_min+(r-1)*step_r)*sin(k*step_angle));
                if(a>0&a<=m&b>0&b<=n)
                HoughSpace(a,b,r) = HoughSpace(a,b,r)+1;%h(a,b,r)的坐标，圆心和半径
                end
            end
        end
    end


    % 搜索超过阈值的聚集点。对于多个圆的检测，阈值要设的小一点！通过调此值，可以求出所有圆的圆心和半径
    max_para = max(max(max(HoughSpace)));%返回值就是这个矩阵的最大值
    index = find(HoughSpace>=max_para*p);%一个矩阵中，想找到其中大于max_para*p数的位置
    length = size(index);%符合阈值的个数
    HoughCircle = false(m,n);
    %HoughCircle = zeros(m,n);
    %通过位置求半径和圆心。
    for i=1:ecount
        for k=1:length
            par3 = floor(index(k)/(m*n))+1;
            par2 = floor((index(k)-(par3-1)*(m*n))/m)+1;
            par1 = index(k)-(par3-1)*(m*n)-(par2-1)*m;
            if((rows(i)-par1)^2+(cols(i)-par2)^2<(r_min+(par3-1)*step_r)^2+5&...
                    (rows(i)-par1)^2+(cols(i)-par2)^2>(r_min+(par3-1)*step_r)^2-5)
                  HoughCircle(rows(i),cols(i)) = true;   %检测的圆
            end
        end
    end               

    % 从超过峰值阈值中得到
    for k=1:length
        par3 = floor(index(k)/(m*n))+1;%取整
        par2 = floor((index(k)-(par3-1)*(m*n))/m)+1;
        par1 = index(k)-(par3-1)*(m*n)-(par2-1)*m;
        CircleParaXYR = [CircleParaXYR;par1,par2,par3];
        HoughCircle(par1,par2)= true; %这时得到好多圆心和半径，不同的圆的圆心处聚集好多点，这是因为所给的圆不是标准的圆
        %fprintf(1,'test1:Center %d %d \n',par1,par2);
    end

    %集中在各个圆的圆心处的点取平均，得到针对每个圆的精确圆心和半径！
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
             XYR=[XYR;CircleParaXYR(k,1),CircleParaXYR(k,2),CircleParaXYR(k,3)];  %保存剩下圆的圆心和半径位置
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
          TempPara=[TempPara;c1,c2,c3]; %保存各个圆的圆心和半径的值
          CircleParaXYR=XYR;
    end

end