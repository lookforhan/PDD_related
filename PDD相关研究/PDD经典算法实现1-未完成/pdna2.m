% 实现论文[1]的算法。
% 采用面向对象方法
% [1]	ANG WAH KHIM, JOWITT PAUL W. Solution for Water Distribution Systems under Pressure-Deficient Conditions[J]. Journal of Water Resources Planning and Management, 2006, 132(3): 175–182.
% name: PDNA

% 本文件需要'C:\Users\hc042\Desktop\renxingjisuancode2\'中函数的支持。
clc;clear;close all;tic
funcName = 'PDNA2';
libName = 'epanet2';
hfileName = 'epanet2.h';
lib_directory='C:\Users\hc042\Desktop\renxingjisuancode2\';
active_directory ='C:\Users\hc042\Desktop\PDD经典算法实现1\';
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
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random_singleTime',path);%单点模拟所需的函数。
    load EPA_F
end
if libisloaded(libName)
    unloadlibrary (libName)
end
loadlibrary([lib_directory,libName],[lib_directory,hfileName]);
input_net_filename=cell(3,1);
output_net_file=cell(3,1);
input_net_filename{1}=[lib_directory,'运算案例','\','net01.inp'];

input_net_filename{2}=[lib_directory,'运算案例','\','net02.inp'];
input_net_filename{3}=[lib_directory,'运算案例','\','net03.inp'];
output_net_file{1}=[active_directory,'PDNAnet01.inp'];
output_net_file{2}=[active_directory,'PDNAnet02.inp'];
output_net_file{3}=[active_directory,'PDNAnet03.inp'];
output_net_filename=['C:\Users\hc042\Desktop\计算结果','\555',];
if isdir(output_net_filename)
    rmdir(output_net_filename,'s')
end
mkdir(output_net_filename);
% % for i = 1:3
% % [t1, net_data ] = read_net( input_net_filename{i},EPA_format);
% % junction_id = net_data{2,2}(:,1);
% % junction_elevation = net_data{2,2}(:,2);
% % junction_demand = net_data{15,2}(:,2);
% % net_data{15,2}(:,2) = [];%
% % % junction_coordinate
% % add_num = numel(junction_id);%节点数目
% % add_R_id = cell(add_num,1);%新增水源名称
% % add_R_head = junction_elevation;%新增水源水头
% % add_coordinate = cell(add_num,2);%新增水源坐标
% % add_J_id = cell(add_num,1);%新增节点名称
% % add_J_elevation = junction_elevation;%新增节点高程
% % add_J_demand = junction_demand;%新增节点需水量
% %
% % add_P_id = cell(add_num*2,1);
% % add_P_N1 = cell(add_num*2,1);
% % add_P_N2 = cell(add_num*2,1);
% % add_P_L = num2cell(ones(add_num*2,1));
% % add_P_C = num2cell(ones(add_num*2,1)*1E6);
% % add_P_D = num2cell(ones(add_num*2,1)*300);
% % add_P_M = num2cell(ones(add_num*2,1)*0);
% % add_P_S = cell(add_num*2,1);
% % for j = 1:add_num
% %     junction_j = junction_id{j};
% %     net_data{15,2}{j,2} = 0;
% %     loc = ismember(net_data{23,2}(:,1),junction_j);
% %     junction_x = net_data{23,2}(loc,2);
% %     junction_y = net_data{23,2}(loc,3);
% %     add_coordinate{j,1} = junction_x{1};
% %     add_coordinate{j,2} = junction_y{1};
% %     add_R_id{j} = [junction_j,'-R'];
% %     add_J_id{j} = [junction_j,'-J'];
% %     add_P_id{j,1} = [add_R_id{j},'-P'];
% %     add_P_S{j,1} = 'CLOSED';
% %     add_P_N1{j,1} = add_R_id{j};
% %     add_P_N2{j,1} = junction_j;
% %     add_P_id{j+add_num,1} = [add_J_id{j},'-P'];
% %     add_P_S{j+add_num,1} = 'CLOSED';
% %     add_P_N1{j+add_num,1} = add_J_id{j};
% %     add_P_N2{j+add_num,1} = junction_j;
% % end
% % all_pipe_data =[net_data{5,2}; [add_P_id,add_P_N1,add_P_N2,add_P_L,add_P_D,add_P_C,add_P_M,add_P_S]];
% % all_node_coordinate = [net_data{23,2};[add_R_id,add_coordinate];[add_J_id,add_coordinate]];
% % outdata{1} = all_pipe_data;
% % outdata{2} = net_data{2,2};
% % outdata{3}=[[add_J_id,add_coordinate,add_J_elevation,num2cell(ones(add_num,1)),cell(add_num,1);add_R_id,add_coordinate,add_R_head,num2cell(ones(add_num,1)*2),cell(add_num,1)],cell(add_num*2,3),num2cell(zeros(add_num*2,1))];
% % outdata{4}=net_data{3,2};
% % % outdata{6}=[[net_data{15,2};[add_J_id,junction_demand]],cell(add_num*2,1)];
% % outdata{6}=[net_data{15,2},cell(add_num,1)];
% % outdata{7} = cell(0,2);
% % outdata{8} = all_node_coordinate;
% % t_W=Write_Inpfile5(net_data,EPA_format,outdata,output_net_file{i});% 写入新管网inp
% % end

% PROCESS
% n_j =0;
% n_r=0;
% R_num=0;
% R_id=cell(1,1);
% int32 = libpointer('int32Ptr',0);
% cstring = libpointer('cstring','id');
% J_demand = [33.33;33.33;50;66.67];
% R_head = [85;89.08;90.98;91.03;91.97;96.92;98.78;100.0;109.86];
% for i = 1:1
%     c = calllib(libName,'ENopen',input_net_filename{i},'1.rpt','');
%     if c
%         keyboard
%     end
%     [c,n_j] = calllib('epanet2','ENgetcount',0,n_j);
%     if c
%         keyboard
%     end
%     [c,n_r] = calllib('epanet2','ENgetcount',1,n_r);
%     if c
%         keyboard
%     end
%     
%     for j = 1:n_j
%         [c,int32] = calllib(libName,'ENgetnodetype',j,int32);
%         if c
%             keyboard
%         end
%         if double(int32) ==1
%             R_num = R_num+1;
%             R_index(R_num) =double(j);
%             [c,int32] = calllib(libName,'ENgetnodetype',j,int32);
%             if c
%                 keyboard
%             end
%             [c,cstring] = calllib(libName,'ENgetnodeid',j,cstring);
%             if c
%                 keyboard
%             end
%             R_id{R_num} = cstring;
%         end
%         
%     end
%     c = calllib(libName,'ENclose');
%     if c
%         keyboard
%     end
%     c = calllib(libName,'ENopen',output_net_file{i},'1.rpt','');
%     if c
%         keyboard
%     end
%     id = libpointer('cstring',R_id{1});
%     int32 = libpointer('int32Ptr',1);
%     [c,~,index] = calllib(libName,'ENgetnodeindex',id,int32);
%     c = calllib(libName,'ENsetnodevalue',index,0,88);
%     c = calllib(libName,'ENclose');
%     if c
%         keyboard
%     end
% end
% calllib('epanet2','ENsaveinpfile','wenti2.inp')
toc