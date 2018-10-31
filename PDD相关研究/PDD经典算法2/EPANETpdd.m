% EPANETpdd

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
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random_singleTime',path);%单点模拟所需的函数。
    load EPA_F
end
if libisloaded(libName)
    unloadlibrary (libName)
end
errcode=loadlibrary(libName,hfileName);%加载EPANET文件
input_net_filename=cell(4,1);
output_net_file=cell(4,1);
input_net_filename{1}=[lib_directory,'运算案例','\','net01.inp'];
input_net_filename{2}=[lib_directory,'运算案例','\','net02.inp'];
input_net_filename{3}=[lib_directory,'运算案例','\','net03.inp'];
input_net_filename{4}=['Test2.inp'];
output_net_file{1}=[active_directory,'EPANETpddnet01.inp'];
output_net_file{2}=[active_directory,'EPANETpddnet02.inp'];
output_net_file{3}=[active_directory,'EPANETpddnet03.inp'];
output_net_file{4}=[active_directory,'Test2.inp'];
output_net_filename=['C:\Users\hc042\Desktop\计算结果','\555',];
if isdir(output_net_filename)
    rmdir(output_net_filename,'s')
end
mkdir(output_net_filename);
errcode=calllib(libName,'ENopen',input_net_filename{1},'Net.rpt','');%打开inp文件
id = libpointer('cstring','7');
index = libpointer('int32Ptr',0);
[errcode,id,index]=calllib(libName,'ENgetnodeindex',id,index);
% errcode=calllib(libName,'ENsetnodevalue',index,paramcode,value);
% [errcode,value]=calllib(libName,'ENgetnodevalue',index,paramcode,value);
value = libpointer('doublePtr',0);
[errcode,value]=calllib(libName,'ENgetnodevalue',index,1,value);
errcode=calllib(libName,'ENsetnodevalue',index,1,value*4);
errcode=calllib(libName,'ENsetnodevalue',index,120,0);
errcode=calllib(libName,'ENsetnodevalue',index,121,0);
for i = 1:4
    errcode=calllib(libName,'ENsetnodevalue',i,120,0);
errcode=calllib(libName,'ENsetnodevalue',i,121,0);
end
errcode = calllib(libName,'ENsaveinpfile',output_net_file{1});
errcode = calllib(libName,'ENclose')
% errcode = calllib(libName,'ENsolveH');
errcode=calllib(libName,'ENopen',input_net_filename{2},'Net.rpt','');%打开inp文件
for i = 1:6
    errcode=calllib(libName,'ENsetnodevalue',i,120,0);
errcode=calllib(libName,'ENsetnodevalue',i,121,0);
end
% errcode = calllib(libName,'ENsolveH')
errcode = calllib(libName,'ENsaveinpfile',output_net_file{2});
errcode = calllib(libName,'ENclose')
errcode=calllib(libName,'ENopen',input_net_filename{3},'Net.rpt','');%打开inp文件
for i = 1:9
    errcode=calllib(libName,'ENsetnodevalue',i,120,0);
errcode=calllib(libName,'ENsetnodevalue',i,121,0);
end
% errcode = calllib(libName,'ENsolveH')
errcode = calllib(libName,'ENsaveinpfile',output_net_file{3});
% for j = 1:4
% [errcode,value1(j,1)]=calllib(libName,'ENgetnodevalue',j,9,value);
% [errcode,value2(j,1)]=calllib(libName,'ENgetnodevalue',j,10,value);
% [errcode,value3(j,1)]=calllib(libName,'ENgetnodevalue',j,110,value);
% end
% errcode = calllib(libName,'ENclose');
errcode=calllib(libName,'ENopen',input_net_filename{4},'Net.rpt','');%打开inp文件
id = libpointer('cstring','7');
index = libpointer('int32Ptr',0);
[errcode,id,index]=calllib(libName,'ENgetnodeindex',id,index);
% errcode=calllib(libName,'ENsetnodevalue',index,paramcode,value);
% [errcode,value]=calllib(libName,'ENgetnodevalue',index,paramcode,value);
value = libpointer('doublePtr',0);
% [errcode,value]=calllib(libName,'ENgetnodevalue',index,1,value);
% errcode=calllib(libName,'ENsetnodevalue',index,1,value*4);
% errcode=calllib(libName,'ENsetnodevalue',index,120,0);
% errcode=calllib(libName,'ENsetnodevalue',index,121,0);
for i = 1:4
    errcode=calllib(libName,'ENsetnodevalue',i,120,0);
errcode=calllib(libName,'ENsetnodevalue',i,121,0);
end
errcode = calllib(libName,'ENsaveinpfile',output_net_file{4});
errcode = calllib(libName,'ENclose')