function my_fig_trim_export(name)
% Cuts the unnecessary space around the given figure, names it with the
% name specified, and saves it in the directory (Results) in 4 different
% formats
% by: Mahmoud Nazzal
% date: 13-11-2018
set(gca,'FontSize',12, 'FontName', 'Times New Roman')  
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
saveas(fig, name)
saveas(fig,[name '.jpg'])
saveas(fig,[name '.pdf'])
% saveas(fig,[Dir '\' name '.eps'], 'epsc')
