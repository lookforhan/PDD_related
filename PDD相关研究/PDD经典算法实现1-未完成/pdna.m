% 实现论文[1]的算法。
% 采用面向对象方法
% 读入管网，并将管网所有节点增加一个等高的人工水源和人工节点
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
        function obj = pdna() %创建对象
            loadlibrary([obj.lib_directory,obj.libName],[obj.lib_directory,obj.hfileName]);
            obj.active_directory = pwd;%当前目录
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
                path([obj.lib_directory,'random_singleTime'],path);%单点模拟所需的函数。
                load EPA_F
            end
            obj.epa_format = EPA_format;
            disp('输出文件路径：obj.output_dirctory=?')
            disp('临时文件路径：obj.temporary_dirctory=？')
            disp('临时文件路径：*obj.inpFile=？')
            disp('临时文件路径：*obj.new_inpFile=？')
        end
        function delete(obj) % 析构对象
            unloadlibrary (obj.libName);
%             rmdir(obj.temporary_directory,'s');
        end
        function readInpfile(obj,Input_file) %读入标准inp文件
            obj.inpFile = Input_file;
            [t1, obj.net_data  ] = read_net( input_net_filename,EPA_format);
            if t1
                disp('error in read_net')
                keyboard
            end    
        end
        function inp2new_inpfile(obj) % 将标准inp文件转化为合适参考文献[1]的inp文件。
            obj.net_data
            
        end
    end
end