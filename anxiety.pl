use strict;
use warnings;

use Irssi;
use Irssi::TextUI;

our $VERSION = '1.00';
our %IRSSI = (
	authors     => 'Max E. Aubrey',
	contact     => 'maxeaubrey@gmail.com',
	name        => 'Anxiety Counter',
	description => 'Gives a total of the number of lines written by you/others in a window.',
	license     => 'GPLv3'
);

my %anxiety;

my $cmd = 'anxiety';
Irssi::command_bind({
	$cmd => 'runsub',
	$cmd . ' reset' => 'countReset',
	$cmd . ' get'   => 'countGet'
});

sub runsub {
	my ($data, $server, $item) = @_;
	Irssi::command_runsub($cmd, $data, $server, $item);
};

Irssi::signal_add({
	'message own_public'  => 'countUp',
	'message own_private' => 'countUp',
	'message public'      => 'countDown',
	'message private'     => 'countDown',
	'window changed'      => sub { Irssi::statusbar_items_redraw 'anxietyCounter'; }
});

Irssi::statusbar_item_register( 'anxietyCounter', '0', 'counter_sb_draw_handler');

sub countUp {
	my $window = $_[2];
	$anxiety{$window} = 1 unless defined($anxiety{$window}++);
	Irssi::statusbar_items_redraw 'anxietyCounter';
};

sub countDown {
	my $window =  $_[2];
	$anxiety{$window} = -1 unless defined($anxiety{$window}--);
	Irssi::statusbar_items_redraw 'anxietyCounter';
};

sub countReset {
	my $window = length $_[0] ? $_[0] : Irssi::active_win->get_active_name;
	delete $anxiety{$window};
	Irssi::statusbar_items_redraw 'anxietyCounter';
};

sub countGet {
	my $window = $anxiety{$_[0]} // 0;
	print "Counter: $window";
};

sub counter_sb_draw_handler {
	my ($sb_item, $get_size_only) = @_;
	my $active = Irssi::active_win->get_active_name;
	my $ct = $anxiety{$active} // 0;
	my $colour = $ct > 0 ? '%R' : $ct < 0 ? '%G' : '%K';
	my $sb = "Ct: ${colour}$ct\%n";

	$sb_item->default_handler($get_size_only, "{sb $sb}", '', 0);
};
