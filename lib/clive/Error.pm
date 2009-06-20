# -*- coding: ascii -*-
###########################################################################
# clive, command line video extraction utility.
# Copyright 2007, 2008, 2009 Toni Gundogdu.
#
# This file is part of clive.
#
# clive is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# clive is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
###########################################################################
package clive::Error;

require Exporter;

our @ISA = qw(Exporter);

use constant {
    CLIVE_OK          => 0,
    CLIVE_NOTHINGTODO => 1,    # file already retrieved
    CLIVE_NOSUPPORT   => 2,    # host not supported
    CLIVE_READ        => 3,    # file open/read error
    CLIVE_GREP        => 4,    # grep: nothing matched in cache
    CLIVE_OPTARG      => 5,    # invalid option argument
    CLIVE_SYSTEM      => 6,    # system call failed (e.g. fork)
    CLIVE_REGEXP      => 7,    # regexp pattern matching failed
    CLIVE_FORMAT      => 8,    # requested format unavailable
    CLIVE_NET         => 9,    # network error
    CLIVE_STOP        => 10,   # --stop-after
};

our @EXPORT_OK = qw(
    CLIVE_OK
    CLIVE_NOTHINGTODO
    CLIVE_NOSUPPORT
    CLIVE_READ
    CLIVE_GREP
    CLIVE_OPTARG
    CLIVE_SYSTEM
    CLIVE_REGEXP
    CLIVE_FORMAT
    CLIVE_NET
    CLIVE_STOP
);

1;

# The thief he kindly spoke.
