##########################################################################
#
#   Copyright (c) 2003 Aymargeddon Development Team
#
#   This file is part of
#   "FROGS" = Framework for Realtime Online Games of Strategy
#
#   FROGS is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2 of the License, or (at your option)
#   any later version.
#
#   FROGS is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#   more details.
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, write to the Free Software Foundation, Inc., 675
#   Mass Ave, Cambridge, MA 02139, USA.
#
###########################################################################
#

#
# This file holds a baseclass for the topology of the game.
# All methods here are independent of a concrete topology. 
# but they require, that such dependent functions exists,
# so this base class did not work if there is no derived class.
#
# Derived classes have to implement the following functions
#
# grep() - return a list of all locations with true evaluation of sub
# neighbours() - returns a list of all neigbours of location
# distance() - returns the distance between two locations
#
# have a look at HexTorus.pm to see an example


package Map;

use strict;

# returns all locations
sub get_all{
    my $self = shift;

    return $self->grep(sub{1;});
}

# returns all locations with distance <= dist arround loc
sub distant_neighbours{
    my ($self,$loc,$dist) = @_;

    # for performance reason
    # TODO: do this only, if neighbours() is avaiable in the derived class
    return $self->neighbours($loc) if $dist == 1;

    return $self->grep(sub{
	my $loc2 = shift;
	return $self->distance($loc,$loc2) <= $dist;});

}

1;


