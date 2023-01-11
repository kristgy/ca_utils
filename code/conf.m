clear all
close all

cf = struct();

cf.dcom = @(fmt,num) strrep(sprintf(fmt,num),'.',',');

cf.price_data_dir = '../price_data/';
% FIXME Move to G: drive
cf.cons_data_dir = '../../../afs_home/personal/housing/ref_data/';
%cf.fig_dir = '../figures/';
cf.fig_dir = [cf.cons_data_dir 'figures/'];
cf.rep_dir = [cf.cons_data_dir 'reports/'];
cf.tmp_data_dir = cf.cons_data_dir;
cf.rep_sum_file = 'invoice_summary.xlsx';

run([cf.cons_data_dir 'private_conf.m']);

cf.month_l = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
cf.month_l_se = ['jan';'feb';'mar';'apr';'maj';'jun';'jul';'aug';'sep';'okt';'nov';'dec'];

cf.yr = 2022;
cf.m = 10;
cf.years = [2020, 2021, 2022];
%                  Jan    Feb    Mar    Apr    May    Jun    Jul    Aug    Sep    Oct    Nov    Dec
% our price from Telge [�re/kWh]
cf.telge_avg =   [ NaN    NaN    NaN    NaN    NaN    NaN    NaN    NaN    NaN     31.49  35.15  41.74;  % 2020
                    58.73  65.33  45.93  41.68  51.96  48.69  67.82  76.31 102.37  78.37 102.55 202.39;  % 2021
                   118.67  89.68 144.61  98.18 114.25 142.68 101.60 253.66 251.56 101.79 163.56    NaN]; % 2022
% avg spot prices on Nordpool [�re/kWh]
% from https://www.vattenfall.se/elavtal/elpriser/timpris-pa-elborsen/
cf.vattenf_avg = [  25.02  19.46  14.97   9.80  13.54  24.91   9.26  34.71  34.85  23.02  24.13  31.58;  % 2020
                    49.05  53.62  36.78  33.68  43.50  40.30  59.05  67.11  91.84  64.75  83.52 180.74;  % 2021
                   104.33  77.48 130.33  89.22 102.86 126.31  86.61 223.05 228.63  80.65 130.88 269.02]; % 2022

%cf.data_file = 'All sessions within period for all users_2020-06-01--2021-07-01.csv';
%cf.data_file = 'All sessions within period for all users_2020-07-01--2021-07-01.csv';
%cf.data_file = 'All sessions within period for all users_2020-10-01--2021-10-01.csv';
%cf.data_file = 'All sessions within period for all users_2020-11-01--2021-02-01.csv';
%cf.data_file = 'All sessions within period for all users_2020-10-01--2022-10-01.csv';
%cf.data_file = 'All sessions within period for all users_2021-04-01--2021-06-30.csv';
%cf.data_file = 'All sessions within period for all users_2020-06-01--2021-04-01.csv';
%cf.data_file = 'All sessions within period for all users_2020-06-01--2021-03-16.csv';
%cf.data_file = 'All sessions within period for all users_2020-10-01--2022-10-31.csv';
%cf.data_file = 'All sessions within period for all users_2022-10-01--2022-10-31.csv';
cf.data_file = 'All sessions within period for all users_2020-10-01--2022-12-31.csv';

cf.price_data_file_str = 'data*.xlsx';
cf.price_file = 'prices';
cf.cons_file = 'consumption';

cf.num_years = length(cf.years);
cf.dtfmt = 'yyyy-mm-dd';

cf.eng_tax = NaN*ones(cf.num_years,12);
cf.eng_tax(1,:) = 35.3; % [�re/kWh]
cf.eng_tax(2,:) = 35.6;
cf.eng_tax(3,:) = 36.0;

% use hourly price or average monthly price
%cf.hourly_prices = true;
cf.hourly_prices = false;

% payment terms (number of days)
cf.paytrms = 30;

%cf.markup = 2.2; % [�re/kWh] % According to contract, ignoring Elcertificat
cf.markup = 6.6; % [�re/kWh] % Including estimate of elcertificat, based on fit of historical data
%cf.markup = 10; % [�re/kWh] % Including estimate of elcertificat, based on fit of historical data
%cf.markup = 0; % [�re/kWh] % When running monthly average price

cf.VAT = 0.25;

cf.transf_price = NaN*ones(cf.num_years,12,7,24);
cf.transf_price(1,:) = 25.6;
cf.transf_price(2,1:3,:) = 24.4;
cf.transf_price(2,4:12,:) = 14.4;
cf.transf_price(2,11:12,2:6,7:22) = 48.0;
cf.transf_price(3,:) = 14.4;
cf.transf_price(3,[1:3 11:12],2:6,7:22) = 48.0;
