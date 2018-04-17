clear all;
close all;
clc;

img=ones(256,256);
imshow(img);
[x y]=ginput();
x=round(x);
y=round(y);
n=length(x);
p=[];
for i=1:n
   img(y(i)-1:y(i)+1,x(i)-1:x(i)+1)=0; 
   p=[p;x(i) y(i)];     %待判断凸包的点集
end
imshow(img);

%%下面计算凸包
[t index]=max(p(:,2));  %找到y最大的点的索引，这里没考虑当有多个这样的点的情况
tmp_p=p(index,:);         %找到y最大的点
tmp_heng=[tmp_p(1)+30,tmp_p(2)];    %设一个和y最大的点平行的点

for i=1:n           %这里没判断夹角相同的情况，当夹角相同，可以判断当前点和p0点的距离。
    jiao(i)=multi_jiao(tmp_heng,p(i,:),tmp_p);  %求每个点和y最大的点的夹角，自己和自己夹角NAN
end
jiao=jiao';
p=[p jiao];

p=sortrows(p,3);    %按第三列排序，第三列是夹角度数

re{1}=p(n,1:2);     %re相当于栈
re{2}=p(1,1:2);
re{3}=p(2,1:2);
top=3;    %指向栈顶的指针

for i=3:n-1
    while multi(p(i,1:2),re{top-1},re{top})>=0      %如果为正
        top=top-1;       
    end
    top=top+1;
    re{top}=p(i,1:2);
end

%下面是把找到的凸包上的点连线
for i=2:top   
   img=drawline(img,re{i-1}(1),re{i-1}(2),re{i}(1),re{i}(2));
end
img=drawline(img,re{1}(1),re{1}(2),re{top}(1),re{top}(2));
figure;
imshow(img)

