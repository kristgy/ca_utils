clear all
close all

data_file = 'All sessions within period for all users_2020-06-01--2021-01-01.csv';
%date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSSXXX','TimeZone','Europe/Zurich');
%date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss');
date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX','TimeZone','Europe/Zurich');
stripper = @(date_str) regexprep(date_str,'\.\d{7}\+','+');
strip_fun = @(date_str) cellfun(stripper,date_str,'UniformOutput',false);
dottifier = @(data_str) str2num(strrep(data_str,',','.'));
decimal_fun = @(data_str) cellfun(dottifier,data_str);

opts = detectImportOptions(data_file);
opts.SelectedVariableNames = {'FirstName','ConsumptionKWh','StartTime','EndTime'};
T = readtable(data_file,opts);
T.StartTime = strip_fun(T.StartTime);
T.EndTime = strip_fun(T.EndTime);
T.StartTime = date_fun(T.StartTime);
T.EndTime = date_fun(T.EndTime);
T.ConsumptionKWh = decimal_fun(T.ConsumptionKWh);
TT = table2timetable(T,'RowTimes','StartTime');
dur = T.EndTime-T.StartTime;

users = unique(TT.FirstName);
users(1) = {'NN'};
num_users = length(users);
us_lut = cell2struct(num2cell(1:length(users)),users,2);

cons_acc = zeros(num_users,12,7,24,60);

for s = 1:length(dur)
	Consumption = ones(floor(minutes(dur(s))),1)*TT.ConsumptionKWh(s)/floor(minutes(dur(s)));
	User = TT.FirstName(s);
	if length(User{:}) == 0 
		User = {'NN'};
	end
	s_tab = timetable(Consumption,'TimeStep',minutes(1),'StartTime',TT.StartTime(s));
	for m = 1:length(Consumption)
		cons_acc(us_lut.(User{:}),month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) = ...
		cons_acc(us_lut.(User{:}),month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) + s_tab.Consumption(m);
	end
end

save('processed_usage','TT','users','cons_acc')

