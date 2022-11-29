function [consumption, energy]  = cost_eng_usr_monthly(users,yr,cons,cf)
%clear all
%close all
%run conf.m
%load([cf.tmp_data_dir cf.cons_file],'cons')
%users = [2 3];
%yr = 2020; 

c_y_idx = find(cons.years==yr);
e_y_idx = find(cf.years==yr);

% FIXME add abonnemang
consumption = squeeze(sum(cons.day_of_month(users,c_y_idx,:,:,:,:),[1,4,5,6],'omitnan'));
energy = consumption'.*squeeze(cf.telge_avg(e_y_idx,:));
