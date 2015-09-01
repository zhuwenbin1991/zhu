function code=getCode(Datenum)
%判断某一天，某个合约的还在不在当前交易代码中
%如果在，需要判断合约的位置。
%如果不在，前一天就需要平仓
%上述问题可在ismember（）中解决

%现在的问题是判断任意时刻的00、01、02、03各自的代码
%LastDate是最后交易时刻的datenum  64*1 double
%Date是每个时刻的datenum    351000*1 double
global CodePareLd LastDate
code=cell(1,4);
for i=1:length(LastDate)
    if i==1
        if Datenum<=LastDate(i)
            code=CodePareLd(i,2:5);
            break
        end
    else 
        if Datenum <= LastDate(i) && Datenum > LastDate(i-1)
            code=CodePareLd(i,2:5);
            break
        end
    end
end
        
    





