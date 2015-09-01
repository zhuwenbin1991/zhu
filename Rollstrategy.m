%��ʼ����Ϊ2011-01-05 09:16:00.000��IDΪ46981
%��������Ϊ2015-06-24 15:15:00.000,IDΪ339660
clc;
clear;
load IFDataall.mat
load lastdate.mat
load CodePareLd.mat

% global  LastDate
% getCode(Date(100000));

%ԭʼ����
LastDate=datenum(lastdate(:,1));
LastDatevec=datevec(LastDate);
c=[0 0 0 15 15 0];
c=repmat(c,length(LastDatevec),1);
LastDatevec1=LastDatevec+c;
LastDate=datenum(LastDatevec1);    %���ж�

LastDatevec=LastDatevec1(:,1:3);
Date=cell2mat(IFDatacell(:,1));    %���ж�
Datevec1=datevec(Date);
Datevec=Datevec1(:,1:3);
IF00Price=cell2mat(IFDatacell(:,2));
IF01Price=cell2mat(IFDatacell(:,4));
IF02Price=cell2mat(IFDatacell(:,6));
IF03Price=cell2mat(IFDatacell(:,8));

%�۲�����
spread10=IF01Price-IF00Price;
spread20=IF03Price-IF00Price;
spread30=IF03Price-IF00Price;
spread21=IF02Price-IF01Price;
spread31=IF03Price-IF01Price;
spread32=IF03Price-IF02Price;


%������ʼ��
pos=zeros(length(Date),1);              %��λ��ʼ��ΪIF00,pos��ȡ{0,1,2,3}
shortMargin=zeros(length(Date),1);
cash=repmat(1e5,length(Date),1);
dynamicEquity=repmat(1e5,length(Date),1);
staticEquity=repmat(1e5,length(Date),1);
tradingcost=0.00003;                     %����������
Length=30;                               %�ƶ�ƽ���߳���
OpenPosPrice=zeros(length(Date),1);       %��¼���ּ۸�
ClosePosPrice=zeros(length(Date),1);      %��¼ƽ�ּ۸�

OpenDate=zeros(length(Date),1);            %����ʱ��
CloseDate=zeros(length(Date),1);           %ƽ��ʱ��


%NetMargin=zeros(length(Date),1);               %����
%CumNetMargin=zeros(length(Date),1);            %�ۼƾ���

% ������Ա���deltaD,�Լ��۲��ȥdeltaD��ֵS
deltaD10=MA(spread10,Length);
deltaD20=MA(spread20,Length);
deltaD30=MA(spread30,Length);
deltaD21=MA(spread21,Length);
deltaD31=MA(spread31,Length);
deltaD32=MA(spread32,Length);

S10=spread10-deltaD10;
S20=spread20-deltaD20;
S30=spread30-deltaD30;
S21=spread21-deltaD21;
S31=spread31-deltaD31;
S32=spread32-deltaD32;


OpenPosNum=1;                            %���ּ۸���ţ��ڳ����ڵ��º�Լ�ϳֲ�
OpenPosPrice(1)=IF00Price(1); %��ʼ�ֲּ۸�
OpenDate(1)=Date(1);                     %��ʼ�ֲ�ʱ��
tempcode=getCode(OpenDate(1));
OpenCode(OpenPosNum)=tempcode(1);         %��ʼ���ֲֳ�     
ClosePosNum=0;                           %ƽ�ּ۸����
CloseCode=cell(1,4);

%% ���Բ���
for i=30:length(Date)-1
    if mod(i,10000)==0
        fprintf('������ɵ�%d��\n',i);
    end
    %������߽�����ǽ�����
    if test(LastDatevec,Datevec(i+1,:))==1  ||  test(LastDatevec,Datevec(i,:))==1              
        if i == length(Date)                     %�����ʱ�����гֲ�
            switch pos(i-1)
                case 0
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                case 1
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                case 2
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                case 3
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
            end
        end
        %% ����λ�ڵ��º�Լ    
        if i~=length(Date)    
            if pos(i-1)==0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�              
                CloseDate(ClosePosNum)=Date(i);            
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];  %ȷ��ƽ�ּۣ�ֵ��ע���������ƽ��ʱ������󽻸�ʱ�䣬��ƽ�ּ��������º�Լ�ơ�
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S20(i),S30(i)]);           %ѡ����۲��ֵ����
                switch b
                    case 1
                        pos(i)=1;                    
                        OpenPosPrice(OpenPosNum)=IF01Price(i); 
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=2;
                        OpenPosPrice(OpenPosNum)=IF02Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 3
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end       
            end

            %% ����λ�ڴ���01��Լ�����������º�Լ���Ʋ�
            if pos(i-1)==1  
                if spread21(i)>0 && spread31(i)>0
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                  
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    [a,b]=max([S21(i),S31(i)]);
                    switch b
                        case 1
                            pos(i)=2;
                            OpenPosPrice(OpenPosNum)=IF02Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                        case 2
                            pos(i)=3;
                            OpenPosPrice(OpenPosNum)=IF03Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    end
                end
                if (spread21(i)*spread31(i))<0
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                     
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    [a,b]=max([spread21(i),spread31(i)]);
                    switch b
                        case 1
                            pos(i)=2;
                            OpenPosPrice(OpenPosNum)=IF02Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                        case 2
                            pos(i)=3;
                            OpenPosPrice(OpenPosNum)=IF03Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    end
                end
                if spread21(i)<0 && spread31(i)<0
                    pos(i)=1;
                    continue;
                end
            end

            %% ����λ�ڵ���02��Լ�����������º�Լ���Ʋ�
            if pos(i-1)==2  
                if spread21(i)<0 && spread32(i)>0
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    [a,b]=max([abs(S21(i)),abs(S32(i))]);
                    switch b
                        case 1
                            pos(i)=1;
                            OpenPosPrice(OpenPosNum)=IF01Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                        case 2
                            pos(i)=3;
                            OpenPosPrice(OpenPosNum)=IF03Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    end
                end
                if spread21(i)*spread32(i)>0 && spread21(i)>0
                    pos(i)=3;
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                   
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    OpenPosPrice(OpenPosNum)=IF03Price(i);
                    tempcode=getCode(OpenDate(OpenPosNum));
                    OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
                if spread21(i)*spread32(i)>0 && spread21(i)<0
                    pos(i)=1;
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�            
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    OpenPosPrice(OpenPosNum)=IF01Price(i);
                    tempcode=getCode(OpenDate(OpenPosNum));
                    OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
                if spread21(i)>0 && spread32(i)<0
                    pos(i)=2;
                    continue;
                end
            end

            %% ����λ���¼�03��Լ�����������º�Լ���Ʋ�
            if pos(i-1)==3  
                if spread32(i)<0 && spread31(i)<0
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                 
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    [a,b]=max([abs(S32(i)),abs(S31(i))]);
                    switch b
                        case 1
                            pos(i)=1;
                            OpenPosPrice(OpenPosNum)=IF02Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                        case 2
                            pos(i)=2;
                            OpenPosPrice(OpenPosNum)=IF03Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    end
                end
                if spread32(i)*spread31(i)<0
                    ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                 
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                    OpenPosNum=OpenPosNum+1;
                    OpenDate(OpenPosNum)=Date(i);
                    [a,b]=min([spread32(i),spread31(i)]);
                    switch b
                        case 1
                            pos(i)=1;
                            OpenPosPrice(OpenPosNum)=IF02Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                        case 2
                            pos(i)=2;
                            OpenPosPrice(OpenPosNum)=IF03Price(i);
                            tempcode=getCode(OpenDate(OpenPosNum));
                            OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    end
                end
                if spread21(i)>0 && spread31(i)>0
                    pos(i)=3;
                    continue;
                end
            end
        end           
    end
    
    
    
    
    
    %% �ǽ����ռ�ǰһ��
    if  test(LastDatevec,Datevec(i+1,:))~=1  &&  test(LastDatevec,Datevec(i,:))~=1        
        %% ����λ�ڵ���00��Լ    
        if pos(i-1)==0         
            % �ж��Ʋ��������ǽ����տ��Ƶ����º�Լ���ı�pos�����һ�����гֲ֣���ƽ�֡���Բ��Ʋֵ�������ж�ƽ�ּ۸��Ƿ�Ҫ��Ծ��insideһ���������жϡ�ƽ�ּ۸�ȷ���Ժ�ֱ���㾻����
            if spread10(i)>0 && spread20(i)>0 &&spread30(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                 
                CloseDate(ClosePosNum)=Date(i);
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S20(i),S30(i)]);           %ѡ����۲��ֵ����
                switch b
                    case 1
                        pos(i)=1;                    
                        OpenPosPrice(OpenPosNum)=IF01Price(i);    
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=2;
                        OpenPosPrice(OpenPosNum)=IF02Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 3
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end 
            end
            
            if spread10(i)>0 && spread20(i)<0 && spread30(i)<0
                %�Ʋֵ����º�Լ
                pos(i)=1;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�                 
                CloseDate(ClosePosNum)=Date(i);
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF01Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread10(i)<0 && spread20(i)>0 && spread30(i)<0
                %�Ʋֵ�������Լ
                pos(i)=2;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                CloseDate(ClosePosNum)=Date(i);
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF02Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
           end
                
            
            if spread10(i)<0 && spread20(i)>0 && spread30(i)<0
                %�Ʋֵ��¼���Լ
                pos(i)=3;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�
                CloseDate(ClosePosNum)=Date(i);
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF02Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread10(i)>0 && spread20(i)>0 && spread30(i)<0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�              
                CloseDate(ClosePosNum)=Date(i);            
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];  %ȷ��ƽ�ּۣ�ֵ��ע���������ƽ��ʱ������󽻸�ʱ�䣬��ƽ�ּ��������º�Լ�ơ�
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S20(i)]);           %ѡ����۲��ֵ����
                switch b
                    case 1
                        pos(i)=1;                    
                        OpenPosPrice(OpenPosNum)=IF01Price(i); 
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=2;
                        OpenPosPrice(OpenPosNum)=IF02Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread10(i)>0 && spread20(i)<0 && spread30(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�              
                CloseDate(ClosePosNum)=Date(i);                              
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];   %ȷ��ƽ�ּۣ�ֵ��ע���������ƽ��ʱ������󽻸�ʱ�䣬��ƽ�ּ��������º�Լ�ơ�
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S30(i)]);           %ѡ����۲��ֵ����
                switch b
                    case 1
                        pos(i)=1;                    
                        OpenPosPrice(OpenPosNum)=IF01Price(i) ;
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread10(i)<0 && spread20(i)<0 && spread30(i)<0
                pos(i)=0;
                continue;
            end
            
        end
    
        
        
        %% ����λ�ڴ���01��Լ�������ô�Ʋ֣�����Ȼ��01��Լ�������ж����̼ۣ��Ƿ�Ҫ��ǰ��
        if pos(i-1)==1  
            if spread10(i)<0 && spread21(i)>0 && spread31(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S10(i)),S21(i),S31(i)]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=2;
                        OpenPosPrice(OpenPosNum)=IF02Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 3
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread10(i)>0 && spread21(i)>0 && spread31(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S21(i),S31(i)]);
                switch b
                    case 1
                        pos(i)=2;
                        OpenPosPrice(OpenPosNum)=IF02Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread10(i)<0 && spread21(i)<0 && spread31(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S10(i)),S31(i)]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i); 
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread10(i)>0 && spread21(i)>0 && spread31(i)<0
                pos(i)=2;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF02Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread10(i)>0 && spread21(i)<0 && spread31(i)>0
                pos(i)=3;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF03Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread10(i)<0 && spread21(i)<0 && spread31(i)<0
                pos(i)=0;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];              
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF00Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            %���Ʋֵ����
            if spread10(i)>0 && spread21(i)<0 && spread31(i)<0
                pos(i)=1;
                continue;
            end
                
        end
        
        
        %% ����λ�ڵ���02��Լ�����������º�Լ���Ʋ�
        if pos(i-1)==2  
            if spread20(i)<0 && spread21(i)<0 && spread32(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S20(i)),abs(S21(i)),S32(i)]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=1;
                        OpenPosPrice(OpenPosNum)=IF01Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 3
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread20(i)<0 && spread21(i)<0 && spread32(i)<0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S20(i)),abs(S21(i))]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=1;
                        OpenPosPrice(OpenPosNum)=IF01Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread20(i)<0 && spread21(i)>0 && spread32(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S20(i)),S32(i)]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF03Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread20(i)<0 && spread21(i)>0 && spread32(i)<0
                pos(i)=0;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF00Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread20(i)>0 && spread21(i)<0 && spread32(i)<0
                pos(i)=1;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF01Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread20(i)>0 && spread21(i)>0 && spread32(i)>0
                pos(i)=3;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF03Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            %���Ʋֵ����
            if spread20(i)>0 && spread21(i)>0 && spread32(i)<0
                pos(i)=2;
                continue;
            end          
        end
       
        
        %% ����λ���¼�03��Լ�����������Լ���Ʋ�
        if pos(i-1)==3  
            if spread30(i)<0 && spread31(i)<0 && spread32(i)<0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S30(i)),abs(S31(i)),abs(S32(i))]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=1;
                        OpenPosPrice(OpenPosNum)=IF01Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 3
                        pos(i)=3;
                        OpenPosPrice(OpenPosNum)=IF02Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread30(i)<0 && spread31(i)<0 && spread32(i)>0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S30(i)),abs(S31(i))]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=1;
                        OpenPosPrice(OpenPosNum)=IF01Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread30(i)<0 && spread31(i)>0 && spread32(i)<0
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([abs(S30(i)),abs(S32(i))]);
                switch b
                    case 1
                        pos(i)=0;
                        OpenPosPrice(OpenPosNum)=IF00Price(i);
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                    case 2
                        pos(i)=2;
                        OpenPosPrice(OpenPosNum)=IF02Price(i); 
                        tempcode=getCode(OpenDate(OpenPosNum));
                        OpenCode(OpenPosNum)=tempcode(pos(i)+1);
                end
            end
            
            if spread30(i)<0 && spread31(i)>0 && spread32(i)>0
                pos(i)=0;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF00Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread30(i)>0 && spread31(i)<0 && spread32(i)>0
                pos(i)=1;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF01Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            if spread30(i)>0 && spread31(i)>0 && spread32(i)<0
                pos(i)=2;
                ClosePosNum=ClosePosNum+1;                 %��ʼ�Ʋ�               
                CloseDate(ClosePosNum)=Date(i);                
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];                
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                OpenPosPrice(OpenPosNum)=IF02Price(i);
                tempcode=getCode(OpenDate(OpenPosNum));
                OpenCode(OpenPosNum)=tempcode(pos(i)+1);
            end
            
            %���Ʋֵ����
            if spread30(i)>0 && spread31(i)>0 && spread32(i)>0
                pos(i)=3;
                continue;
            end          
        end
    end
end              

%% ��Ч����
RecLength=ClosePosNum;
cost=zeros(length(RecLength),1);
NetMargin=zeros(length(RecLength),1);
for i=1:RecLength
    %ӯ������
    NetMargin(i)=OpenPosPrice(i)*(1-0.5/10000)-ClosePosPrice(i)*(1+0.5/10000);
    cost(i)=(OpenPosPrice(i)+ClosePosPrice(i))*0.5/10000;
    NetMargin(i)=NetMargin(i)-cost(i);
end

CumNetMargin=Plus(NetMargin(1:RecLength));





