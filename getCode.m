function code=getCode(Datenum)
%�ж�ĳһ�죬ĳ����Լ�Ļ��ڲ��ڵ�ǰ���״�����
%����ڣ���Ҫ�жϺ�Լ��λ�á�
%������ڣ�ǰһ�����Ҫƽ��
%�����������ismember�����н��

%���ڵ��������ж�����ʱ�̵�00��01��02��03���ԵĴ���
%LastDate�������ʱ�̵�datenum  64*1 double
%Date��ÿ��ʱ�̵�datenum    351000*1 double
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
        
    





