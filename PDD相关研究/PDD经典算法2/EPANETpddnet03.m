%EPANETpdd����
clear;clc;close all;tic
funcName = 'EPANETPDD';
hfileName = 'toolkit.h';
libName = 'EPANETx64PDD';
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
errcode=loadlibrary(libName,hfileName);%����EPANET�ļ�
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
errcode=calllib(libName,'ENopen',output_net_file{3},'Net.rpt','');%��inp�ļ�
R_head = [86;88;90;92;94;96;98;100.0;117.56];
R_head2 = [86;88;90;92;94;96;98;98;117.56];
head_cell = cell(numel(R_head),1);
demand_cell = cell(numel(R_head),1);
value = libpointer('doublePtr',0);
id = libpointer('cstring','R2');
index = libpointer('int32Ptr',0);
[errcode,id,index]=calllib(libName,'ENgetnodeindex',id,index)
c = calllib(libName,'ENsetnodevalue',9,1,75);%������ˮ��
for i = 1:numel(R_head)
    c = calllib(libName,'ENsetnodevalue',10,0,R_head(i));%��Reservoirs head ��ֵ
    c = calllib(libName,'ENsetnodevalue',11,0,R_head2(i));%��Reservoirs head ��ֵ
    c = calllib(libName,'ENsolveH');
    for j = 1:9
        [errcode,value1(j,1)]=calllib(libName,'ENgetnodevalue',j,9,value);%��ˮ��
        [errcode,value2(j,1)]=calllib(libName,'ENgetnodevalue',j,10,value);%ˮͷ
        [errcode,value3(j,1)]=calllib(libName,'ENgetnodevalue',j,110,value);%ѹ��
    end
    head_cell{i} = value2;
    demand_cell{i} = value1;   
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
mid_3 = {'0 head','1,','2','3','4','5','6','7','8','9'};
mid_4 =[mid_3;num2cell(mid_2)]
xlswrite('net03.xls',mid_4)
% calllib(libName,'ENclose');
