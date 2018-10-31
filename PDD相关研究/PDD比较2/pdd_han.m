% pdd_han
% ��������WDN_PDD_HBW2.m�еķ�����
clc;clear;
libName = 'epanet2'
root_name='EPA_case\'; %���������������ڵ��ļ������ƣ�
Intact_net_filename='net02.inp';%�����ʼ����inp�ļ���+��ַ
EPA_format_filename='EPA_format4.txt';%��ʼ����inp�ļ��е����ݸ�ʽ
Modified_net_filename=['Modified_',Intact_net_filename];%��������ƻ�����inp�ļ�����
Intact_net_rpt_filename=['Intact_',Intact_net_filename(1:end-4),'.rpt'];
Intact_net_out_filename=['Intact_',Intact_net_filename(1:end-4),'.out'];
Modified_net_rpt_filename=['Modified_',Intact_net_filename(1:end-4),'.rpt'];
Modified_net_out_filename=['Modified_',Intact_net_filename(1:end-4),'.out'];
%% �����������,��������������[1]
Hmin=0;%PDDģ��Hmin�ڵ���Сѹ��ˮͷ(��λm)
Hdes=10;%PDDģ��Hdes�ڵ�����ѹ��ˮͷ(��λm);
circulation_num=200;%PDDѭ��������
Q_adjust_coefficent=0.5; %PDD�������������Ľڵ������ˮ�����������ĵ���ϵ��,Ϊȷ��������һ�㲻����5��
doa=0.01;%PDD���㾫�ȣ�����ˮ��������λ(m)�����������ֵ��
loadlibrary('epanet2.dll','epanet2.h');
code=calllib('epanet2','ENopen',Intact_net_filename,[root_name,Intact_net_rpt_filename],[root_name,Intact_net_out_filename]);% �򿪹��������ļ�
if code==0
    
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
R_head = [86;88;90;92;94;96;98;100.0;117.56];
demand_cell = cell(numel(R_head),1);
J_basedemand = [25;25;25;25;25;75];
junction_num=count_node-count_tank;
for i_head =1:numel(R_head)
    for n_node = 1:junction_num
        c = calllib(libName,'ENsetnodevalue',n_node,1,J_basedemand(n_node));%��Reservoirs head ��ֵ
    end
    c = calllib(libName,'ENsetnodevalue',7,0,R_head(i_head));%��Reservoirs head ��ֵ
    disp(['ˮԴˮͷΪ��',num2str(R_head(i_head))])
    calllib('epanet2','ENsolveH');
    %%  ���������Ƿ���ڽڵ㸺ѹ
    
    out_node_pressure=Get_hydraulic_results(junction_num,11);
    out_node_demand=Get_hydraulic_results(junction_num,1);
    negative_node=find(out_node_pressure<10);
    if ~isempty(negative_node)
        disp('����ˮ��������  ��  �ڵ㸺ѹ��');
        negative_check=1;
    else
        demand_cell{i_head} = out_node_demand;
        disp('����ˮ��������  ��  �ڵ㸺ѹ��');
        negative_check=0;
    end
    %% PDD������ˮ����ˮ������,���Ĳ��õ�Wagner[4]�����PDDģ�ͣ�PDDģ��ʵ�ַ�������Liu[2]����ĵ�������
    if negative_check==1
        %     calllib('epanet2','ENopen',Intact_net_filename,[root_name,Modified_net_rpt_filename],[root_name,Modified_net_out_filename]);
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
        demand_cell{i_head} = Q_after;
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
xlswrite('net0202_10_0.8.xls',mid_4)
calllib(libName,'ENclose');