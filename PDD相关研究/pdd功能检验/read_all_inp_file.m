function [ t,net_data ] = read_all_inp_file( input_file )
%UNTITLED4 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
EPA_format_filename = 'EPA_format2.txt';
internal_inpfile = 'new.inp';
loadlibrary('epanet2.dll','epanet2.h'); %����EPA��̬���ӿ�
code=calllib('epanet2','ENopen',input_file,'in.rpt','in.out');% �򿪹��������ļ�
calllib('epanet2','ENsaveinpfile',internal_inpfile);
fid2=fopen(EPA_format_filename,'r'); %��EPAˮ��ģ���ļ������ݴ洢��ʽ������
    EPA_format=textscan(fid2,'%q%q%q','delimiter',';');%��ȡinp�ļ��еĹؼ��ʼ����ݴ洢���͸�ʽ���ļ���
    fclose(fid2);
    [t,net_data]=Read_File_dll_inp4(internal_inpfile,EPA_format);%��ȡˮ��ģ��inp�ļ������ݣ�
end

