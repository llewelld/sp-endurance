# This file is part of sp-endurance.
#
# vim: ts=4:sw=4:et
#
# Copyright (C) 2012 by Nokia Corporation
#
# Contact: Eero Tamminen <eero.tamminen@nokia.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA

use v5.10;
use strict;

my $inline_ok;

eval "use Inline::MakeMaker";
if ($@) {
    say "Note: install the Perl 'Inline' CPAN module for faster endurance data parsing.";
} else {
    $inline_ok = 1;
}
use ExtUtils::MakeMaker;

my $version;

open CHANGELOG, '../changelog' or die "Unable to open ../changelog: $!";
while (<CHANGELOG>) {
    /^sp-endurance \(([\d\.]+)\), / and $version = $1, last;
}
close CHANGELOG;

die "Unable to determine version number from '../changelog'"
    unless defined $version;

if ($version =~ /^(\d)\.(\d)$/)       { $version = "$1.0$2";  }
if ($version =~ /^(\d)\.(\d)\.(\d)$/) { $version = "$1.$2$3"; }

if ($version !~ /^\d\.\d\d/) {
    print STDERR "ERROR: version number for this perl module must be of the form '#.##', got '$version'.\n";
}

say "Setting module version number to: $version";

say "Generating 'lib/SP/Endurance.pm' ...";
open ENDURANCE_PM, '>', 'lib/SP/Endurance.pm' or die "Unable to open 'lib/SP/Endurance.pm' for writing: $!";
print ENDURANCE_PM <<END;
# AUTOMATICALLY GENERATED BY: $0
package SP::Endurance;
our \$VERSION = '$version';
1;
END
close ENDURANCE_PM;

ExtUtils::MakeMaker::WriteMakefile(
    NAME               => 'SP::Endurance',
    VERSION            => $version,
    ABSTRACT           => 'sp-endurance post processing support module',
    AUTHOR             => 'Tommi Rantala <ext-tommi.1.rantala@nokia.com>',
    ($inline_ok ?
        (CONFIGURE_REQUIRES => { 'Inline::MakeMaker' => 0.45, 'ExtUtils::MakeMaker' => 6.52 }) :
        ()),
    LICENSE            => 'gpl',
    INSTALLDIRS        => 'vendor',
    clean              => { FILES => '_Inline Parser.inl lib/SP/Endurance.pm' },
);

if ($inline_ok) {
    # Amend the Makefile so that our inlined function(s) get compiled.
    # See also the Inline::MakeMaker sources.
    open MAKEFILE, '>> Makefile' or die "Unable to open Makefile for appending: $!";
    print MAKEFILE <<END;
Parser.inl : \$(TO_INST_PM)
	\$(PERL) -Mblib -MInline=NOISY,_INSTALL_ -MSP::Endurance::Parser -e1 $version \$(INST_ARCHLIB)

pure_all :: Parser.inl
END
    close MAKEFILE;
}
