rawdata = importdata('account-statement_2022-02-01_2022-05-31_en_ddaffd.csv');

alldata = rawdata.textdata;
data = alldata(2:end,[1,2,5,6]);

%Process the data

%Accounts
currentAccount = alldata(alldata(:,2)=="Current",[1,3:end]);
pocketAccount = alldata(alldata(:,2)=="Pocket",[1,3:end]);

%Money spent
cardPaymentsCell = data(data(:,1)=="CARD_PAYMENT",end);
cardPayments = zeros([length(cardPaymentsCell),1]);
for i = 1:length(cardPaymentsCell)
    cardPayments(i) = str2double(cardPaymentsCell{i}); 
end

totalSpent = sum(cardPayments)

transfersCell = data(data(:,1)=="TRANSFER",end);
transfers = zeros([length(transfersCell),1]);
for i = 1:length(transfersCell)
    transfers(i) = str2double(transfersCell{i}); 
end

totalSpent = sum(transfers(transfers < 0))
totalReceived = sum(transfers(transfers > 0))

%dates (from started date)
datesCell = alldata(2:end,3);
dates = datetime(datesCell,'InputFormat','yyyy-MM-dd HH:mm:ss', 'Format', 'yyyy-MM-dd');

d = rawdata.data;
plot(dates(1:end-10),d(1:end-10));

%dates (from end date)
datesCell = alldata(2:end,4);
dates = datetime(datesCell,'InputFormat','yyyy-MM-dd HH:mm:ss', 'Format', 'yyyy-MM-dd');

d = rawdata.data;
plot(dates(1:end-10),d(1:end-10));

%descriptions
descriptionsCell = data(:,3);
descriptions = string(descriptionsCell);

uniqueDesc = unique(descriptions);

%how much spent per unique description

paymentsCell = data(:,end);
payments = zeros([length(paymentsCell),1]);
for i = 1:length(paymentsCell)
    payments(i) = str2double(paymentsCell{i}); 
end

%%Add higher level sections that nest the Unique descriptions, like
%%groceries, travel, restaurants.
groupNames = ["Groceries","Travel","Restaurants","University","Housing","Shopping","Rest"];
groups = cell([length(groupNames),2]);

groups{1,1} = groupNames(1);
groups{2,1} = groupNames(2);
groups{3,1} = groupNames(3);
groups{4,1} = groupNames(4);
groups{5,1} = groupNames(5);
groups{6,1} = groupNames(6);
groups{7,1} = groupNames(7);

groups{1,2} = ["Sainsburys","Tesco Stores 5106","Tesco Stores 6479","Tesco Stores 6863",...
    "Co-Op Group Food","Deans Family Butchers","Sq *connors Fruit Corner"];
groups{2,2} = ["Ryanair","Trainline","Tfl Travel Charge","thetrainline.com"];
groups{3,2} = ["200 Degrees","Bao Stoney","Bloo 88","Caffe Tucci","Castle Fruit And Salad Bo",...
    "Cawa Division Ltd","Deliveroo","Edosushi","Howst","Iz *johns Van","Lunch Stop","Pret A Manger",...
    "Sq *luckyfox","Sq *terrace Goods","Sumup  *5tara Sheffield","Ztl*chatime Sheff Limi",...
    "Ztl*johns Van","Ztl*peddler Market","Ztl*ramenfications Lim"];
groups{4,2} = ["To Univ Of Sheffield","Www.sheffieldstudentsu"];
groups{5,2} = ["To Dove Properties And Estates Limited","To Unihomes"];
groups{6,2} = ["Amazon Eu","Amazon Go","Amazon Prime","Amznmktplace","Nisbets Plc",...
    "Nya*lane7 Ltd","Smith & Tissington","The Light Cinemas","Waterstones","amazon.co.uk","www.voxi.co.uk"];
groups{7,2} = [];

infoGroups = zeros([length(groupNames),2]);
infoDescriptions = zeros([length(uniqueDesc),2]);
for i = 1:length(uniqueDesc)
    description = uniqueDesc(i);
    received = 0;
    sent = 0;
    
    all = payments(descriptions == description);
    received = sum(all(all>0));
    sent = sum(all(all<0));
    infoDescriptions(i,1) = received;
    infoDescriptions(i,2) = abs(sent);
    
    inSection = false;
    for j = 1:length(groupNames)-1
        if ismember(description,groups{j,2})
            inSection = true;
            
            infoGroups(j,1) = infoGroups(j,1) + received;
            infoGroups(j,2) = infoGroups(j,2) + abs(sent);
        end
    end
    if ~inSection
        infoGroups(end,1) = infoGroups(end,1) + received;
        infoGroups(end,2) = infoGroups(end,2) + abs(sent);
    end
end

t = table([uniqueDesc;"Total"],[infoDescriptions(:,1);sum(infoDescriptions(:,1))],...
    [infoDescriptions(:,2);sum(infoDescriptions(:,2))],'VariableNames',["Description","Received","Sent"]);

%Sankey diagram text (for https://sankeymatic.com/build/)
allMoneySectionTxt = "Total";
textLines = cell([length(uniqueDesc),1]);

for i = 1:length(textLines)
    if infoDescriptions(i,2) ~= 0
        txt = strcat(allMoneySectionTxt," [",string(infoDescriptions(i,2)),"] ",uniqueDesc(i));
        textLines{i} = txt; 
    elseif infoDescriptions(i,2) == 0 && infoDescriptions(i,1) ~= 0
        txt = strcat(uniqueDesc{i}," [",string(infoDescriptions(i,1)),"] ",allMoneySectionTxt);
        textLines{i} = txt; 
    end
end

tableTxt = table(textLines);
writetable(tableTxt,"SankeyTextDescriptions",'WriteVariableNames',false);

%Sankey diagram text of Groups (for https://sankeymatic.com/build/)
allMoneySectionTxt = "Total";
textLines = cell([length(groupNames),1]);

for i = 1:length(groupNames)
    if infoGroups(i,2) ~= 0
        txt = strcat(allMoneySectionTxt," [",string(infoGroups(i,2)),"] ",groupNames(i));
        textLines{i} = txt; 
    elseif infoGroups(i,2) == 0 && infoGroups(i,1) ~= 0
        txt = strcat(groupNames(i)," [",string(infoGroups(i,1)),"] ",allMoneySectionTxt);
        textLines{i} = txt; 
    end
end

tableTxt = table(textLines);
writetable(tableTxt,"SankeyTextGroups",'WriteVariableNames',false);