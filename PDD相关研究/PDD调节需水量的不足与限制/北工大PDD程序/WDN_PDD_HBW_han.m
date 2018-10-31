%�������������Բ��ýڵ���ˮ����Pressure Dependent Demand��PDD ģ�ͽ������ˮ��ģ�ͼ������ĸ�ѹ���⡣
%��д�ˣ��ΰ��������������ҵ��ѧ��������ѧԺ,benweihou@bjut.edu.cn; (2018-8-2)
%�ο����ף�
%[1] �ΰ, ������. �����ƻ���ˮ������ѹˮ������[J]. ��ľ�����뻷������, 2013, 35(5):37-44.
%[2] LIU J, Yu G, SAVIC, D. Deficient-network simulation considering pressure-dependent demand[C]. The International Conference on Pipeline and Trenchless Technology, Beijing, China, October 26-29, 2011:886-900. 
%[3] ����,������,����.ѹ�������ĸ�ˮ������ˮ�����㷽��[J]. �人��ѧѧ��(��ѧ��), 2011, 44(1):79-82.
%[4] Wagner J M, Shamir U, Marks D H. Water distribution reliability: simulation methods[J]. Journal of water resources planning and management, 1988, 114(3): 276-294.
%% �޸�1��
% �ڳ���WDN_PDD_HBW.m��62�е�73�н������޸�
% ��ԭ���ע�ͣ������·�д���޸ĺ����
% �����˼���ǣ�
% ����bdemandΪ�ڵ��ʼ��ˮ����
% ����bdemand1Ϊÿ�ε���������Ľڵ���ˮ��������j����ˮ����
% ����bdemand2Ϊ����PDDģ�͵�����Ľڵ���ˮ��������j+1����ˮ����
% ԭ�����������߹�ϵд���ˡ�
%% �޸�2��
% ��20��Hdes=10��ΪHdes=20.
% Hdes=10�����PDDģ�͵���ʧЧ������,�Ժ��������ϸ���档
%%
clear all; close all;clc;tic;
%% ���������ļ�
root_name='EPA_case\'; %���������������ڵ��ļ������ƣ�
Intact_net_filename='Test2.inp';%�����ʼ����inp�ļ���+��ַ
EPA_format_filename='EPA_format4.txt';%��ʼ����inp�ļ��е����ݸ�ʽ
Modified_net_filename=['Modified_',Intact_net_filename];%��������ƻ�����inp�ļ�����
Intact_net_rpt_filename=['Intact_',Intact_net_filename(1:end-4),'.rpt'];
Intact_net_out_filename=['Intact_',Intact_net_filename(1:end-4),'.out'];
Modified_net_rpt_filename=['Modified_',Intact_net_filename(1:end-4),'.rpt'];
Modified_net_out_filename=['Modified_',Intact_net_filename(1:end-4),'.out'];
%% �����������,��������������[1]
Hmin=0;%PDDģ��Hmin�ڵ���Сѹ��ˮͷ(��λm)
Hdes=20;%PDDģ��Hdes�ڵ�����ѹ��ˮͷ(��λm);
circulation_num=40;%PDDѭ��������
doa=0.01;%PDD���㾫�ȣ�����ˮ��������λ(m)�����������ֵ��
%% ������������״̬��ˮ������
loadlibrary('epanet2.dll','epanet2.h'); 
code=calllib('epanet2','ENopen',[root_name,Intact_net_filename],[root_name,Intact_net_rpt_filename],[root_name,Intact_net_out_filename]);% �򿪹��������ļ�
if code==0
    calllib('epanet2','ENsolveH');
    calllib('epanet2','ENsaveH');
    pointer=libpointer('int32Ptr',0);
    [~,count_node]=calllib('epanet2','ENgetcount',0,pointer);
    [~,count_tank]=calllib('epanet2','ENgetcount',1,pointer);
    calllib('epanet2','ENsetreport','NODES ALL');
    calllib('epanet2','ENreport'); 
else
    disp(['����net.inp�ļ������������',num2str(code)]);
    calllib('epanet2','ENreport'); 
    calllib('epanet2','ENclose');
    return
end
%%  ���������Ƿ���ڽڵ㸺ѹ
junction_num=count_node-count_tank;
out_node_pressure=Get_hydraulic_results(junction_num,11);
out_node_demand=Get_hydraulic_results(junction_num,1);
calllib('epanet2','ENclose'); 
negative_node=find(out_node_pressure<0);
if ~isempty(negative_node)
    disp('����ˮ��������  ��  �ڵ㸺ѹ��');
    negative_check=1;
else
    disp('����ˮ��������  ��  �ڵ㸺ѹ��');
    negative_check=0;
end
%% PDD������ˮ����ˮ������,���Ĳ��õ�Wagner[4]�����PDDģ�ͣ�PDDģ��ʵ�ַ�������Liu[2]����ĵ�������
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
        disp('PDDģ�ͳɹ�����ڵ㸺ѹ���⣡') ;
    else
        disp('PDDģ�͵�����������PDDģ�Ͳ�����Ҫ������') ;
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
disp('���������');
toc;