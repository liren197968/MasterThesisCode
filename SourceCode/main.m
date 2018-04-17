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
   p=[p;x(i) y(i)];     %���ж�͹���ĵ㼯
end
imshow(img);

%%�������͹��
[t index]=max(p(:,2));  %�ҵ�y���ĵ������������û���ǵ��ж�������ĵ�����
tmp_p=p(index,:);         %�ҵ�y���ĵ�
tmp_heng=[tmp_p(1)+30,tmp_p(2)];    %��һ����y���ĵ�ƽ�еĵ�

for i=1:n           %����û�жϼн���ͬ����������н���ͬ�������жϵ�ǰ���p0��ľ��롣
    jiao(i)=multi_jiao(tmp_heng,p(i,:),tmp_p);  %��ÿ�����y���ĵ�ļнǣ��Լ����Լ��н�NAN
end
jiao=jiao';
p=[p jiao];

p=sortrows(p,3);    %�����������򣬵������ǼнǶ���

re{1}=p(n,1:2);     %re�൱��ջ
re{2}=p(1,1:2);
re{3}=p(2,1:2);
top=3;    %ָ��ջ����ָ��

for i=3:n-1
    while multi(p(i,1:2),re{top-1},re{top})>=0      %���Ϊ��
        top=top-1;       
    end
    top=top+1;
    re{top}=p(i,1:2);
end

%�����ǰ��ҵ���͹���ϵĵ�����
for i=2:top   
   img=drawline(img,re{i-1}(1),re{i-1}(2),re{i}(1),re{i}(2));
end
img=drawline(img,re{1}(1),re{1}(2),re{top}(1),re{top}(2));
figure;
imshow(img)

