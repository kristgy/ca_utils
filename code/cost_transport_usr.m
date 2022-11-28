function [consumption, transport, engtax]  = cost_transport_usr(users,year,cons,cf)
%clear all
%close all
%run conf.m
%load([cf.tmp_data_dir cf.cons_file],'cons')
%%users = [2 3];
%users = [1];
%year = 2022; 

c_y_idx = find(cons.years==year);
e_y_idx = find(cf.years==year);

% FIXME add abonnemang
consumption = squeeze(sum(cons.day_of_week(users,c_y_idx,:,:,:,:),[1,6],'omitnan'));
transport = consumption.*squeeze(cf.transf_price(e_y_idx,:,:,:));
engtax = sum(consumption,[2,3])'.*squeeze(cf.eng_tax(e_y_idx,:));
