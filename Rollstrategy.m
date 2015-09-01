%开始日期为2011-01-05 09:16:00.000，ID为46981
%结束日期为2015-06-24 15:15:00.000,ID为339660
clc;
clear;
load IFDataall.mat
load lastdate.mat
load CodePareLd.mat

% global  LastDate
% getCode(Date(100000));

%原始数据
LastDate=datenum(lastdate(:,1));
LastDatevec=datevec(LastDate);
c=[0 0 0 15 15 0];
c=repmat(c,length(LastDatevec),1);
LastDatevec1=LastDatevec+c;
LastDate=datenum(LastDatevec1);    %做判断

LastDatevec=LastDatevec1(:,1:3);
Date=cell2mat(IFDatacell(:,1));    %做判断
Datevec1=datevec(Date);
Datevec=Datevec1(:,1:3);
IF00Price=cell2mat(IFDatacell(:,2));
IF01Price=cell2mat(IFDatacell(:,4));
IF02Price=cell2mat(IFDatacell(:,6));
IF03Price=cell2mat(IFDatacell(:,8));

%价差数据
spread10=IF01Price-IF00Price;
spread20=IF03Price-IF00Price;
spread30=IF03Price-IF00Price;
spread21=IF02Price-IF01Price;
spread31=IF03Price-IF01Price;
spread32=IF03Price-IF02Price;


%参数初始化
pos=zeros(length(Date),1);              %仓位初始化为IF00,pos可取{0,1,2,3}
shortMargin=zeros(length(Date),1);
cash=repmat(1e5,length(Date),1);
dynamicEquity=repmat(1e5,length(Date),1);
staticEquity=repmat(1e5,length(Date),1);
tradingcost=0.00003;                     %交易手续费
Length=30;                               %移动平均线长度
OpenPosPrice=zeros(length(Date),1);       %记录建仓价格
ClosePosPrice=zeros(length(Date),1);      %记录平仓价格

OpenDate=zeros(length(Date),1);            %建仓时间
CloseDate=zeros(length(Date),1);           %平仓时间


%NetMargin=zeros(length(Date),1);               %净利
%CumNetMargin=zeros(length(Date),1);            %累计净利

% 计算策略变量deltaD,以及价差减去deltaD的值S
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


OpenPosNum=1;                            %建仓价格序号，期初已在当月合约上持仓
OpenPosPrice(1)=IF00Price(1); %初始持仓价格
OpenDate(1)=Date(1);                     %初始持仓时间
tempcode=getCode(OpenDate(1));
OpenCode(OpenPosNum)=tempcode(1);         %初始开仓持仓     
ClosePosNum=0;                           %平仓价格序号
CloseCode=cell(1,4);

%% 策略部分
for i=30:length(Date)-1
    if mod(i,10000)==0
        fprintf('正在完成第%d行\n',i);
    end
    %明天或者今天就是交割日
    if test(LastDatevec,Datevec(i+1,:))==1  ||  test(LastDatevec,Datevec(i,:))==1              
        if i == length(Date)                     %若最后时间仍有持仓
            switch pos(i-1)
                case 0
                    ClosePosNum=ClosePosNum+1;                 %开始移仓
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                case 1
                    ClosePosNum=ClosePosNum+1;                 %开始移仓
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                case 2
                    ClosePosNum=ClosePosNum+1;                 %开始移仓
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                case 3
                    ClosePosNum=ClosePosNum+1;                 %开始移仓
                    CloseDate(ClosePosNum)=Date(i);
                    CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                    [a,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                    ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
            end
        end
        %% 若仓位在当月合约    
        if i~=length(Date)    
            if pos(i-1)==0
                ClosePosNum=ClosePosNum+1;                 %开始移仓              
                CloseDate(ClosePosNum)=Date(i);            
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];  %确定平仓价，值得注意的是若开平仓时间跨过最后交割时间，则平仓价需往当月合约推。
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S20(i),S30(i)]);           %选择离价差均值最大的
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

            %% 若仓位在次月01合约，不能往当月合约上移仓
            if pos(i-1)==1  
                if spread21(i)>0 && spread31(i)>0
                    ClosePosNum=ClosePosNum+1;                 %开始移仓                  
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
                    ClosePosNum=ClosePosNum+1;                 %开始移仓                     
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

            %% 若仓位在当季02合约，不能往当月合约上移仓
            if pos(i-1)==2  
                if spread21(i)<0 && spread32(i)>0
                    ClosePosNum=ClosePosNum+1;                 %开始移仓
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
                    ClosePosNum=ClosePosNum+1;                 %开始移仓                   
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
                    ClosePosNum=ClosePosNum+1;                 %开始移仓            
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

            %% 若仓位在下季03合约，不能往当月合约上移仓
            if pos(i-1)==3  
                if spread32(i)<0 && spread31(i)<0
                    ClosePosNum=ClosePosNum+1;                 %开始移仓                 
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
                    ClosePosNum=ClosePosNum+1;                 %开始移仓                 
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
    
    
    
    
    
    %% 非交割日及前一天
    if  test(LastDatevec,Datevec(i+1,:))~=1  &&  test(LastDatevec,Datevec(i,:))~=1        
        %% 若仓位在当月00合约    
        if pos(i-1)==0         
            % 判断移仓条件。非交割日可移到当月合约。改变pos。最后一天若有持仓，则平仓。针对不移仓的情况，判断平仓价格是否要跳跃，inside一个函数来判断。平仓价格确定以后，直接算净利。
            if spread10(i)>0 && spread20(i)>0 &&spread30(i)>0
                ClosePosNum=ClosePosNum+1;                 %开始移仓                 
                CloseDate(ClosePosNum)=Date(i);
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S20(i),S30(i)]);           %选择离价差均值最大的
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
                %移仓到次月合约
                pos(i)=1;
                ClosePosNum=ClosePosNum+1;                 %开始移仓                 
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
                %移仓到当季合约
                pos(i)=2;
                ClosePosNum=ClosePosNum+1;                 %开始移仓
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
                %移仓到下季合约
                pos(i)=3;
                ClosePosNum=ClosePosNum+1;                 %开始移仓
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓              
                CloseDate(ClosePosNum)=Date(i);            
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];  %确定平仓价，值得注意的是若开平仓时间跨过最后交割时间，则平仓价需往当月合约推。
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S20(i)]);           %选择离价差均值最大的
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓              
                CloseDate(ClosePosNum)=Date(i);                              
                CloseCode(ClosePosNum)=getCode(CloseDate(ClosePosNum));
                [~,b]=ismember(OpenCode(OpenPosNum),CloseCode(ClosePosNum));
                ClosePosPrice(ClosePosNum)=['IF0',num2str(b-1),'Price(',num2str(i),')'];   %确定平仓价，值得注意的是若开平仓时间跨过最后交割时间，则平仓价需往当月合约推。
                OpenPosNum=OpenPosNum+1;
                OpenDate(OpenPosNum)=Date(i);
                [a,b]=max([S10(i),S30(i)]);           %选择离价差均值最大的
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
    
        
        
        %% 若仓位在次月01合约，随便怎么移仓，若依然在01合约，则需判断收盘价，是否要往前推
        if pos(i-1)==1  
            if spread10(i)<0 && spread21(i)>0 && spread31(i)>0
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
            
            %不移仓的情况
            if spread10(i)>0 && spread21(i)<0 && spread31(i)<0
                pos(i)=1;
                continue;
            end
                
        end
        
        
        %% 若仓位在当季02合约，不能往当月合约上移仓
        if pos(i-1)==2  
            if spread20(i)<0 && spread21(i)<0 && spread32(i)>0
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
            
            %不移仓的情况
            if spread20(i)>0 && spread21(i)>0 && spread32(i)<0
                pos(i)=2;
                continue;
            end          
        end
       
        
        %% 若仓位在下季03合约，可在任意合约上移仓
        if pos(i-1)==3  
            if spread30(i)<0 && spread31(i)<0 && spread32(i)<0
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
                ClosePosNum=ClosePosNum+1;                 %开始移仓               
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
            
            %不移仓的情况
            if spread30(i)>0 && spread31(i)>0 && spread32(i)>0
                pos(i)=3;
                continue;
            end          
        end
    end
end              

%% 绩效评价
RecLength=ClosePosNum;
cost=zeros(length(RecLength),1);
NetMargin=zeros(length(RecLength),1);
for i=1:RecLength
    %盈利点数
    NetMargin(i)=OpenPosPrice(i)*(1-0.5/10000)-ClosePosPrice(i)*(1+0.5/10000);
    cost(i)=(OpenPosPrice(i)+ClosePosPrice(i))*0.5/10000;
    NetMargin(i)=NetMargin(i)-cost(i);
end

CumNetMargin=Plus(NetMargin(1:RecLength));





