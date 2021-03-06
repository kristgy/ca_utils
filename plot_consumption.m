clear all
close all

load('processed_usage')

figure()
bar(squeeze(sum(cons_acc,[1,3,4,5]))')
ylabel('Consumption [kWh]')
xlabel('Month')
print('-dpng','consumption_month')

figure()
bar(squeeze(sum(cons_acc,[1,2,4,5]))')
ylabel('Consumption [kWh]')
xlabel('Day of week')
print('-dpng','consumption_weekday')

figure()
bar(0:23,squeeze(sum(cons_acc,[1,2,3,5]))')
ylabel('Consumption [kWh]')
xlabel('Hour of day')
set(gca,'XTick',[0:23])
print('-dpng','consumption_hour')

sel_u = [2,3,4,5,7];
figure()
%bar(0:23,squeeze(sum(cons_acc(sel_u,:,:,:,:),[2,3,5])))
plot(0:23,squeeze(sum(cons_acc(sel_u,:,:,:,:),[2,3,5])))
ylabel('Consumption [kWh]')
xlabel('Hour of day')
set(gca,'Xlim',[0 23],'XTick',[0:23])
%legend(users(sel_u),'Location','NorthWest')
legend(users(sel_u),'Location','best')
print('-dpng','consumption_hour_user')

month_l = ['jan';'feb';'mar';'apr';'may';'jun';'jul';'aug';'sep';'oct';'nov';'dec'];
%sel_m = [1, 2, 3, 10,11,12];
sel_m = [1, 2, 3];
for u = 1:length(users)
	figure()
	bar(0:23,squeeze(sum(cons_acc(u,:,:,:,:),[2,3,5])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	set(gca,'XTick',[0:23])
	%legend(users(u),'Location','NorthWest')
	legend(users(u),'Location','best')
	print('-dpng',['consumption_hour_' users{u}])

	figure()
	%bar(0:23,squeeze(sum(cons_acc(u,sel_m,:,:,:),[3,5])))
	plot(0:23,squeeze(sum(cons_acc(u,sel_m,:,:,:),[3,5])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	set(gca,'Xlim',[0 23],'XTick',[0:23])
	title(sprintf('Charging of %s per month (total %.1f kWh)', users{u}, sum(cons_acc(u,sel_m,:,:,:),[2,3,4,5])));
	sums = squeeze(sum(cons_acc(u,sel_m,:,:,:),[3,4,5]))
	%legend(compose('%s (%.1f kWh)',month_l(sel_m,:),sums'),'Location','NorthWest')
	legend(compose('%s (%.1f kWh)',month_l(sel_m,:),sums'),'Location','best')
	print('-dpng',['consumption_hour_month_' users{u}])
end

