%%2017.10.29��
clc; clear all; close all;

%���ؼ������沢��ˮ��ģ���ļ�
errcode=loadlibrary('epanet2.dll','epanet2.h');%����EPANET�ļ�
errcode=calllib('epanet2','ENopen','ky11_Jolly2013_base.inp','Net.rpt','');%��inp�ļ�
%�������ӽڵ�����
nodenum=0;%nodenum���ܽڵ���Ŀ�����Ը�������ֵ�����Ը�������ֵ
[errcode,nodenum]=calllib('epanet2','ENgetcount',0,nodenum);%��ȡ�ܽڵ���Ŀ��ע���ȡ��ֵ�ķ�ʽ������Ҫ����ͬ�Ĳ���nodenum��Ҳ���Բ�ͬ
%0�����ȡ�ܽڵ���Ŀ�Ĵ��룬��ߵ�nodenumΪ����ֵ�Ĵ洢�������ұ�nodenumΪ��ʼֵ��
tank=0;%tanknum��ˮԴ�ڵ���Ŀ�����Ը�������ֵ����Ҫ��ȡˮԴ�ڵ���Ŀ�����ʼ��
[errcode,tank]=calllib('epanet2','ENgetcount',1,tank);%��ȡˮԴ����Ŀ����ʽ���������ͬ��1�����ȡˮԴ�ڵ���Ŀ�Ĵ���
junctionnum=nodenum - tank;%junctionnum�����ӽڵ���Ŀ��ע�����ӽڵ���Ŀ�����ܽڵ�����ȥˮԴ�ڵ���

%��ȡ���������µĽڵ�ѹ���ͻ�����ˮ��
errcode=calllib('epanet2','ENopenH');%��ˮ������ϵͳ
errcode=calllib('epanet2','ENinitH',0);%��ʼ����ˮ��ˮλ���ܵ�״̬�������Լ�ģ��ʱ�䣬0��ʾ���洢������ˮ�����
time=0;%��ʼ������ʱ�䣬����������ֵ
pressure=0;
base_demand=0;
tstep=1;%��ʼ��ˮ�������Ĳ������������������ֵ
while (tstep && ~errcode)
    [errcode,time]=calllib('epanet2','ENrunH',time);%ִ����timeʱ�̵�ˮ������
    number=double(time)/3600;
    if (number==2)%��ȡ��2��ˮ��������ˮ������
        for i=1:junctionnum
            [errcode,pressure]=calllib('epanet2','ENgetnodevalue',i,11,pressure);
            [errcode,base_demand]=calllib('epanet2','ENgetnodevalue',i,1,base_demand);
            pressurevalue(i)=pressure;
            basedemandvalue(i)=base_demand;
        end
    end
    [errcode,tstep]=calllib('epanet2','ENnextH',tstep);
end
errcode=calllib('epanet2','ENcloseH');%�ر�ˮ������ϵͳ���ͷ��ڴ�
pressurevalue;
basedemandvalue;
errcode=calllib('epanet2','ENclose');%�ر�tookitϵͳ
unloadlibrary('epanet2');


%%%%%%%%%%%%%%% ִ��PDDģ��%%%%%%%%%%%%
%���ؼ������沢��ˮ��ģ���ļ�
errcode=loadlibrary('EPANETx64PDD.dll','toolkit.h');%����EPANET�ļ�
errcode=calllib('EPANETx64PDD','ENopen','ky11_Jolly2013.inp','Net.rpt','');%��inp�ļ�
tstep=1;
pressurenew=0;
time=0;
number=0;
for i=1:junctionnum
    errcode=calllib('EPANETx64PDD','ENopenH');
    basedemand_new(i)= basedemandvalue(i)+5;%�ı�ڵ�i����ɢϵ�����Ӷ��ı乤��
    errcode=calllib('EPANETx64PDD','ENsetnodevalue',i,1,basedemand_new(i));%���µĽڵ���ɢϵ������ڵ�i
    errcode=calllib('EPANETx64PDD','ENinitH',0);
    while (tstep && ~errcode)
        [errcode,time]=calllib('EPANETx64PDD','ENrunH',time);%ִ����timeʱ�̵�ˮ������
        number=double(time)/3600;
        if (number==2)
            for j=1:junctionnum
                [errcode,pressurenew]=calllib('EPANETx64PDD','ENgetnodevalue',j,11,pressurenew);
                pressure_new(j,i)=pressurenew;
               tao=-(pressure_new(j,i) - pressurevalue(j));
               if tao<0.09
                   tao=0;
               end 
                P_matrix(j,i)=tao;
             end  
            end
       
        [errcode,tstep]=calllib('EPANETx64PDD','ENnextH',tstep);
    end
    tstep=1;
    errcode=calllib('EPANETx64PDD','ENsetnodevalue',i,1,basedemandvalue(i));%ע��ÿһ��ѭ����Ҫ�Ѹı��Ľڵ���ɢϵ���Ļ�ԭ���Ľڵ���ɢϵ��
    errcode=calllib('EPANETx64PDD','ENcloseH');
end
P_matrix;%%���ѹ�������Ⱦ���
errcode=calllib('EPANETx64PDD','ENclose');%�ر�tookitϵͳ
unloadlibrary('EPANETx64PDD');
