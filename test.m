function  c  = test( a, b )
% 本函数的功能是判断向量b是否与矩阵a中的某一行相等
    c=0;
    for i=1:size(a,1)
        if sum(abs(a(i,:)-b))==0
            c=1;
            break;
        end
    end
end