package Koha::REST::Holds;

use base 'CGI::Application';
use Modern::Perl;

use Koha::REST::Response qw(format_response response_boolean);
use C4::Reserves;
use C4::HoldsQueue;
use C4::Circulation;
use C4::Biblio;

use C4::Items;
use C4::Branch;
use C4::Members;
use YAML;
use File::Basename;
use JSON;
use Data::Dumper qw(Dumper);

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

# return array of biblio items with pendings holds
sub get_pending_hold_biblionumbers {
    my @pending_holds = C4::HoldsQueue::GetBibsWithPendingHoldRequests();
    return @pending_holds;
}

# return current holds for a branch
sub get_holds_for_branch {
    my ($branchcode) = @_;
    return [] unless ($branchcode);

    my $response = [];
    
    #my @holds = C4::Reserves::GetReservesForBranch($branchcode);
    my $pending_hold_biblionumbers = C4::HoldsQueue::GetBibsWithPendingHoldRequests();
    # my @pending_hold_biblionumbers = C4::HoldsQueue::GetHoldsQueueItems($branchcode);
    foreach my $pending_hold_biblionumber (@$pending_hold_biblionumbers) {
        my $holds = C4::HoldsQueue::GetPendingHoldRequestsForBib($pending_hold_biblionumber);
        my $reserves = C4::Reserves::GetReservesFromBiblionumber($pending_hold_biblionumber);
        foreach my $hold (@$holds) {
            push @$response, {
                hold => $hold
            };
        };
        foreach my $reserve (@$reserves) {
            push @$response, {
                reserve => $reserve
            };
        };
    };
    # foreach my $hold (@holds) {
    #     my $biblio = (C4::Biblio::GetBiblio($hold->{biblionumber}))[-1];
    #     my $item = C4::Items::GetItem($hold->{itemnumber});
    #     push @$response, {
    #         hold_id => $hold->{reserve_id},
    #         rank => $hold->{priority},
    #         reservedate => $hold->{reservedate},
    #         biblionumber => $hold->{biblionumber},
    #         branchcode => $hold->{branchcode},
    #         itemnumber => $hold->{itemnumber},
    #         title => $biblio ? $biblio->{title} : '',
    #         barcode => $item ? $item->{barcode} : '',
    #         itemcallnumber => $item ? $item->{itemcallnumber} : '',
    #         branchname => C4::Branch::GetBranchName($hold->{branchcode}),
    #         cancellationdate => $hold->{cancellationdate},
    #         found => $hold->{found},
    #     };
    # }
    return $response;
}

1;
