% pdna for net01
% name: pdna_for_net01
% PROCESS
n_j =0;
n_r=0;
R_num=0;
R_id='0';
JJ_id=cell(4,1);
JJ_id{1} = '1-J';
JJ_id{2} = '2-J';
JJ_id{3} = '3-J';
JJ_id{4} = '4-J';
JR_id=cell(4,1);
JR_id{1} = '1-R';
JR_id{2} = '2-R';
JR_id{3} = '3-R';
JR_id{4} = '4-R';
J_id = cell(4,1);
J_id{1} = '1';
J_id{2} = '2';
J_id{3} = '3';
J_id{4} = '4';
% int32 = libpointer('int32Ptr',0);
cstring = libpointer('cstring','id');
J_elevation = [90;88;90;85];
J_demand = [33.33;33.33;50;66.67];
R_head = [84;85;89.08;90.98;91.03;91.97;96.92;98.78;100.0;109.86];
J_head_cell=cell(numel(R_head),1);
J_demand_cell=cell(numel(R_head),1);
J_pressure_cell=cell(numel(R_head),1);

% for  j = 1: numel(R_head)
step1 = 0;
for  j = 1
    c = calllib(libName,'ENopen',output_net_file{1},'1.rpt','');%打开inp
    if c
        keyboard
    end
    id = libpointer('cstring',R_id);
    int32 = libpointer('int32Ptr',1);
    [c,~,index] = calllib(libName,'ENgetnodeindex',id,int32);% 找到Reservoirs
    if c
        disp(num2str(c));
        keyboard
    end
    c = calllib(libName,'ENsetnodevalue',index,0,R_head(j));%给Reservoirs head 赋值
    if c
        disp(num2str(c));
        keyboard
    end
    c = calllib(libName,'ENsolveH');% run hydraulic analysis.
    if c
        disp(num2str(c));
        keyboard
    end
    
%     stop1 = 1;
%     while stop1 ==1
%         step1 =step1+1;
%         c = calllib(libName,'ENsolveH');% run hydraulic analysis.
%         if c
%             disp(num2str(c));
%             keyboard
%         end
%         [t,JR_demand]=Get_chosen_node_value2(JR_id,9);% demand
%         if t
%             disp(num2str(c));
%             keyboard
%         end        
%         [t,J_pressure]=Get_chosen_node_value2(J_id,11);% pressure
%         if t
%             disp(num2str(c));
%             keyboard
%         end
%        J_pressure_cell{j} = J_pressure;
%        JR_demand_cell{j} = JR_demand;
%        loc = find(J_pressure>0);
%        if ~isempty(loc)
%            continue
%        end
%        
%        if step1 >20
%            break
%        end
%     end
%             [t,J_head]=Get_chosen_node_value2(J_id,10);% head
%         
%         if t
%             disp(num2str(c));
%             keyboard
%         end
%      
%      
%      J_head_cell{j} = J_head;
    % process of pressure
    c = calllib(libName,'ENclose');
    if c
        keyboard
    end
end
% c = calllib(libName,'ENclose');
% if c
%     disp(num2str(c));
%     keyboard
% end
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