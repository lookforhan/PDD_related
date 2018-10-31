% ʵ������[1]���㷨��
% ����������󷽷�
% ��������������������нڵ�����һ���ȸߵ��˹�ˮԴ���˹��ڵ�
classdef pdna < handle
    properties
        funcName = 'PDNA';
        libName = 'epanet2';
        hfileName = 'epanet2.h'
        lib_directory='C:\Users\hc042\Desktop\renxingjisuancode2\';
        active_directory
        output_directory
        temporary_directory
        inpFile
        middle_inpFile
        new_inpFile
        epa_format
        net_data
    end
    methods
        function obj = pdna() %��������
            loadlibrary([obj.lib_directory,obj.libName],[obj.lib_directory,obj.hfileName]);
            obj.active_directory = pwd;%��ǰĿ¼
            try
                load EPA_F
            catch
                path([obj.lib_directory,'toolkit'],path);
                path([obj.lib_directory,'readNet'],path);
                path([obj.lib_directory,'damageNet'],path);
                path([obj.lib_directory,'EPS'],path);
                path([obj.lib_directory,'getValue'],path);
                path([obj.lib_directory,'eventTime'],path);
                path([obj.lib_directory,'random'],path);
                path([obj.lib_directory,'random_singleTime'],path);%����ģ������ĺ�����
                load EPA_F
            end
            obj.epa_format = EPA_format;
            disp('����ļ�·����obj.output_dirctory=?')
            disp('��ʱ�ļ�·����obj.temporary_dirctory=��')
            disp('��ʱ�ļ�·����*obj.inpFile=��')
            disp('��ʱ�ļ�·����*obj.new_inpFile=��')
        end
        function delete(obj) % ��������
            unloadlibrary (obj.libName);
%             rmdir(obj.temporary_directory,'s');
        end
        function readInpfile(obj,Input_file) %�����׼inp�ļ�
            obj.inpFile = Input_file;
            [t1, obj.net_data  ] = read_net( input_net_filename,EPA_format);
            if t1
                disp('error in read_net')
                keyboard
            end    
        end
        function inp2new_inpfile(obj) % ����׼inp�ļ�ת��Ϊ���ʲο�����[1]��inp�ļ���
            obj.net_data
            
        end
    end
end