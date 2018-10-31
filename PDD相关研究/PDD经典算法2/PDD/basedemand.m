%%2017.10.29晚
clc; clear all; close all;

%加载计算引擎并打开水力模型文件
errcode=loadlibrary('epanet2.dll','epanet2.h');%加载EPANET文件
errcode=calllib('epanet2','ENopen','ky11_Jolly2013_base.inp','Net.rpt','');%打开inp文件
%计算连接节点数量
nodenum=0;%nodenum是总节点数目，可以赋予任意值，可以赋予任意值
[errcode,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);%获取总节点数目，注意获取数值的方式，两边要有相同的参数nodenum，也可以不同
%0代表获取总节点数目的代码，左边的nodenum为返回值的存储变量，右边nodenum为初始值。
tank=0;%tanknum是水源节点数目，可以赋予任意值，但要获取水源节点数目必须初始化
[errcode,tank]=calllib('epanet2','ENgetcount',1,tank);%获取水源点数目，方式与上面的相同，1代表获取水源节点数目的代码
junctionnum=nodenum - tank;%junctionnum是连接节点数目，注意连接节点数目等于总节点数减去水源节点数

%获取正常工况下的节点压力和基本需水量
errcode=calllib('epanet2','ENopenH');%打开水力分析系统
errcode=calllib('epanet2','ENinitH',0);%初始化贮水池水位，管道状态和设置以及模拟时间，0表示不存储二进制水力结果
time=0;%初始化工况时间，可以是任意值
pressure=0;
base_demand=0;
tstep=1;%初始化水力分析的步数，可以是任意非零值
while (tstep && ~errcode)
    [errcode,time]=calllib('epanet2','ENrunH',time);%执行在time时刻的水力分析
    number=double(time)/3600;
    if (number==2)%获取第2步水力分析的水力数据
        for i=1:junctionnum
            [errcode,pressure]=calllib('epanet2','ENgetnodevalue',i,11,pressure);
            [errcode,base_demand]=calllib('epanet2','ENgetnodevalue',i,1,base_demand);
            pressurevalue(i)=pressure;
            basedemandvalue(i)=base_demand;
        end
    end
    [errcode,tstep]=calllib('epanet2','ENnextH',tstep);
end
errcode=calllib('epanet2','ENcloseH');%关闭水力分析系统，释放内存
pressurevalue;
basedemandvalue;
errcode=calllib('epanet2','ENclose');%关闭tookit系统
unloadlibrary('epanet2');


%%%%%%%%%%%%%%% 执行PDD模拟%%%%%%%%%%%%
%加载计算引擎并打开水力模型文件
errcode=loadlibrary('EPANETx64PDD.dll','toolkit.h');%加载EPANET文件
errcode=calllib('EPANETx64PDD','ENopen','ky11_Jolly2013.inp','Net.rpt','');%打开inp文件
tstep=1;
pressurenew=0;
time=0;
number=0;
for i=1:junctionnum
    errcode=calllib('EPANETx64PDD','ENopenH');
    basedemand_new(i)= basedemandvalue(i)+5;%改变节点i的扩散系数，从而改变工况
    errcode=calllib('EPANETx64PDD','ENsetnodevalue',i,1,basedemand_new(i));%把新的节点扩散系数赋予节点i
    errcode=calllib('EPANETx64PDD','ENinitH',0);
    while (tstep && ~errcode)
        [errcode,time]=calllib('EPANETx64PDD','ENrunH',time);%执行在time时刻的水力分析
        number=double(time)/3600;
        if (number==2)
            for j=1:junctionnum
                [errcode,pressurenew]=calllib('EPANETx64PDD','ENgetnodevalue',j,11,pressurenew);
                pressure_new(j,i)=pressurenew;
               tao=-(pressure_new(j,i) - pressurevalue(j));
               if tao<0.09
                   tao=0;
               end 
                P_matrix(j,i)=tao;
             end  
            end
       
        [errcode,tstep]=calllib('EPANETx64PDD','ENnextH',tstep);
    end
    tstep=1;
    errcode=calllib('EPANETx64PDD','ENsetnodevalue',i,1,basedemandvalue(i));%注意每一次循环后要把改变后的节点扩散系数改回原来的节点扩散系数
    errcode=calllib('EPANETx64PDD','ENcloseH');
end
P_matrix;%%输出压力灵敏度矩阵
errcode=calllib('EPANETx64PDD','ENclose');%关闭tookit系统
unloadlibrary('EPANETx64PDD');
