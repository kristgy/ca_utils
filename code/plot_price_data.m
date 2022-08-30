clear all
close all

run conf.m

load([tmp_data_dir price_file])


plot(Prices.Time,Prices.Price/100)
ylabel('Hourly Nordpool spot price [kr/kWh]')
print('-dpng',[fig_dir 'hourly_Nordpool_spot'])


