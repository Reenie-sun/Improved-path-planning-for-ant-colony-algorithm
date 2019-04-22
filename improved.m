function [R_best,F_best,L_best,T_best,S_best,S_ave,Shortest_Route,Shortest_Length] = improved(D,initial,destination,dis,h,NC_max,m,Rho,Omega,Mu,Q,u,Tau_min,Tau_max,Rho_min)
%%  ��Ⱥ�㷨��·���滮������⺯��
%%  ��Ҫ����˵��
%%  D        8�������ת�ƾ���
%%  initial  ��ʼ����
%%  destination  �յ�����
%%  dis      ������������
%%  NC_max   ����������
%%  m        ���ϸ���
%%  Alpha    ������Ϣ����Ҫ�̶ȵĲ���
%%  Beta     ��������ʽ������Ҫ�̶ȵĲ���
%%  c        �ٽ�ʱ��
%%  Rho      ��Ϣ������ϵ��
%%  Omega    ��������ʽ��Ϣϵ��1
%%  Mu       ��������ʽ��Ϣϵ��2
%%  Q        ��Ϣ������ǿ��ϵ��
%%  R_best   �������·��
%%  L_best   �������·�ߵĳ���
%%  ================================================================
%% ��һ����������ʼ��
global MM;
global Lgrid;
global Dir;
Tau=20*ones(MM^2,8);             %TauΪ��Ϣ�ؾ���
NC=1;                         %����������
R_best=zeros(NC_max,MM^2);    %�������·��(����Ϊ����������NC_max������Ϊ�߹�դ������)
R_best_to_direct=zeros(NC_max,MM^2);  %�������·�ߣ�ת�Ʒ���
L_best=inf.*ones(NC_max,1);   %�������·�ߵĳ��ȣ�inf:�����
F_best=zeros(NC_max,1);     %�������·�߸߶Ⱦ�����
T_best=zeros(NC_max,1);     %�������·��ת�����
S_best=zeros(NC_max,1);     %�������·���ۺϵ÷�
S_ave=zeros(NC_max,1);        %����·�ߵ�ƽ������
inum = MM+(initial(1)/Lgrid-0.5)*MM-(initial(2)/Lgrid-0.5); %��ʼ����ת��Ϊդ����
dnum = MM+(destination(1)/Lgrid-0.5)*MM-(destination(2)/Lgrid-0.5); %�յ�����ת��Ϊդ����
Tabu=zeros(m,MM^2);           %�洢����¼·��������tabu:��ֹͣ�����ɱ���m�о���
to_direct=zeros(m,MM^2);         %�洢����¼·����ת�Ʒ�����̣�m�о���
while NC<=NC_max              %ֹͣ����֮һ���ﵽ����������
%% �ڶ�����mֻ���ϰ����ʺ���ѡ����һդ��
%{
if NC<c
       Alpha = 4*NC/c;
       Beta = (3*c-1.5*NC)/c;
else
%}
       Alpha = 1;
       Beta = 3;
%end

   Tabu(:,1)=inum;     %����ʼդ�������ɱ�
   for i=1:m
       j=2;       %դ��ӵڶ�����ʼ
       while Tabu(i,j-1)~=dnum
            visited=Tabu(i,1:(j-1));      %�ѷ��ʵ�դ��
            J=zeros(1,1);         %�����ʵ�դ��
            N=J;        %�����ʵ�դ��ת�Ʒ���
            P=J;        %ת�Ƹ��ʷֲ�
            Jc=1;       %ѭ���±�
            for k=1:8   %����ѭ���������ʵ�դ�������k��դ�������ѷ��ʵ�դ������Ϊ�����ʵ�դ��
                k1 = Dir(k)+visited(end);
                if D(visited(end),k)==inf
                    continue
                end
                if isempty(find(visited==k1, 1)) % if length(find(visited==k))==0
                    J(Jc)=k1;% ��������դ���ž���
                    N(Jc)=k; % ��������դ��ת�Ʊ�ž���
                    Jc=Jc+1;  %�±��1��������һ���洢�����ʵ�դ��
                end
            end
            if J==0        %��·�����
                Tabu(i,:)=0;
                to_direct(i,:)=0;
                break
            end
            max_dis = max(dis(J));         
            delta_dis = max(dis(J))-min(dis(J))+0.001;
            max_h=max(abs(h(visited(end))-h(J)));
            delta_v=max(h(visited(end))-h(J))-min(h(visited(end))-h(J))+0.001;
            %���������դ���ת�Ƹ��ʷֲ�������ʽ��Ϣ���ʷֲ�
            for k=1:length(J)           %sum(J>0)��ʾ�����ʵ�դ��ĸ���
                if j==2
                    r = u/length(J);
                elseif N(k)==to_direct(i,j-2)
                    r = 0.5*u;
                else
                    r = 0.5*u/length(J);
                end
                Phi=(max_dis-dis(J(k)))/delta_dis*Omega+Mu;
                d=D(visited(end),N(k));
                v=(max_h-abs(h(visited(end))-h(J(k))))/delta_v*Omega+Mu;
                Eta=r+1/d+Phi+v;
                P(k)=Tau(visited(end),N(k))^Alpha*Eta^Beta;  %���ʼ��㹫ʽ�еķ���
            end                         %TauΪ��Ϣ�ؾ���,EtaΪ�������Ӿ���
            P=P/(sum(P));               %ת�Ƹ��ʷֲ�������Ϊ������դ�����       
            %������ԭ��ѡȡ��һ��դ��
            Pcum=cumsum(P); %cumsum���ۼӺ�: cumsum([1 1 1])= 1 2 3�����ۼӵ�Ŀ������ʹPcum��ֵ���д���rand����
            Select=find(Pcum>=rand);    %���ۻ����ʺʹ��ڸ��������������ѡ��������ϵ����һ��դ����Ϊ�������ʵ�դ��         
            Tabu(i,j)=J(Select(1));          %�����ʹ���դ�������ɱ���
            to_direct(i,j-1) = N(Select(1));     %to_direct��ʾ�������ʵ�դ��ת�Ʒ���
            j=j+1;                     
       end 
       
   end  
 
if NC>=2            %��������������ڵ���2������һ�ε��������·�ߴ���Tabu�ĵ�һ����
        Tabu(1,:)=R_best(NC-1,:);
        to_direct(1,:)=R_best_to_direct(NC-1,:);
end
%% ����������¼���ε������·��
    L=zeros(m,1);
    F=zeros(m,1);
    T=zeros(m,1);
    S=zeros(m,1);
    x=1;y=100;z=1;
    for i=1:m
           if Tabu(i,:)==0          %ȥ����·�����
               L(i)=inf; 
               F(i)=inf;
               T(i)=inf;
               S(i)=inf;
               continue
           end 
           F(i)=std(h(Tabu(i,:)~=0));  %���߹�·���ĸ߶ȵľ�����
           j=2;
           L(i)=Lgrid*D(Tabu(i,1),to_direct(i,1));
           while Tabu(i,j+1)~=0
              L(i)=L(i)+Lgrid*D(Tabu(i,j),to_direct(i,j));  %��·������
              T(i)=T(i)+~(~(to_direct(i,j)-to_direct(i,j-1))); %��ת��Ĵ���
              j=j+1;
           end
           S(i)=x*L(i)+y*F(i)+z*T(i);            %���ۺ�·������
    end
    S_best(NC)=min(S);               %����·��Ϊ�ۺ����ŵ�·��
    if S_best(NC)==inf
        error('û��ͨ·');
    end
    pos=find(S==S_best(NC));         %�ҳ�����·����Ӧ��λ�ã�������ֻ������
    R_best(NC,:)=Tabu(pos(1),:);     %ȷ������·����Ӧ��դ��˳��
    R_best_to_direct(NC,:)=to_direct(pos(1),:); %ȷ������·����Ӧ��դ��ת�Ʒ���˳��
    L_best(NC) = L(pos(1));          %��������·�߳���
    F_best(NC) = F(pos(1));          %��������·�߸߶Ⱦ�����
    T_best(NC) = T(pos(1));          %��������·��ת�����
    S_ave(NC)=mean(S(S~=inf));       %���k�ε�����ƽ���ۺ�ָ��(ȥ����·�����)
    NC=NC+1;   
%% ���Ĳ���������Ϣ��
    %n = sum((to_direct(pos(1),:)~=0));
    Delta_Tau=zeros(MM^2,8);           %Delta_Tau��i,j����ʾ���е��������ڵ�i��դ������8��դ��·���ϵ���Ϣ������
    for i=1:m
        for j=1:MM^2  %����������·����·�������ͷ���Ϣ�أ�Q/S(i)
            if Tabu(i,j)==0||Tabu(i,j+1)==0  %�ų���·�������
                break
            else
              Delta_Tau(Tabu(i,j),to_direct(i,j))=Delta_Tau(Tabu(i,j),to_direct(i,j))+Q/S(i); 
            end
        end
    end
    if Tau<Tau_min     %�н����Ϣ��
        Tau=Tau_min;
    elseif Tau>Tau_max
        Tau=Tau_max;
    end
    Tau=(1-Rho).*Tau+Delta_Tau;     %��Ϣ�ظ��¹�ʽ   
    if 0.95*Rho>Rho_min     %�н�Ķ�̬�ӷ�ϵ��
        Rho=0.95*Rho;
    else
        Rho=Rho_min;
    end
%% ���岽�����ɱ�����
    Tabu=zeros(m,MM^2);  %ÿ����һ�ζ������ɱ�����
    to_direct=zeros(m,MM^2);  %ת�Ʒ����������
end
%% ��������������
Pos=find(S_best==min(S_best));      %�ҵ�L_best����Сֵ���ڵ�λ�ò�����Pos
Shortest_Route=R_best(Pos(1),:);     %��ȡ���·��
Shortest_Route=Shortest_Route(Shortest_Route~=0);%ȥ��ȫ����·�����
Shortest_Length=L_best(Pos(1));     %��ȡ���·���ĳ���
end