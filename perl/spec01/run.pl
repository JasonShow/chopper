#!/usr/bin/env perl
use warnings;
use strict;
use Data::Dumper;;


my $szFile = "/c/Users/owen/Documents/workspace/sh_utils/perl/spec01/cindy.txt";
if (not -e $szFile) {
    print "error,the file is not exsit.\n";
}
my $outputfile = "DataTime.csv";
my $FILE_OUT;
my $FILE_IN;
open($FILE_IN, "<$szFile");
open($FILE_OUT, ">$outputfile");

my @lines = ();

unless (open $FILE_IN, $szFile) {
    print "failed to open the File\n";
}

my @avguploadtime = ();
my @avgprocesstime = ();
my $loopName = '';
my $blockIndex = 0;
# 0 can be falsy means defatult is not block
my $isBlook = 0;
my $suiteName = 0;
my $uploadTime = 0;
my $primaryLable = 0;
my %container = ();
my $phData = ();
my @suitNames = ();

my $type = '';

while (my $line = <$FILE_IN>) {
    chomp($line);
    if ($line =~ /Executing\s+Test\s+Flow\s+Loop\s+Iteration\s*:\s*(\d+)/) {
        # 如果发现这一层是loopName，那么取到loopName并且什么都不做，说明在什么时候 就要将这个数据推入哈希
        # 来自于loopName
        $loopName = ''.$1.'';
        # 设置类型
        $type = 'loop';
        print '发现一层loop:  ['.$loopName."]\n";
    }
    elsif ($line =~ /Test Suite Name\s\:\s(.*)/) {
        # 如果发现这一层是suitname
        # 设置类型
        $type = 'suit';
        $suiteName = ''.$1.'';
        # 先把这一层的name放进数组把名字缓存起来
        push @suitNames, $suiteName;
        # 设置blockIndex 为 0 ？
        # 设置isBlook为0 是什么意思？
        # blockIndex是block的blockIndex，所以在遇到suit的时候重置一下
        $blockIndex = 0;
        $isBlook = 0;
        print '发现一层suit:  '.$suiteName."\n";
    }
    elsif ($line =~ /Primary Label\s*:\s*(.*)/) {
        # 如果遇到了block
        # 设置类型
        print '发现一层block'."\n";
        $type = 'block';
        # isBlook是1，意思是说遇到了block
        # isBlook是这一行的类型
        $isBlook = 1;
        $blockIndex++;
        $primaryLable = $1;
    }
    elsif ($line =~ /^--/) {
        $isBlook = 0;
        # 设置类型
        print '发现一层time'."\n";
        $type = 'time';
    }
    # 如果标记为1 ，即当前行是block
    # 如果上述类型检查完毕，发现isBlook是1 说明目前我们还在寻找time
    # 然后检查是不是时间
    if ($isBlook) {
        print "push time \n";
        # 如果这行是 upload time
        if ($line =~ /upload time\s+(.*)\s+msec/) {
            # 将时间推入哈希
            print "推upload进哈希 \n";
            print 'xxxxxxxxxxxxxxxxxxxxx'.$suiteName.'\n';
            $container{$loopName.''}->{''.$suiteName.''}->{$blockIndex}->{"UPLOADTIME"} = $1;
        }
        # 如果这行是 start time
        if ($line =~ /process time\s+(.*)\s+msec/) {
            # 将时间推入哈希
            print "推process进哈希 \n";
            print 'yyyyyyyyyyyyyyyyyy'.$suiteName.'\n';
            $container{$loopName.''}->{''.$suiteName.''}->{$blockIndex}->{"PROCESSTIME"} = $1;
        }
    }
}

print Dumper \%container;
print Dumper \@suitNames;


# build suitNames
my $suiteNameLen = @suitNames;
for (my $i = 0; $i < $suiteNameLen; $i++)
{
    if ($suitNames[$i] eq $suitNames[0])
    {
        @suitNames = @suitNames[0 .. $i + 1]
    }
}

print Dumper @suitNames;

print "|====================compute=======================|\n";
print "|====================compute=======================|\n";
print "|====================compute=======================|\n";
print "|====================compute=======================|\n";
print "|====================compute=======================|\n";

my @_loopnames = sort {$a <=> $b} (keys %container);
shift @_loopnames;
# 分子=5
my $down = @_loopnames;

# 表格
my %table = ();

# 只循环两次
foreach my $_suitName (@suitNames) {
    print "suitname:\n";
    print $_suitName;
    print "\n";

    # 循环好几次
    # 制造一个容器，使得在子循环可以填充该容器，并在子循环结束，可以被收集
    my @blockList = qw();
    foreach my $_loopname (@_loopnames) {
        #        print  $_loopname;
        #        print Dumper \$container{$_loopname}{$_suitName};
        # 循环block次数
        # 制作一个哈希容器，在子循环中收集两个时间，并且在，结束时候，可以被收集
        my %unit = qw();
        my $uploadT = 0;
        my $processT = 0;
        foreach my $_blk (sort {$a <=> $b} keys $container{$_loopname}{$_suitName}) {
            #            print $_blk."\n";
            #            print Dumper \$container{$_loopname}{$_suitName}{$_blk}{'PROCESSTIME'};
            #            print Dumper \$container{$_loopname}{$_suitName}{$_blk}{'UPLOADTIME'};
            $uploadT += $container{$_loopname}{$_suitName}{$_blk}{'UPLOADTIME'};
            $processT += $container{$_loopname}{$_suitName}{$_blk}{'PROCESSTIME'};

        }
        # 收集两个时间
        $unit{'UPLOADTIME'} = \$uploadT / $down;
        $unit{'PROCESSTIME'} = \$processT / $down;
        push @blockList, \%unit;
        #        print "*****************\n";
    }
    # 收集suit计算结果
    $table{''.$_suitName.''} = [ @blockList ];
}

print "%%%%%%%%%%%%%%%%%%%%% end %%%%%%%%%%%%%%%%%%%%%%%%%%\n";
print Dumper \%table;



#print $table{'share_badc_dgt_rdi_semi'};
#print $table{'LEGO_PPMU_dc_semi'};
#




