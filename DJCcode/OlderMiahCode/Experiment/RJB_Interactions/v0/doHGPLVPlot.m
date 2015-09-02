function [handles, h, p] = doHGPLVPlot(phasors, FW, isEarly, isLate, t, tx)

    handles(1) = figure;
    winsize = 1000;
    
    presavers = [];
    postsavers = [];
    
    prev = [];
    postv = [];
    
    for mfw = FW
        if (mfw > 70 && mfw < 150)
            pre = abs(mean(mean(phasors(:,mfw==FW,isEarly),3),2));
            post = abs(mean(mean(phasors(:,mfw==FW,isLate),3),2));
                        
            % zscore
            zt = double(t < 1);
            pre = zscoreAgainstInterest(pre, zt, 1);
            post = zscoreAgainstInterest(post, zt, 1);

            prev(end+1) = mean(pre(t > 3 & t < 6));
            postv(end+1) = mean(post(t > 3 & t < 6));
            
            buf = zeros(1,ceil(winsize/2))';
            spre = GaussianSmooth(cat(1, buf, pre, buf), winsize);
            spre = spre((ceil(winsize/2)+1):(end-(ceil(winsize/2))));
            spost = GaussianSmooth(cat(1, buf, post, buf), winsize);
            spost = spost((ceil(winsize/2)+1):(end-(ceil(winsize/2))));
            
            ax = plot(t, GaussianSmooth([spre spost],1000));
            set(ax(1), 'color', [1 .8 .8]);
            set(ax(2), 'color', [.8 .8 1]);
            legendOff(ax);
%             plot(t, GaussianSmooth([pre post],1000))
            hold on;
            
            presavers = cat(2, presavers, spre);
            postsavers = cat(2, postsavers, spost);
        end
    end
    
    ax = plot(t, [mean(presavers,2), mean(postsavers,2)], 'linewidth', 3);
    set(ax(1), 'color', [1 0 0]);
    set(ax(2), 'color', [0 0 1]);
    
    legend('early', 'late', 'location', 'northwest');
    
    xlabel('time (s)');
    ylabel('n-PLV');
    
    ylim([-0.3 .8]);
    
    ax = vline([tx.fb tx.post tx.pre]);
    set(ax, 'color', [0 0 0]);
    
    % do the bar plot
    handles(2) = figure;
    [h, p] = ttest2(prev, postv);
    ax = barweb([mean(prev) mean(postv)], [sem(prev,2) sem(postv,2)], 1, [], [], [], [], [1 0 0; 0 0 1]);
    set(ax.errors(1), 'linewidth', 2)
    set(ax.errors(2), 'linewidth', 2)
    set(ax.bars(2), 'linewidth', 2)
    set(ax.bars(1), 'linewidth', 2)
    set(ax.ax, 'linewidth', 2)    
    ax2 = hline(0, 'k-');
    set(ax2, 'linewidth', 2);
    
    sigstar({{0.86, 1.14}}, p);
    set(gca, 'ytick', []);
end