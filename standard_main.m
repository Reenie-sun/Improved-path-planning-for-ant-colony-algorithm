 %% ����դ���ͼ
clear;clc
%{
G=[0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0
0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 1 1 0 0 0 0 0 1 0 0 0 0 1 1 0 0 0 0 0
0 0 0 0 0 0 1 1 0 0 0 0 1 0 0 1 0 0 0 0
0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0
0 1 1 1 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0
0 1 1 1 0 0 1 1 1 0 0 0 0 0 0 1 0 0 0 0
0 1 1 1 0 0 0 1 1 1 0 0 0 1 0 1 0 0 0 0
0 1 1 0 0 0 0 0 0 0 0 0 1 1 0 1 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0
0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0 0 0 0 0
0 0 0 0 1 1 0 0 1 1 1 0 0 0 0 0 0 0 0 0
0 0 0 0 1 1 0 0 0 0 0 0 1 1 0 0 1 1 1 0
0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 1 1 0
0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0
0 0 1 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 1 0 0 1 1 1 0 0 0 0 0 1 1 0
0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 0 0 1 1 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; % G ����ͼΪ01�������Ϊ1����ʾ�ϰ���
%}
load map.mat
h=rot90(abs(peaks(30)));
global MM
global Dir 
global Lgrid 
%Lgrid = input('������դ��������');
Lgrid = 1;
MM=size(G,1); %MMΪ����ά��
figure(1);   
for i=1:MM
  for j=1:MM
  x1=(j-1)*Lgrid;y1=(MM-i)*Lgrid; 
  x2=j*Lgrid;y2=(MM-i)*Lgrid; 
  x3=j*Lgrid;y3=(MM-i+1)*Lgrid; 
  x4=(j-1)*Lgrid;y4=(MM-i+1)*Lgrid; 
  f=(max(max(h))-h(i,j))/max(max(h));
    if G(i,j)==1 
        fill([x1,x2,x3,x4],[y1,y2,y3,y4],[0.2,0.2,0.2]); hold on %դ��Ϊ1�����Ϊ��ɫ
    else 
        fill([x1,x2,x3,x4],[y1,y2,y3,y4],[f,1,f]); hold on %դ��Ϊ0�����Ϊ��ɫ
    end 
  end 
end
axis([0,MM*Lgrid,0,MM*Lgrid]) 
grid on
%% ��ʼ����ͼ��Ϣ
%{
Xinitial = input('�������ʼ���X���꣺');
Yinitial = input('�������ʼ���Y���꣺');
%}
Xinitial = 0.6;
Yinitial = 0.2;
[initial ij_initial]= modify(Xinitial,Yinitial);
if max(ij_initial)>MM||G(ij_initial(1),ij_initial(2))==1
    error('��ʼ�㲻�������ϰ����ϻ򳬳���Χ');
end
%{
Xdestination = input('������Ŀ����X���꣺');
Ydestination = input('������Ŀ����Y���꣺');
    %}
Xdestination = 29.4;
Ydestination = 29.3;
[destination ij_destination]= modify(Xdestination,Ydestination);
if max(ij_destination)>MM||G(ij_destination(1),ij_destination(2))==1
    error('Ŀ��㲻�������ϰ����ϻ򳬳���Χ');
end
%% ���������������dis
dis = zeros(MM,MM);
for i=1:MM
  for j=1:MM
   x = (j-0.5)*Lgrid;
   y = (MM-i+0.5)*Lgrid;
   dis(i,j) = sqrt(sum(([x y]-destination).^2));
  end
end
%% �������ת�ƾ���D
D=zeros(MM^2,8);   %�кű�ʾդ���ţ��кű�ʾ�ڽӵ�8�������դ���
Dir = [-MM-1,-1,MM-1,MM,MM+1,1,1-MM,-MM];
 for i = 1:MM^2     %8����ת�ƾ�������������
     Dirn = Dir+i;
     if G(i)==1
             D(i,:)=inf;
             continue
     end
         for j = 1:8
             if  Dirn(j)<=0||Dirn(j)>MM^2        %��������������Ϊ0
                 continue 
             end
             if G(Dirn(j))==1
                 D(i,j) = inf;
             elseif mod(j,2)==0         %ż������Ϊ�������ҷ���
                 D(i,j) = 1;
             elseif j==1 %���Ϸ�����������֤·�߲�����ϰ�������߹�
                 if (G(Dirn(2))+G(Dirn(8))==0)
                   D(i,j) = 1.4; 
                 else
                   D(i,j) = inf;   
                 end
             elseif (Dirn(j-1)<=0||Dirn(j-1)>MM^2)||(Dirn(j+1)<=0||Dirn(j+1)>MM^2)%�ų�����ֱ�����դ���������
                 continue
             elseif G(Dirn(j-1))+G(Dirn(j+1))==0    %��������б����
                 D(i,j) = 1.4;
             else
                 D(i,j) = inf;
             end
         end
     
 end
%% ����߽�
 num = 1:MM^2;
 obs_up = find(mod(num,MM)==1);
 obs_up = obs_up(2:end-1);
 D(obs_up,[1,2,3])=inf;
 obs_down = find(mod(num,MM)==0);
 obs_down = obs_down(2:end-1);
 D(obs_down,[5,6,7])=inf;
 D(2:MM-1,[1,7,8]) = inf;
 D(MM^2-MM+2:MM^2-1,[3,4,5])=inf;
 D(1,[1,2,3,7,8])=inf;
 D(MM,[1,5,6,7,8])=inf;
 D(MM^2-MM+1,[1,2,3,4,5])=inf;
 D(MM^2,[3,4,5,6,7])=inf;
%% ������ʼ��
tic
NC_max=30; m=35; t=8; Rho=0.1; Q=100; Omega=10; Mu=2; Lambda=2;
%% �����ҵ�������·��
[R_best,F_best,L_best,T_best,L_ave,Shortest_Route,Shortest_Length]=standard(D,initial,destination,dis,h,NC_max,m,t,Rho,Omega,Mu,Lambda,Q); %��������
%�����ҵ�������·��
j = ceil(Shortest_Route/MM);
i = mod(Shortest_Route,MM);
i(i==0) = MM;
x = (j-0.5)*Lgrid;
y = (MM-i+0.5)*Lgrid;
x = [initial(1) x destination(1)];
y = [initial(2) y destination(2)];
figure(1);
plot(x,y,'--b');
xlabel('x'); ylabel('y'); title('���·��');
grid on 
toc  %��������ʱ��
%% ������������
figure(2); iter=1:length(L_best);
plot(iter,L_best,'-b','LineWidth',1)
xlabel('��������'); ylabel('�������·�ߵĳ���'); 
axis([0,NC_max,25,90]);
grid on;hold on
figure(3); iter=1:length(L_best);
plot(iter,F_best*100,'-b','LineWidth',1)
xlabel('��������'); ylabel('�������·�ߵĸ߶Ⱦ�����*100'); 
axis([0,NC_max,0,30]);
grid on;hold on
figure(4); iter=1:length(L_best);
plot(iter,T_best,'-b','LineWidth',1)
xlabel('��������'); ylabel('�������·�ߵ�ת�����'); 
axis([0,NC_max,5,50]);
grid on;hold on
toc
