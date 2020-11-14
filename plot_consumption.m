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
print('-dpng','consumption_hour')

sel = [2,3,4,5,7];
figure()
bar(0:23,squeeze(sum(cons_acc(sel,:,:,:,:),[2,3,5])))
ylabel('Consumption [kWh]')
xlabel('Hour of day')
legend(users(sel),'Location','NorthWest')
print('-dpng','consumption_hour_user')

for u = 1:length(users)
	figure()
	bar(0:23,squeeze(sum(cons_acc(u,:,:,:,:),[2,3,5])))
	ylabel('Consumption [kWh]')
	xlabel('Hour of day')
	legend(users(u),'Location','NorthWest')
	print('-dpng',['consumption_hour_' users{u}])
end

