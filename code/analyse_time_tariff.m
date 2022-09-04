clear all
close all

run conf.m

idx = isnan(telge_avg);
p = polyfit(vattenf_avg(~idx),telge_avg(~idx),1);
figure()
plot(vattenf_avg(:),telge_avg(:),'*',vattenf_avg(~idx),polyval(p,vattenf_avg(~idx)),'-r')
xlabel('Vattenfall avg. montly spot price [öre/kWh]')
ylabel('Telge montly spot price [öre/kWh]')
leg_str = compose('Fit: slope %1.2f, offset %1.2f öre/kWh', p(1), p(2));
legend('Data points',leg_str{1});

load([tmp_data_dir cons_file])
load([tmp_data_dir price_file])

% fixme need to add a check to verfiy that consumption and price data cover the same years
cost_hour = squeeze(sum(cons_full,[1 6],'omitnan')).*pr_full;
%cost_mon = squeeze(sum(cons_full,[1 4 5 6],'omitnan')).*telge_avg;
cost_mon = squeeze(sum(cons_full,[1 4 5 6],'omitnan')).*vattenf_avg;

cost_hour_monthly = sum(cost_hour,[3,4],'omitnan')
total_hour = sum(cost_hour,'all','omitnan')/100
total_mon = sum(cost_mon,'all','omitnan')/100

figure()
plot(1:12,cost_mon'/100)
leg_str_1 = compose('%d faktisk (månadspris)',price_years);
hold on
set(gca,'ColorOrderIndex',1)
plot(cost_hour_monthly'/100,'--')
leg_str_2 = compose('%d simulerad (timpris)',price_years);
legend({leg_str_1{:}, leg_str_2{:}},'Location','best')
title(compose('Månadspris (%.f kr) vs. timpris (%.f kr)',total_mon,total_hour))
xlabel('Månad')
ylabel('Kostnad el laddning (ex moms och elcert.) [kr/mån]')
print('-dpng',[fig_dir 'hourly_monthly_historical_comparision'])
