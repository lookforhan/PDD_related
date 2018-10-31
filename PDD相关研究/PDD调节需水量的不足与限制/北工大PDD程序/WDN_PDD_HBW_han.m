%本程序用来测试采用节点需水量的Pressure Dependent Demand，PDD 模型解决管网水力模型计算结果的负压问题。
%编写人：侯本伟，韩朝，北京工业大学建筑工程学院,benweihou@bjut.edu.cn; (2018-8-2)
%参考文献：
%[1] 侯本伟, 杜修力. 地震破坏供水管网低压水力分析[J]. 土木建筑与环境工程, 2013, 35(5):37-44.
%[2] LIU J, Yu G, SAVIC, D. Deficient-network simulation considering pressure-dependent demand[C]. The International Conference on Pipeline and Trenchless Technology, Beijing, China, October 26-29, 2011:886-900. 
%[3] 周毅,陈永祥,李曦.压力决定的给水管网需水量计算方法[J]. 武汉大学学报(工学版), 2011, 44(1):79-82.
%[4] Wagner J M, Shamir U, Marks D H. Water distribution reliability: simulation methods[J]. Journal of water resources planning and management, 1988, 114(3): 276-294.
%% 修改1：
% 在程序WDN_PDD_HBW.m的62行到73行进行了修改
% 将原语句注释，并在下方写了修改后命令。
% 程序的思想是：
% 变量bdemand为节点初始需水量。
% 变量bdemand1为每次迭代计算出的节点需水量。（第j步需水量）
% 变量bdemand2为根据PDD模型调整后的节点需水量。（第j+1步需水量）
% 原来程序将这三者关系写错了。
%% 修改2：
% 将20行Hdes=10改为Hdes=20.
% Hdes=10会出现PDD模型调节失效的问题,稍后会整理详细报告。
%%
clear all; close all;clc;tic;
%% 输入数据文件
root_name='EPA_case\'; %算例管网数据所在的文件夹名称；
Intact_net_filename='Test2.inp';%输入初始管网inp文件名+地址
EPA_format_filename='EPA_format4.txt';%初始管网inp文件中的数据格式
Modified_net_filename=['Modified_',Intact_net_filename];%输出地震破坏管网inp文件名；
Intact_net_rpt_filename=['Intact_',Intact_net_filename(1:end-4),'.rpt'];
Intact_net_out_filename=['Intact_',Intact_net_filename(1:end-4),'.out'];
Modified_net_rpt_filename=['Modified_',Intact_net_filename(1:end-4),'.rpt'];
Modified_net_out_filename=['Modified_',Intact_net_filename(1:end-4),'.out'];
%% 计算参数设置,具体参数介绍详见[1]
Hmin=0;%PDD模型Hmin节点最小压力水头(单位m)
Hdes=20;%PDD模型Hdes节点需求压力水头(单位m);
circulation_num=40;%PDD循环次数；
doa=0.01;%PDD计算精度，两次水量调整单位(m)的相对误差，容许值；
%% 管网正常运行状态的水力计算
loadlibrary('epanet2.dll','epanet2.h'); 
code=calllib('epanet2','ENopen',[root_name,Intact_net_filename],[root_name,Intact_net_rpt_filename],[root_name,Intact_net_out_filename]);% 打开管网数据文件
if code==0
    calllib('epanet2','ENsolveH');
    calllib('epanet2','ENsaveH');
    pointer=libpointer('int32Ptr',0);
    [~,count_node]=calllib('epanet2','ENgetcount',0,pointer);
    [~,count_tank]=calllib('epanet2','ENgetcount',1,pointer);
    calllib('epanet2','ENsetreport','NODES ALL');
    calllib('epanet2','ENreport'); 
else
    disp(['读入net.inp文件出错！错误代码',num2str(code)]);
    calllib('epanet2','ENreport'); 
    calllib('epanet2','ENclose');
    return
end
%%  检查计算结果是否存在节点负压
junction_num=count_node-count_tank;
out_node_pressure=Get_hydraulic_results(junction_num,11);
out_node_demand=Get_hydraulic_results(junction_num,1);
calllib('epanet2','ENclose'); 
negative_node=find(out_node_pressure<0);
if ~isempty(negative_node)
    disp('管网水力计算结果  有  节点负压。');
    negative_check=1;
else
    disp('管网水力计算结果  无  节点负压。');
    negative_check=0;
end
%% PDD调整需水量后水力计算,本文采用的Wagner[4]提出的PDD模型，PDD模型实现方法采用Liu[2]提出的迭代方法
if negative_check==1
    calllib('epanet2','ENopen',[root_name,Intact_net_filename],[root_name,Modified_net_rpt_filename],[root_name,Modified_net_out_filename]);
    C_mid=ones(junction_num,1);
    HMIN=Hmin*C_mid;HDES=Hdes*C_mid;
    bdemand=Get_hydraulic_results(junction_num,1);
    for n=1:circulation_num 
        calllib('epanet2','ENsolveH');
        node_pre=Get_hydraulic_results(junction_num,11);
        bdemand1=Get_hydraulic_results(junction_num,1);
%         bdemand2=bdemand1;
        bdemand2=bdemand;  
%         bdemand1(node_pre<=Hmin)=0;
        bdemand2(node_pre<=Hmin)=0;
        ii=find(node_pre(:,1)>Hmin&node_pre(:,1)<Hdes);
%         bdemand1(ii,1)=0.5*(bdemand1(ii,1)+bdemand(ii,1).*((node_pre(ii,1)-HMIN(ii,1))./(HDES(ii,1)-HMIN(ii,1))).^(1/2));
        bdemand2(ii,1)=0.5*(bdemand1(ii,1)+bdemand(ii,1).*((node_pre(ii,1)-HMIN(ii,1))./(HDES(ii,1)-HMIN(ii,1))).^(1/2));
%         error=abs(bdemand1-bdemand2)./bdemand2;
        error=abs(bdemand2-bdemand1)./bdemand1;
        if max(error)<=doa
            break
        end
        for i=1:junction_num
%             calllib('epanet2','ENsetnodevalue',i,1,bdemand1(i,1));
            calllib('epanet2','ENsetnodevalue',i,1,bdemand2(i,1));
        end
        calllib('epanet2','ENsaveH');
    end
    if n< circulation_num
        disp('PDD模型成功处理节点负压问题！') ;
    else
        disp('PDD模型迭代不收敛，PDD模型参数需要调整！') ;
    end
    calllib('epanet2','ENsaveinpfile',[root_name,Modified_net_filename]); 
    calllib('epanet2','ENclose');
end
calllib('epanet2','ENopen',[root_name,Modified_net_filename],[root_name,Modified_net_rpt_filename],[root_name,Modified_net_out_filename]);
calllib('epanet2','ENsolveH');
calllib('epanet2','ENsaveH');
calllib('epanet2','ENsetreport','NODES ALL');
calllib('epanet2','ENreport'); 
calllib('epanet2','ENclose'); 
unloadlibrary epanet2;
disp('计算结束！');
toc;