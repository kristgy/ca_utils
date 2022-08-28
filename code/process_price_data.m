clear all
close all

run conf.m

% Load spot price data from Nordpool downloaded in one .xlsx file per week from
% https://www.vattenfall.se/elavtal/elpriser/timpris-pa-elborsen/

date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd HH:mm','TimeZone','Europe/Zurich');

datafiles = dir([price_data_dir price_data_file_str])

Prices = timetable();

for file = 1:length(datafiles)
	T = readtable([price_data_dir datafiles(file).name]);
	T.Properties.VariableNames = ["Time","Price"];
	T.Time = date_fun(T.Time);
	TT = table2timetable(T,'RowTimes','Time');
	Prices = [Prices;TT];
end

Prices = sortrows(Prices,'Time');

price_years = year(min(Prices.Time)):year(max(Prices.Time));
pr = zeros(length(price_years),12,7,24);
pr_full = NaN*ones(length(price_years),12,31,24);

for h = 1:length(Prices.Time)
	pr(year(Prices.Time(h))-price_years(1)+1,month(Prices.Time(h)),weekday(Prices.Time(h)),hour(Prices.Time(h))+1) = Prices.Price(h);
	pr_full(year(Prices.Time(h))-price_years(1)+1,month(Prices.Time(h)),day(Prices.Time(h)),hour(Prices.Time(h))+1) = Prices.Price(h);
end

save([tmp_data_dir price_file],'Prices','pr','pr_full','price_years') 
