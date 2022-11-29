function [consumption, transport, engtax]  = cost_transport_usr(users,yr,cons,cf)
%clear all
%close all
%run conf.m
%load([cf.tmp_data_dir cf.cons_file],'cons')
%%users = [2 3];
%users = [1];
%yr = 2022; 

c_y_idx = find(cons.years==yr);
e_y_idx = find(cf.years==yr);

% FIXME add abonnemang
consumption = squeeze(sum(cons.day_of_week(users,c_y_idx,:,:,:,:),[1,6],'omitnan'));
transport = consumption.*squeeze(cf.transf_price(e_y_idx,:,:,:));
transport = squeeze(sum(transport,[2 3],'omitnan'));
engtax = sum(consumption,[2,3])'.*squeeze(cf.eng_tax(e_y_idx,:));
