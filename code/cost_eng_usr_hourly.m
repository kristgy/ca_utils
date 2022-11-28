function [consumption, energy, markup]  = cost_eng_usr_hourly(users,year,cons,price,cf)
%clear all
%close all
%run conf.m
%load([cf.tmp_data_dir cf.cons_file],'cons')
%load([cf.tmp_data_dir cf.price_file],'price')
%users = [2 3];
%year = 2020; 

c_y_idx = find(cons.years==year);
p_y_idx = find(price.years==year);

% FIXME add abonnemang
consumption = squeeze(sum(cons.day_of_month(users,c_y_idx,:,:,:,:),[1,6],'omitnan'));
energy = consumption.*squeeze(price.day_of_month(p_y_idx,:,:,:));
markup = consumption.*cf.markup;

