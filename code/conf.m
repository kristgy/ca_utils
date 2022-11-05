clear all
close all

price_data_dir = '../price_data/';
cons_data_dir = '../../../ref_data/';
%fig_dir = '../figures/';
fig_dir = [cons_data_dir 'figures/'];
rep_dir = [cons_data_dir 'reports/'];
tmp_data_dir = cons_data_dir;

run([cons_data_dir 'private_conf.m'])

month_l = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
month_l_se = ['jan';'feb';'mar';'apr';'maj';'jun';'jul';'aug';'sep';'okt';'nov';'dec'];

%                Jan   Feb    Mar    Apr    May    Jun    Jul    Aug    Sep    Oct    Nov    Dec
% our price from Telge [öre/kWh]
telge_avg =   [NaN    NaN    NaN    NaN    NaN    NaN    NaN    NaN    NaN    31.49  35.15  41.74; % 2020
               58.73  65.33  45.93  41.68  51.96  48.69  67.82  76.31 102.37  78.37 102.55 202.39; % 2021
              118.67  89.68 144.61  98.18 114.25 142.68 101.60 253.66 251.56    NaN    NaN    NaN];  % 2022
% avg spot prices on Nordpool [öre/kWh]
% from https://www.vattenfall.se/elavtal/elpriser/timpris-pa-elborsen/
vattenf_avg = [25.02  19.46  14.97   9.80  13.54  24.91   9.26  34.71  34.85  23.02  24.13  31.58;
               49.05  53.62  36.78  33.68  43.50  40.30  59.05  67.11  91.84  64.75  83.52 180.74;
              104.33  77.46 130.33  89.22 102.9  126.31  86.61 223.05 228.63  80.65    NaN    NaN];
% from https://elen.nu/elprishistorik/elpriser-2022/
elen_avg =    [25.02  19.46  14.96   9.80  13.54  24.89   9.26  34.71  34.85  23.02  24.13  31.58;
               49.05  53.63  36.78  33.68  43.50  40.30  59.05  67.11  91.84  64.75  83.52 180.74;
              104.33  77.48 130.33  89.22 102.86 126.31  86.61 223.05 228.63  80.65    NaN    NaN];

%data_file = 'All sessions within period for all users_2020-06-01--2021-07-01.csv';
%data_file = 'All sessions within period for all users_2020-07-01--2021-07-01.csv';
%data_file = 'All sessions within period for all users_2020-10-01--2021-10-01.csv';
%data_file = 'All sessions within period for all users_2020-11-01--2021-02-01.csv';
%data_file = 'All sessions within period for all users_2020-10-01--2022-10-01.csv';
%data_file = 'All sessions within period for all users_2021-04-01--2021-06-30.csv';
%data_file = 'All sessions within period for all users_2020-06-01--2021-04-01.csv';
%data_file = 'All sessions within period for all users_2020-06-01--2021-03-16.csv';
data_file = 'All sessions within period for all users_2020-10-01--2022-10-31.csv';

price_data_file_str = 'data*.xlsx';
price_file = 'prices';
cons_file = 'consumption';

num_years = 3;
dtfmt = 'yyyy-mm-dd';

eng_tax = NaN*ones(num_years,12);
eng_tax(1,:) = 35.3; % [öre/kWh]
eng_tax(2,:) = 35.6;
eng_tax(3,:) = 36.0;

%markup = 2.2; % [öre/kWh] % According to contract, ignoring Elcertificat
markup = 6.6; % [öre/kWh] % Including estimate of elcertificat, based on fit of historical data

VAT = 0.25;

transf_price = NaN*ones(num_years,12,7,24);
transf_price(1,:) = 25.6;
transf_price(2,1:3,:) = 24.4;
transf_price(2,4:12,:) = 14.4;
transf_price(2,11:12,2:6,7:22) = 48.0;
transf_price(3,:) = 14.4;
transf_price(3,[1:3 11:12],2:6,7:22) = 48.0;
