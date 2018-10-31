function value=Get_hydraulic_results(junction_num,n)
pointer=libpointer('singlePtr',0);
value=zeros(junction_num,1);
    for i=1:junction_num
        [~,a]=calllib('epanet2','ENgetnodevalue',i,n,pointer);
        value(i,1)=a;        
    end
end