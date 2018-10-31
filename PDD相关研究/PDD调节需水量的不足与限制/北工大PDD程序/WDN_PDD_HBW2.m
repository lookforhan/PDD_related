%�������������Բ��ýڵ���ˮ����Pressure Dependent Demand��PDD ģ�ͽ������ˮ��ģ�ͼ������ĸ�ѹ���⡣
%��д�ˣ��ΰ��������������ҵ��ѧ��������ѧԺ,benweihou@bjut.edu.cn; (2018-8-10)
%�ο����ף�
%[1] �ΰ, ������. �����ƻ���ˮ������ѹˮ������[J]. ��ľ�����뻷������, 2013, 35(5):37-44.
%[2] Jun L, Guoping Y. Iterative methodology of pressure-dependent demand based on EPANET for pressure-deficient water distribution analysis[J]. Journal of Water Resources Planning and Management, 2012, 139(1): 34-44. 
%[3] ����,������,����.ѹ�������ĸ�ˮ������ˮ�����㷽��[J]. �人��ѧѧ��(��ѧ��), 2011, 44(1):79-82.
%[4] Wagner J M, Shamir U, Marks D H. Water distribution reliability: simulation methods[J]. Journal of water resources planning and management, 1988, 114(3): 276-294.
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
Hdes=10;%PDDģ��Hdes�ڵ�����ѹ��ˮͷ(��λm);
circulation_num=40;%PDDѭ��������
Q_adjust_coefficent=0.3; %PDD�������������Ľڵ������ˮ�����������ĵ���ϵ��,Ϊȷ��������һ�㲻����5��
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
    Q_req=Get_hydraulic_results(junction_num,1); 
    for n=1:circulation_num 
        calllib('epanet2','ENsolveH');
        node_pre=Get_hydraulic_results(junction_num,11);
        Q_before=Get_hydraulic_results(junction_num,1);
        Q_after=Q_before;
        loc_1=node_pre<=Hmin;
        Q_after(loc_1)=(1-Q_adjust_coefficent)*Q_before(loc_1)+Q_adjust_coefficent*0;
        loc_2=(node_pre(:,1)>Hmin&node_pre(:,1)<Hdes);
        Q_after(loc_2)=(1-Q_adjust_coefficent)*Q_before(loc_2)+Q_adjust_coefficent*(Q_req(loc_2).*((node_pre(loc_2)-HMIN(loc_2))./(HDES(loc_2)-HMIN(loc_2))).^(1/2));
        error=abs(Q_after-Q_before);
        if max(error)<=doa
            break
        end
        for i=1:junction_num
            calllib('epanet2','ENsetnodevalue',i,1,Q_after(i,1));
        end
        calllib('epanet2','ENsaveH');
    end
    if n<circulation_num
        disp('PDDģ�ͳɹ�����ڵ㸺ѹ���⣡') ;
        disp(['PDDģ�͵Ĳ�������ϵ��Ϊ ',num2str(Q_adjust_coefficent),' ; ������������Ϊ ',num2str(n)]);
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