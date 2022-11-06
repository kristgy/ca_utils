clear all
close all

run conf.m

% FIXME this code accumulates mulitple years, if consumption data contains more than one year

%sel_u = [2:7, 9:10];
sel_u = [1:5];
%sel_m = [1, 2, 3, 10,11,12];
%sel_m = [8, 9, 10];
%sel_m = [10, 11, 12];
sel_m = [6, 7, 8];

load([cf.tmp_data_dir cf.cons_file],'cons');

figure()
bar(squeeze(sum(cons.day_of_week,[1,2,4,5,6]))')
ylabel('Consumption [kWh]')
xlabel('Month')
print('-dpng',[cf.fig_dir 'consumption_month'])

figure()
bar(squeeze(sum(cons.day_of_week,[1,2,3,5,6]))')
ylabel('Consumption [kWh]')
xlabel('Day of week')
print('-dpng',[cf.fig_dir 'consumption_weekday'])

figure()
bar(0:23,squeeze(sum(cons.day_of_week,[1,2,3,4,6]))')
ylabel('Consumption [kWh]')
xlabel('Hour of day')
set(gca,'XTick',[0:23])
print('-dpng',[cf.fig_dir 'consumption_hour'])

figure()
plot(0:23,squeeze(sum(cons.day_of_week(sel_u,:,:,:,:,:),[2,3,4,6])))
ylabel('Consumption [kWh]')
xlabel('Hour of day')
set(gca,'Xlim',[0 23],'XTick',[0:23])
%legend(cons.users.FirstName(sel_u),'Location','NorthWest')
legend(cons.users.FirstName(sel_u),'Location','best')
print('-dpng',[cf.fig_dir 'consumption_hour_user'])

for u = 1:length(cons.users.Email)
	figure()
	bar(0:23,squeeze(sum(cons.day_of_week(u,:,:,:,:,:),[2,3,4,6])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	set(gca,'XTick',[0:23])
	%legend(cons.users.FirstName(u),'Location','NorthWest')
	legend(cons.users.FirstName(u),'Location','best')
	print('-dpng',[cf.fig_dir 'consumption_hour_' cons.users.FirstName{u}])

	figure()
	plot(0:23,squeeze(sum(cons.day_of_week(u,:,sel_m,:,:,:),[2,4,6])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	set(gca,'Xlim',[0 23],'XTick',[0:23])
	title(sprintf('Charging of %s per month (total %.1f kWh)', cons.users.FirstName{u}, sum(cons.day_of_week(u,:,sel_m,:,:,:),[2,3,4,5,6])));
	sums = squeeze(sum(cons.day_of_week(u,:,sel_m,:,:,:),[2,4,5,6]));
	%legend(compose('%s (%.1f kWh)',cf.month_l(sel_m,:),sums),'Location','NorthWest')
	legend(compose('%s (%.1f kWh)',cf.month_l(sel_m,:),sums),'Location','best')
	print('-dpng',[cf.fig_dir 'consumption_hour_month_' cons.users.FirstName{u}])
end
