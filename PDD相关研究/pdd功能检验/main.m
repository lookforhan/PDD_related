% main
circulation_num =30;
doa = 0.01;
Hmin = 0;
Hdes =20;
filename_inp = 'linshi.inp';
MC_simulate_result_dir ='.\';
[t,net_data ]= read_all_inp_file (filename_inp);
PipeStatus=[];
pipe_relative=[];
[ Pressure,Demand,Length,system_L_cell,system_serviceability_cell,node_serviceability_cell] = ESP_net( filename_inp,...
    MC_simulate_result_dir,PipeStatus,pipe_relative,net_data,...
    circulation_num,doa,Hmin,Hdes);