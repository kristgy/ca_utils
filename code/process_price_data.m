clear all
close all

run conf.m

% Load spot price data from Nordpool downloaded in one .xlsx file per week from
% https://www.vattenfall.se/elavtal/elpriser/timpris-pa-elborsen/

date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd HH:mm','TimeZone','Europe/Zurich');

price = struct();

datafiles = dir([cf.price_data_dir cf.price_data_file_str])

price.t_series = timetable();

for file = 1:length(datafiles)
	T = readtable([cf.price_data_dir datafiles(file).name]);
	T.Properties.VariableNames = ["Time","Price"];
	T.Time = date_fun(T.Time);
	TT = table2timetable(T,'RowTimes','Time');
	price.t_series = [price.t_series;TT];
end

price.t_series = sortrows(price.t_series,'Time');

price.years = year(min(price.t_series.Time)):year(max(price.t_series.Time));
price.day_of_week = zeros(length(price.years),12,7,24);
price.day_of_month = NaN*ones(length(price.years),12,31,24);

for h = 1:length(price.t_series.Time)
	price.day_of_week(year(price.t_series.Time(h))-price.years(1)+1,month(price.t_series.Time(h)),weekday(price.t_series.Time(h)),hour(price.t_series.Time(h))+1) = price.t_series.Price(h);
	price.day_of_month(year(price.t_series.Time(h))-price.years(1)+1,month(price.t_series.Time(h)),day(price.t_series.Time(h)),hour(price.t_series.Time(h))+1) = price.t_series.Price(h);
end

save([cf.tmp_data_dir cf.price_file],'price') 
