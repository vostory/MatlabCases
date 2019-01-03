function name1=Casename(i)
%定义函数，用于输出工况的名称

  %*********************1.0MPa****************************
if i==1,
    name1='p10barug025';
elseif i==2,
    name1='p10barug0367';
elseif i==3,
    name1='p10barug050';
elseif i==4,
    name1='p10barug060';
elseif i==5,
    name1='p10barug070';
elseif i==6,
    name1='p10barug080';
elseif i==7,
    name1='p10barug090';
    
    
    %*********************0.6MPa****************************
elseif i==8,
    name1='p6barug025';
elseif i==9,
    name1='p6barug0367';
elseif i==10,
    name1='p6barug050';
elseif i==11,
    name1='p6barug060';
elseif i==12,
    name1='p6barug070';
elseif i==13,
    name1='p6barug085';
elseif i==14,
    name1='p6barug100';
    
    
    %*********************0.1MPa****************************
elseif i==15,
    name1='ug037p1bar';
elseif i==16,
    name1='ug500';
elseif i==17,
    name1='ug062p1bar';
elseif i==18,
    name1='ug075p1bar';
elseif i==19,
    name1='ug100p1bar';
elseif i==20,
    name1='ug115p1bar';
elseif i==21,
    name1='ug140p1bar';
end
%