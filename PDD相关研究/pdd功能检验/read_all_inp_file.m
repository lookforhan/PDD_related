function [ t,net_data ] = read_all_inp_file( input_file )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
EPA_format_filename = 'EPA_format2.txt';
internal_inpfile = 'new.inp';
loadlibrary('epanet2.dll','epanet2.h'); %加载EPA动态链接库
code=calllib('epanet2','ENopen',input_file,'in.rpt','in.out');% 打开管网数据文件
calllib('epanet2','ENsaveinpfile',internal_inpfile);
fid2=fopen(EPA_format_filename,'r'); %打开EPA水力模型文件的数据存储格式参数；
    EPA_format=textscan(fid2,'%q%q%q','delimiter',';');%读取inp文件中的关键词及数据存储类型格式的文件；
    fclose(fid2);
    [t,net_data]=Read_File_dll_inp4(internal_inpfile,EPA_format);%读取水力模型inp文件的数据；
end

