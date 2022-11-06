clear all
close all

run conf.m

% For prices see:
% https://www.vattenfalleldistribution.se/el-hem-till-dig/elnatspriser/
% Prices include VAT

sub = struct('name',{{'Enkeltariff E4', 'Tidstariff T4'}},...
'low_price',[.305 .18],'high_price',[.305 .60],...
'high_month',[1 2 3 11 12], 'high_day', [2:6], 'high_hour',[7:22])
% NB! Careful with off by one error in high_hour due to Matlab indexing from 1.
%'high_month',[1 2 3 7 8 9 10 11 12], 'high_day', [2:6], 'high_hour',[6:21])

load([cf.tmp_data_dir cf.cons_file],'cons')

consum_high = sum(cons.day_of_week(:,:,sub.high_month,sub.high_day,sub.high_hour,:),'all')
consum_total = sum(cons.day_of_week,'all')
consum_low = consum_total - consum_high

for s = 1:length(sub.name)
	cost_high = consum_high*sub.high_price(s)
	cost_low = consum_low*sub.low_price(s)
	cost_total = cost_high + cost_low
end

