x = randn(1,1000000)*100+10;
hist(x,100), hold on
line([mean(x) mean(x)], ylim, 'LineWidth', 2, 'Color', 'r');