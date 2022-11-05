clear all
close all

run conf.m

% Load spot price data from Nordpool downloaded in one .xlsx file per week from
% https://www.vattenfall.se/elavtal/elpriser/timpris-pa-elborsen/

date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd HH:mm','TimeZone','Europe/Zurich');

price = struct();

datafiles = dir([cf.price_data_dir cf.price_data_file_str])

Prices = timetable();

for file = 1:length(datafiles)
	T = readtable([cf.price_data_dir datafiles(file).name]);
	T.Properties.VariableNames = ["Time","Price"];
	T.Time = date_fun(T.Time);
	TT = table2timetable(T,'RowTimes','Time');
	Prices = [Prices;TT];
end

Prices = sortrows(Prices,'Time');

price.years = year(min(Prices.Time)):year(max(Prices.Time));
price.day_of_week = zeros(length(price.years),12,7,24);
price.day_of_month = NaN*ones(length(price.years),12,31,24);

for h = 1:length(Prices.Time)
	price.day_of_week(year(Prices.Time(h))-price.years(1)+1,month(Prices.Time(h)),weekday(Prices.Time(h)),hour(Prices.Time(h))+1) = Prices.Price(h);
	price.day_of_month(year(Prices.Time(h))-price.years(1)+1,month(Prices.Time(h)),day(Prices.Time(h)),hour(Prices.Time(h))+1) = Prices.Price(h);
end

save([cf.tmp_data_dir cf.price_file],'price') 
