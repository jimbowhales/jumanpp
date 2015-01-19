#!/usr/bin/env perl

use JumanSexp;
use Inflection;
use utf8;
use Encode;
binmode STDIN, ':encoding(utf-8)';
binmode STDOUT, ':encoding(utf-8)';
binmode STDERR, ':encoding(utf-8)';

use strict;
#(接尾辞 (名詞性名詞接尾辞 ((見出し語 ら)(読み ら)(意味情報 "代表表記:ら/ら"))))

while (<STDIN>) {
    if($_ =~ /^\s*;/){ next;}
    my $s = new JumanSexp($_);
    my $pos = $s->{data}[0]{element};
    my $spos = $s->{data}[1]{element};
    my $yomi = ($s->get_elem('読み'))[0];
    my $type = ($s->get_elem('活用型'))[0];
    my $imis = join(" ", ($s->get_elem('意味情報')));
    my $rep = "*";
    $imis =~ s/^"//; #最初と最後のクォーテーションを除く
    $imis =~ s/"$//;
    if($imis =~ s/代表表記:([^ "]*) ?//){
        $rep = $1;
    }
    if($imis =~ /,/){# フォーマットが崩れる
        $STDERR.print("err: 意味情報が','を含む.");
        exit(1);
    }
    if($imis eq ""){
        $imis = "NIL";
    }
    # $spos = ":$spos" if $spos;
    for my $midasi ($s->get_elem('見出し語')) {
        if ($type) {
            if(!$spos){$spos= "*";}
            my @ms =(&get_inflected_forms(Encode::encode('utf-8',$midasi), Encode::encode('utf-8',$type))) ;
            my @ys =(&get_inflected_forms(Encode::encode('utf-8',$yomi), Encode::encode('utf-8',$type))) ;
            #my %hash = map {$ms[$_], $ys[$_]}(0..$#ms); 
            my %hash; @hash{@ms}=@ys;
            for my $m_key (@ms){
                my $mstr = Encode::decode('utf-8', $m_key->{str});
                my $ystr = Encode::decode('utf-8', $hash{$m_key}->{str});
                next unless $mstr;
                my $shortform = Encode::decode('utf-8', $m_key->{form});
                my $form_type = Encode::decode('utf-8', $hash{$m_key}->{form});
                $shortform =~ s/\p{katakana}+列//;
                $shortform =~ s/\p{katakana}+系//;
                if($form_type =~ /((\p{katakana}+列)|(\p{katakana}+系))+/){
                    $form_type = $&;
                }else{
                    $form_type = "*";
                }
                #&print_entry($m->{str}, $pos, ':' , $m->{form});
                &print_entry($mstr, $pos, $spos , $shortform, $type, $midasi, $ystr, $rep, $imis);
            }
        }
        else {
            &print_entry($midasi, $pos, $spos,'*', '*',$midasi, $yomi, $rep, $imis);
        }
    }
}

#(名詞 (普通名詞 ((読み き゜)(見出し語 (き゜ 1.6))(意味情報 "自動獲得:Wikipedia Wikipedia多義"))))
#あいまって,0,0,0,動詞:タ系連用テ形
#相俟った,0,0,0,動詞:タ形
#あいまいやったろ,0,0,0,形容詞:ヤ列タ系省略推量形
#
#(判定詞 ((見出し語 だ)(読み だ)(活用型 判定詞)))
#な,0,0,0,判定詞:ダ列基本連体形
#あいくるしくて,0,0,0,形容詞:タ系連用テ形
#あいこ,0,0,0,名詞:サ変名詞

sub print_entry {
    my ($h, $pos, $spos, $form, $form_type, $midasi, $yomi, $rep, $imis) = @_;
    print $h, ',0,0,0,', $pos,',', $spos, ',' , $form, ',', $form_type, ',' , $midasi , ',', $yomi, ',' , $rep, ',' , $imis,"\n"; }

sub get_inflected_forms {
    my ($midasi, $type) = @_;

    my $inf = new Inflection($midasi, $type, '基本形');
    return $inf->GetAllForms();
}