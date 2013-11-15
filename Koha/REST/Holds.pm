package Koha::REST::Holds;

use base 'CGI::Application';
use Modern::Perl;

use Koha::REST::Response qw(format_response response_boolean);
use C4::Reserves;
use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Branch;
use C4::Members;
use YAML;
use File::Basename;
use JSON;

sub setup {
    my $self = shift;
    $self->run_modes(
        get_holds_for_branch => 'rm_get_holds_for_branch',
    );
}

sub rm_get_holds_for_branch {
    my $self = shift;
    my $branchcode = $self->param('branchcode');

    return format_response($self, get_holds_for_branch($branchcode));
}

# return current holds for a branch
sub get_holds_for_branch {
    my ($branchcode) = @_;
    return [] unless ($branchcode);

    my $response = [];
    my @holds = C4::Reserves::GetReservesForBranch($branchcode);
    foreach my $hold (@holds) {
        # Up to Koha 3.8 GetBiblio returns an array whose last element is the
        # biblio hash.
        # Starting with Koha 3.10 GetBiblio returns only the biblio hash.
        # Getting the last element of what is returned by this sub allow to be
        # compatible with all versions.
        my $biblio = (C4::Biblio::GetBiblio($hold->{biblionumber}))[-1];
        my $item = C4::Items::GetItem($hold->{itemnumber});
        push @$response, {
            hold_id => $hold->{reserve_id},
            rank => $hold->{priority},
            reservedate => $hold->{reservedate},
            biblionumber => $hold->{biblionumber},
            branchcode => $hold->{branchcode},
            itemnumber => $hold->{itemnumber},
            title => $biblio ? $biblio->{title} : '',
            barcode => $item ? $item->{barcode} : '',
            itemcallnumber => $item ? $item->{itemcallnumber} : '',
            branchname => C4::Branch::GetBranchName($hold->{branchcode}),
            cancellationdate => $hold->{cancellationdate},
            found => $hold->{found},
        };
    }

    return $response;
}

1;
