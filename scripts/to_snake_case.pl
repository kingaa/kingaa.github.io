#! /usr/bin/perl -w

use strict;

my $file;
my $slurp;
local $/;

foreach $file (@ARGV) {
    print "editing $file\n";
    open IN, "<$file";
    $slurp = <IN>;
    close IN;
    $slurp =~ s/filter\.mean(\s?)\(/filter_mean$1\(/g;
    $slurp =~ s/pred\.mean(\s?)\(/pred_mean$1\(/g;
    $slurp =~ s/pred\.var(\s?)\(/pred_var$1\(/g;
    $slurp =~ s/filter\.traj(\s?)\(/filter_traj$1\(/g;
    $slurp =~ s/cond\.logLik(\s?)\(/cond_logLik$1\(/g;
    $slurp =~ s/save\.states(\s?)\(/save_states$1\(/g;
    $slurp =~ s/saved\.states(\s?)\(/saved_states$1\(/g;
    $slurp =~ s/eff\.sample\.size(\s?)\(/eff_sample_size$1\(/g;
    $slurp =~ s/as\.pomp(\s?)\(/as_pomp$1\(/g;
    $slurp =~ s/mvn\.rw(\s?)\(/mvn_rw$1\(/g;
    $slurp =~ s/mvn\.diag\.rw(\s?)\(/mvn_diag_rw$1\(/g;
    $slurp =~ s/mvn\.rw\.adaptive(\s?)\(/mvn_rw_adaptive$1\(/g;
    $slurp =~ s/probe\.acf(\s?)\(/probe_acf$1\(/g;
    $slurp =~ s/probe\.ccf(\s?)\(/probe_ccf$1\(/g;
    $slurp =~ s/probe\.marginal(\s?)\(/probe_marginal$1\(/g;
    $slurp =~ s/probe\.mean(\s?)\(/probe_mean$1\(/g;
    $slurp =~ s/probe\.median(\s?)\(/probe_median$1\(/g;
    $slurp =~ s/probe\.nlar(\s?)\(/probe_nlar$1\(/g;
    $slurp =~ s/probe\.period(\s?)\(/probe_period$1\(/g;
    $slurp =~ s/probe\.quantile(\s?)\(/probe_quantile$1\(/g;
    $slurp =~ s/probe\.sd(\s?)\(/probe_sd$1\(/g;
    $slurp =~ s/probe\.var(\s?)\(/probe_var$1\(/g;
    $slurp =~ s/periodic\.bspline\.basis(\s?)\(/periodic_bspline_basis$1\(/g;
    $slurp =~ s/bspline\.basis(\s?)\(/bspline_basis$1\(/g;
    $slurp =~ s/rw\.sd(\s?)\(/rw_sd$1\(/g;
    open OUT, ">$file";
    print OUT $slurp;
    close OUT;
}
