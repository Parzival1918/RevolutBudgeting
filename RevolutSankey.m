rawdata = importdata('account-statement_2022-02-01_2022-05-31_en_ddaffd.csv');

alldata = rawdata.textdata;
data = alldata(2:end,[1,2,5,6]);

%Process the data
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