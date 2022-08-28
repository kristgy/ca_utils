clear all
close all

run conf.m

% FIXME this code accumulates mulitple years, if consumption data contains more than one year

%sel_u = [2:7, 9:10];
sel_u = [1:5];
%sel_m = [1, 2, 3, 10,11,12];
%sel_m = [8, 9, 10];
sel_m = [10, 11, 12];

load([tmp_data_dir cons_file]);

figure()
bar(squeeze(sum(cons_acc,[1,2,4,5,6]))')
ylabel('Consumption [kWh]')
xlabel('Month')
print('-dpng',[fig_dir 'consumption_month'])

figure()
bar(squeeze(sum(cons_acc,[1,2,3,5,6]))')
ylabel('Consumption [kWh]')
xlabel('Day of week')
print('-dpng',[fig_dir 'consumption_weekday'])

figure()
bar(0:23,squeeze(sum(cons_acc,[1,2,3,4,6]))')
ylabel('Consumption [kWh]')
xlabel('Hour of day')
set(gca,'XTick',[0:23])
print('-dpng',[fig_dir 'consumption_hour'])

figure()
plot(0:23,squeeze(sum(cons_acc(sel_u,:,:,:,:,:),[2,3,4,6])))
ylabel('Consumption [kWh]')
xlabel('Hour of day')
set(gca,'Xlim',[0 23],'XTick',[0:23])
%legend(users(sel_u),'Location','NorthWest')
legend(users(sel_u),'Location','best')
print('-dpng',[fig_dir 'consumption_hour_user'])

month_l = ['jan';'feb';'mar';'apr';'may';'jun';'jul';'aug';'sep';'oct';'nov';'dec'];
for u = 1:length(users)
	figure()
	bar(0:23,squeeze(sum(cons_acc(u,:,:,:,:,:),[2,3,4,6])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	set(gca,'XTick',[0:23])
	%legend(users(u),'Location','NorthWest')
	legend(users(u),'Location','best')
	print('-dpng',[fig_dir 'consumption_hour_' users{u}])

	figure()
	plot(0:23,squeeze(sum(cons_acc(u,:,sel_m,:,:,:),[2,4,6])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	set(gca,'Xlim',[0 23],'XTick',[0:23])
	title(sprintf('Charging of %s per month (total %.1f kWh)', users{u}, sum(cons_acc(u,:,sel_m,:,:,:),[2,3,4,5,6])));
	sums = squeeze(sum(cons_acc(u,:,sel_m,:,:,:),[2,4,5,6]));
	%legend(compose('%s (%.1f kWh)',month_l(sel_m,:),sums),'Location','NorthWest')
	legend(compose('%s (%.1f kWh)',month_l(sel_m,:),sums),'Location','best')
	print('-dpng',[fig_dir 'consumption_hour_month_' users{u}])
end
