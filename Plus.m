function c=Plus(a)
    %a��һ������
    for i=1:length(a)
        if isnan(a(i))
            a(i)=0;
            continue;
        end
    end
    c=sum(a);

end