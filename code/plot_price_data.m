clear all
close all

run conf.m

load([cf.tmp_data_dir cf.price_file],'price')


plot(price.t_series.Time,price.t_series.Price/100)
ylabel('Hourly Nordpool spot price [kr/kWh]')
print('-dpng',[cf.fig_dir 'hourly_Nordpool_spot'])


