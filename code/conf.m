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
