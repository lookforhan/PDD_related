%EPANETpdd
% ѡ��İ�������Ϊnet02.inp
clear;clc;close all;tic
funcName = 'epanet2';
hfileName = 'epanet2.h';
libName = 'epanet2';
lib_directory='C:\Users\hc042\Desktop\renxingjisuancode2\';
active_directory =[pwd,'\'];
try
    load EPA_F
catch
    path('C:\Users\hc042\Desktop\renxingjisuancode2\toolkit',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\readNet',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\damageNet',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\EPS',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\getValue',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\eventTime',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random_singleTime',path);%����ģ������ĺ�����
    load EPA_F
end
if libisloaded(libName)
    unloadlibrary (libName)
end
Hmin=0;
Hdes=20;
errcode=loadlibrary([lib_directory,libName],[lib_directory,hfileName]);%����EPANET�ļ�
input_net_filename=cell(3,1);
output_net_file=cell(3,1);
input_net_filename{1}=[lib_directory,'���㰸��','\','net01.inp'];
input_net_filename{2}=[lib_directory,'���㰸��','\','net02.inp'];
input_net_filename{3}=[lib_directory,'���㰸��','\','net03.inp'];
output_net_file{1}=[active_directory,'EPANETpddnet01.inp'];
output_net_file{2}=[active_directory,'EPANETpddnet02.inp'];
output_net_file{3}=[active_directory,'EPANETpddnet03.inp'];
output_net_filename=['C:\Users\hc042\Desktop\������','\555',];
if isdir(output_net_filename)
    rmdir(output_net_filename,'s')
end
mkdir(output_net_filename);
R_head = [86;88;90;92;94;96;98;100.0;117.56];
head_cell = cell(numel(R_head),1);
demand_cell = cell(numel(R_head),1);
errcode=calllib(libName,'ENopen',input_net_filename{2},'Net.rpt','');%��inp�ļ�

n_j =0;
n_r=0;
[c,n_j] = calllib('epanet2','ENgetcount',0,n_j);
[c,n_r] = calllib('epanet2','ENgetcount',1,n_r);
junction_num =n_j -n_r;
J_demand = [25;25;25;25;25;75];
id = libpointer('cstring','9');
index = libpointer('int32Ptr',0);
[errcode,id,index]=calllib(libName,'ENgetnodeindex',id,index);
C_mid=ones(junction_num,1);
c = calllib(libName,'ENsetnodevalue',6,1,75);%������ˮ��
HMIN=Hmin*C_mid;HDES=Hdes*C_mid;two=2*C_mid;
value = libpointer('singlePtr',0);
for i = 1:numel(R_head)
    c = calllib(libName,'ENsetnodevalue',7,0,R_head(i));%��Reservoirs head ��ֵ
    [~,bdemand]=Get(junction_num,1);%��ˮ��
    if i ==4
        keyboard
    end
    for n = 1:80
        calllib('epanet2','ENsolveH');% ����ˮ������
        [~,pre]=Get(junction_num,11);%ѹ��
        [~,bdemand1]=Get(junction_num,1);%��ˮ��
        bdemand2=bdemand;%bdemand2��Ϊ�м����
        bdemand2(pre<=Hmin)=0;
        [i2]=find(pre(:,1)>=Hmin&pre(:,1)<=Hdes);
        bdemand2(i2,1)=(bdemand1(i2,1)+bdemand(i2,1).*((pre(i2,1)-HMIN(i2,1))./(HDES(i2,1)-HMIN(i2,1))).^(1/2))./two(i2,1);
        error=abs(bdemand1-bdemand2)./bdemand1;
        b=max(error);
        if b<0.01
            disp(['PDD������������,����',num2str(n),'��'])
            break
        end
        for j=1:junction_num
            calllib('epanet2','ENsetnodevalue',j,1,bdemand2(j,1));
        end
    end
    disp(['PDD������������,����',num2str(n),'��'])
    for j = 1:6
        [errcode,value1(j,1)]=calllib(libName,'ENgetnodevalue',j,9,value);%��ˮ��
        [errcode,value2(j,1)]=calllib(libName,'ENgetnodevalue',j,10,value);%ˮͷ
        [errcode,value3(j,1)]=calllib(libName,'ENgetnodevalue',j,110,value);%ѹ��
    end
    head_cell{i} = double(value2);
    demand_cell{i} = double(value1);
    for j=1:junction_num
        calllib('epanet2','ENsetnodevalue',j,1,J_demand(j,1));
    end
end
% post-process
mid_head = [];
mid_demand = [];
for i = 1:numel(R_head)
    mid_head = [mid_head,demand_cell{i}];
    %     mid_demand = [mid_demand,R_demand{i}];
end
;
% R_head_2 = repmat(R_head,1,2)'
% R_head_3 = reshape(R_head_2,18,1)
mid_2 = [R_head,mid_head']
mid_3 = {'0 head','2','3','4','5','6','7'};
mid_4 =[mid_3;num2cell(mid_2)]
xlswrite('net02.xls',mid_4)
calllib(libName,'ENclose');
