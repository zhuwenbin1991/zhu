function c=Plus(a)
    %a是一个向量
    for i=1:length(a)
        if isnan(a(i))
            a(i)=0;
            continue;
        end
    end
    c=sum(a);

end