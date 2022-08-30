clear all
close all

%data_file = 'All sessions within period for all users_2020-06-01--2021-07-01.csv';
%data_file = 'All sessions within period for all users_2020-07-01--2021-07-01.csv';
%data_file = 'All sessions within period for all users_2020-10-01--2021-10-01.csv';
%data_file = 'All sessions within period for all users_2020-11-01--2021-02-01.csv';
%data_file = 'All sessions within period for all users_2021-08-01--2021-10-24.csv';
%data_file = 'All sessions within period for all users_2021-10-01--2021-12-31.csv';
data_file = 'All sessions within period for all users_2020-10-01--2022-07-31.csv';
%data_file = 'All sessions within period for all users_2021-04-01--2021-06-30.csv';
%data_file = 'All sessions within period for all users_2020-06-01--2021-04-01.csv';
%data_file = 'All sessions within period for all users_2020-06-01--2021-03-16.csv';

price_data_file_str = 'data*.xlsx';
price_file = 'prices';
cons_file = 'consumption';

price_data_dir = '../price_data/';
cons_data_dir = '../../../ref_data/';
%fig_dir = '../figures/';
fig_dir = [cons_data_dir 'figures/'];
tmp_data_dir = cons_data_dir;
num_years = 3;

eng_tax = NaN*ones(num_years,12);
eng_tax(1,:) = 35.3; % [öre/kWh]
eng_tax(2,:) = 35.6;
eng_tax(3,:) = 36.0;

markup = 2.2; % [öre/kWh]

VAT = 0.25;

transf_price = NaN*ones(num_years,12,7,24);
transf_price(1,:) = 25.6;
transf_price(2,1:3,:) = 24.4;
transf_price(2,4:12,:) = 14.4;
transf_price(2,11:12,2:6,7:22) = 48.0;
transf_price(3,:) = 14.4;
transf_price(3,[1:3 11:12],2:6,7:22) = 48.0;
