clear all
close all

run conf.m

%                Jan   Feb    Mar    Apr    May    Jun    Jul    Aug    Sep    Oct    Nov    Dec
% our price from Telge [öre/kWh]
telge_avg =   [NaN    NaN    NaN    NaN    NaN    NaN    NaN    NaN    NaN    31.49  35.15  41.74; % 2020
               58.73  65.33  45.93  41.68  51.96  48.69  67.82  76.31 102.37  78.37 102.55 202.39; % 2021
              118.67  89.68 144.61  98.18 114.25 142.68 101.60  NaN    NaN    NaN    NaN    NaN];  % 2022
% avg spot prices on Nordpool [öre/kWh]
% from https://www.vattenfall.se/elavtal/elpriser/timpris-pa-elborsen/
vattenf_avg = [25.02  19.46  14.97   9.80  13.54  24.91   9.26  34.71  34.85  23.02  24.13  31.58;
               49.05  53.62  36.78  33.68  43.50  40.30  59.05  67.11  91.84  64.75  83.52 180.74;
              104.33  77.46 130.33  89.22 102.9  126.31  86.61 203.43  NaN    NaN    NaN    NaN];
% from https://elen.nu/elprishistorik/elpriser-2022/
elen_avg =    [25.02  19.46  14.96   9.80  13.54  24.89   9.26  34.71  34.85  23.02  24.13  31.58;
               49.05  53.63  36.78  33.68  43.50  40.30  59.05  67.11  91.84  64.75  83.52 180.74;
              104.33  77.48 130.33  89.22 102.86 126.31  86.61 206.94  NaN    NaN    NaN    NaN];

idx = isnan(telge_avg);
p = polyfit(vattenf_avg(~idx),telge_avg(~idx),1);
plot(vattenf_avg(:),telge_avg(:),'*',vattenf_avg(~idx),polyval(p,vattenf_avg(~idx)),'-r')

load([tmp_data_dir cons_file])
load([tmp_data_dir price_file])

%t_year_pr = squeeze(pr_full(find(price_years==target_year),:,:,:));

% fixme need to add a check to verfiy that consumption and price data cover the same years
all_us = squeeze(sum(cons_full,1,'omitnan'));
all_hour = squeeze(sum(all_us,5,'omitnan'));
all_day = squeeze(sum(all_hour,4,'omitnan'));
all_mon = squeeze(sum(all_day,3,'omitnan'));

cost_hour = all_hour.*pr_full;
%cost_mon = all_mon.*telge_avg(2,:)';
cost_mon = all_mon.*vattenf_avg;

cost_hour_monthly = sum(cost_hour,[3,4],'omitnan')
total_hour = sum(cost_hour,'all','omitnan')/100
total_mon = sum(cost_mon,'all','omitnan')/100

day_pr = squeeze(mean(pr_full,4,'omitnan'));
month_pr = squeeze(mean(day_pr,3,'omitnan'));

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
