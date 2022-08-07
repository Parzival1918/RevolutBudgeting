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

