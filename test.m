function  c  = test( a, b )
% �������Ĺ������ж�����b�Ƿ������a�е�ĳһ�����
    c=0;
    for i=1:size(a,1)
        if sum(abs(a(i,:)-b))==0
            c=1;
            break;
        end
    end
end