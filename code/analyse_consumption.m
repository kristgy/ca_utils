
clear all
close all

run conf.m

load([cf.tmp_data_dir cf.cons_file],'cons')

cons_hour = squeeze(sum(cons.day_of_month,[1 6],'omitnan'));
cons_usr_hour = squeeze(sum(cons.day_of_month,6,'omitnan'));

figure()
histogram(cons_hour)
set(gca,'YScale','log')
xlabel('Charged per hour [kWh]')
ylabel('Number of hours')
print('-dpng',[cf.fig_dir 'consumption_hour_histogram'])

figure()
histogram(cons_usr_hour)
set(gca,'YScale','log')
xlabel('Charged per hour [kWh]')
ylabel('Number of hours')
print('-dpng',[cf.fig_dir 'consumption_hour_histogram'])

for user = 1:length(cons.users.ID)
	figure()
	histogram(cons_usr_hour(user,:))
	title(cons.users.ID(user),'Interpreter','none')
	set(gca,'YScale','log')
	xlabel('Charged per hour [kWh]')
	ylabel('Number of hours')
	print('-dpng',[cf.fig_dir 'consumption_hour_histogram_' num2str(user)])
end
