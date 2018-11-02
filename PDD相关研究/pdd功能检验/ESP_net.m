function [ Pressure,Demand,Length,system_L_cell,system_serviceability_cell,node_serviceability_cell] = ESP_net( output_net_filename_inp,MC_simulate_result_dir,PipeStatus,pipe_relative,net_data,...
    circulation_num,doa,Hmin,Hdes)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
system_original_L = sum(cell2mat(net_data{5,2}(:,4)));
mid_t = libisloaded('epanet2');
if mid_t == 0
    loadlibrary('epanet2.dll','epanet2.h');
end
calllib('epanet2','ENopen',output_net_filename_inp,[MC_simulate_result_dir,'\','1.rpt'],[MC_simulate_result_dir,'\','1.out']);
% node_id_k=libpointer('cstring','node_id_k');
% value_dem=libpointer('singlePtr',0);

calllib('epanet2','ENopenH');
calllib('epanet2','ENinitH',1);

temp_t =0;
temp_tstep =1;
i=0;
n_count=1;
node_id = net_data{2,2}(:,1);
original_junction_num = numel(node_id);
link_id = net_data{5,2}(:,1);
key_flag = 0;
    if ~isempty(PipeStatus)
    max_time = numel(PipeStatus(1,:));
    else
        max_time =24*3600;
    end
while temp_tstep
    if key_flag == 1
        break
    end
    
    i=i+1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [errcode,temp_t]=calllib('epanet2','ENrunH',temp_t);%计算
    n_j =0;
    n_r=0;
    [c,n_j] = calllib('epanet2','ENgetcount',0,n_j);
    [c,n_r] = calllib('epanet2','ENgetcount',1,n_r);
    junction_num =n_j -n_r;
    [~,based_demand]=Get(junction_num,1);%实际需水量
    [~,real_demand]=Get(junction_num,9);%实际需水量
    [~,real_pre]=Get(junction_num,11);%实际需水量
    [~,real_demand_chosen]=Get_chosen_node_value(original_junction_num,node_id);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [pre,dem] = EPS_PDD(circulation_num,doa,Hmin,Hdes,net_data,temp_t,real_demand,based_demand);

    if temp_t <=5
        %         [pre,dem]=Get_chosen_node_value(original_junction_num,node_id);
        Pressure{n_count} = pre;
        Demand{n_count}=dem;
        len = Get_chosen_link_value(link_id);
        Length{n_count}=len;
        system_L_cell {n_count}= len/system_original_L;
        node_serviceability_cell{n_count} =dem./real_demand_chosen;
        system_serviceability_cell{n_count}=sum(dem)/sum(real_demand_chosen);
    else
        if temp_t>max_time
            %             keyboard
            mid_t = max_time;
            key_flag = 1;
        else
            mid_t = temp_t;
        end
        if ~isempty(PipeStatus)
            if PipeStatus(:,mid_t)==PipeStatus(:,mid_t-100)
        else
            n_count = n_count+1;
            %             [pre,dem]=Get_chosen_node_value(original_junction_num,node_id);
            Pressure{n_count} = pre;
            Demand{n_count}=dem;
            len = Get_chosen_link_value(link_id);
            Length{n_count}=len;
            system_L_cell{n_count}= len/system_original_L;
%             if numel(dem)~=numel(
%             end
            node_serviceability_cell{n_count} =dem./real_demand_chosen;
            system_serviceability_cell{n_count}=sum(dem)/sum(real_demand_chosen);
            if numel(PipeStatus(:,1))~=numel(pipe_relative(:,1))
                keyboard
            end
            for i = 1:numel(PipeStatus(:,1))
                status = PipeStatus(i,mid_t);
                
                n=0;
                switch status
                    case 2
                        
                    case 1
                        n = numel(pipe_relative{i,2});
                        for j =1:n
                            id=libpointer('cstring',pipe_relative{i,2}{1,j});
                            index =libpointer('int32Ptr',0);
                            [code,id,index]=calllib('epanet2','ENgetlinkindex',id,index);
                            n=calllib('epanet2','ENsetlinkvalue',index,4,0);
                        end
                        
                    case 0
                        id=libpointer('cstring',pipe_relative{i,1});
                        %                         id = pipe_relative{i,1};
                        index =libpointer('int32Ptr',0);
                        [code,id,index]=calllib('epanet2','ENgetlinkindex',id,index);
                        n= calllib('epanet2','ENsetlinkvalue',index,4,1);
                end
                if n~=0
                    keyboard
                end
                %                 calllib('epanet2','ENsaveinpfile',[MC_simulate_result_dir,'\',num2str(mid_t),'.inp']);
            end
        end
        end
        
    end
    [errcode,temp_tstep]=calllib('epanet2','ENnextH',temp_tstep);
    disp(num2str(temp_t))
    ;
end
calllib('epanet2','ENcloseH');
calllib('epanet2','ENsaveH');%保存水力文件
calllib('epanet2','ENsetreport','NODES ALL'); % 设置输出报告的格式
calllib('epanet2','ENreport');
calllib('epanet2','ENclose');

end

