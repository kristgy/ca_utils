clear all
close all

run conf.m

dottifier = @(data_str) str2num(strrep(data_str,',','.'));
decimal_fun = @(data_str) cellfun(dottifier,data_str);

cons = struct();
cons.users = struct();

opts = detectImportOptions([cf.cons_data_dir cf.data_file]);
opts.SelectedVariableNames = {'SerialNumber','ChargerName','FirstName','LastName','Email','ConsumptionKWh','StartTime','EndTime'};
T = readtable([cf.cons_data_dir cf.data_file],opts);
T.ConsumptionKWh = decimal_fun(T.ConsumptionKWh);
dur = T.EndTime-T.StartTime;

email = unique(T.Email);
num_users = length(email);
us_lut = cell2struct(num2cell(1:num_users),matlab.lang.makeValidName(email),2);

cons.years = year(min(T.StartTime)):year(max(T.EndTime));
% FIXME Initialize cons.day_of_week also with NaN?
cons.day_of_week = zeros(num_users,length(cons.years),12,7,24,60);
cons.day_of_month = NaN*ones(num_users,length(cons.years),12,31,24,60);

for s = 1:length(dur)
	Consumption = ones(floor(minutes(dur(s))),1)*T.ConsumptionKWh(s)/floor(minutes(dur(s)));
	User = matlab.lang.makeValidName(T.Email(s));
	if length(User{:}) == 0 
		User = {'NN'};
	end
	cons.users.ChargerName(us_lut.(User{:})) = T.ChargerName(s);
	cons.users.FirstName(us_lut.(User{:})) = T.FirstName(s);
	cons.users.LastName(us_lut.(User{:})) = T.LastName(s);
	cons.users.Email(us_lut.(User{:})) = T.Email(s);
	cons.users.ID(us_lut.(User{:})) = User{:};
	s_tab = timetable(Consumption,'TimeStep',minutes(1),'StartTime',T.StartTime(s));
	for m = 1:length(Consumption)
		cons.day_of_week(us_lut.(User{:}),year(s_tab.Time(m))-cons.years(1)+1,month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) = ...
		cons.day_of_week(us_lut.(User{:}),year(s_tab.Time(m))-cons.years(1)+1,month(s_tab.Time(m)),weekday(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) + s_tab.Consumption(m);

		% FIXME This would overwrite if user is charging on two chargers at the same time
		cons.day_of_month(us_lut.(User{:}),year(s_tab.Time(m))-cons.years(1)+1,month(s_tab.Time(m)),day(s_tab.Time(m)),hour(s_tab.Time(m))+1,minute(s_tab.Time(m))+1) = s_tab.Consumption(m);
	end
end

save([cf.tmp_data_dir cf.cons_file],'cons')
