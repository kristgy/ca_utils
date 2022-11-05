clear all
close all

run conf.m

%%date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSSXXX','TimeZone','Europe/Zurich');
%%date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ss');
%date_fun = @(date_str) datetime(date_str,'InputFormat','yyyy-MM-dd''T''HH:mm:ssXXX','TimeZone','Europe/Zurich');
%stripper = @(date_str) regexprep(date_str,'\.\d{7}\+','+');
%strip_fun = @(date_str) cellfun(stripper,date_str,'UniformOutput',false);
dottifier = @(data_str) str2num(strrep(data_str,',','.'));
decimal_fun = @(data_str) cellfun(dottifier,data_str);

opts = detectImportOptions([cons_data_dir data_file]);
opts.SelectedVariableNames = {'SerialNumber','ChargerName','FirstName','LastName','Email','ConsumptionKWh','StartTime','EndTime'};
T = readtable([cons_data_dir data_file],opts);
%T.StartTime = strip_fun(T.StartTime);
%T.EndTime = strip_fun(T.EndTime);
%T.StartTime = date_fun(T.StartTime);
%T.EndTime = date_fun(T.EndTime);
T.ConsumptionKWh = decimal_fun(T.ConsumptionKWh);
%TT = table2timetable(T,'RowTimes','StartTime');
dur = T.EndTime-T.StartTime;

charger_name = unique(T.ChargerName);
first_name = unique(T.FirstName);
email = unique(T.Email);
last_name = unique(T.LastName);
num_users = length(email);
us_lut = cell2struct(num2cell(1:num_users),matlab.lang.makeValidName(email),2);
users = struct();

cons_years = year(min(T.StartTime)):year(max(T.EndTime));
% FIXME Initialize cons_acc also with NaN?
cons_acc = zeros(num_users,length(cons_years),12,7,24,60);
cons_full = NaN*ones(num_users,length(cons_years),12,31,24,60);

%return

for s = 1:length(dur)
	Consumption = ones(floor(minutes(dur(s))),1)*T.ConsumptionKWh(s)/floor(minutes(dur(s)));
	%User = matlab.lang.makeValidName(TT.FirstName(s));
	User = matlab.lang.makeValidName(T.Email(s));
	users.ChargerName(us_lut.(User{:})) = T.ChargerName(s);
	users.FirstName(us_lut.(User{:})) = T.FirstName(s);
	users.LastName(us_lut.(User{:})) = T.LastName(s);
	users.Email(us_lut.(User{:})) = T.Email(s);
	if length(User{:}) == 0 
		User = {'NN'};
	end
	s_tab = timetable(Consumption,'TimeStep',minutes(1),'StartTime',T.StartTime(s));
	for m = 1:length(Consumption)
		%cons_acc(us_lut.(User{:}),month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) = ...
		%cons_acc(us_lut.(User{:}),month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) + s_tab.Consumption(m);
		cons_acc(us_lut.(User{:}),year(s_tab.Time(m))-cons_years(1)+1,month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) = ...
		cons_acc(us_lut.(User{:}),year(s_tab.Time(m))-cons_years(1)+1,month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) + s_tab.Consumption(m);

		% FIXME This would overwrite if user is charging on two chargers at the same time
		cons_full(us_lut.(User{:}),year(s_tab.Time(m))-cons_years(1)+1,month(s_tab.Time(m)),day(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) = s_tab.Consumption(m);
	end
end

save([tmp_data_dir cons_file],'T','first_name','cons_acc','cons_full','cons_years')
