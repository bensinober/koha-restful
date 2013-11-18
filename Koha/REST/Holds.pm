package Koha::REST::Holds;

use base 'CGI::Application';
use Modern::Perl;

use Koha::REST::Response qw(format_response response_boolean);
use C4::Reserves;
use C4::HoldsQueue qw(GetHoldsQueueItems);
use C4::Circulation;
use C4::Biblio;
use C4::Items;
use C4::Koha;   # GetItemTypes
use C4::Branch; # GetBranches
use C4::Members;
use YAML;
use File::Basename;
use JSON;

sub setup {
    my $self = shift;
    $self->run_modes(
        get_all_holds        => 'rm_get_all_holds',
        get_pending_holds    => 'rm_get_pending_holds',
        get_holds_for_branch => 'rm_get_holds_for_branch',
    );
}

sub rm_get_all_holds {
    my $self = shift;
    return format_response($self, get_all_holds() );
}

sub rm_get_pending_holds {
    my $self = shift;
    return format_response($self, get_pending_holds() );
}

# return array of biblio items with pendings holds
sub get_pending_holds {
    my $response = [];
    my $pending_hold_biblionumbers = C4::HoldsQueue::GetBibsWithPendingHoldRequests();
    foreach my $pending_hold_biblionumber (@$pending_hold_biblionumbers) {
        my $requests = C4::HoldsQueue::GetPendingHoldRequestsForBib($pending_hold_biblionumber);
        foreach my $request (@$requests) {
            push @$response, {
                request => $request,
            };
        };
    };

    return $response;
}

sub rm_get_holds_for_branch {
    my $self = shift;
    my $branchcode = $self->param('branchcode');
    return format_response($self, get_holds_for_branch($branchcode));
}

# return all holds in queue
sub get_all_holds {
    my $response = [];
    my $pending_holds = GetHoldsQueueItems();
    foreach my $pending_hold (@$pending_holds) {
        push @$response, {
            hold => $pending_hold
        };
    };
    return [@$pending_holds];
}

# return current holds for a branch
sub get_holds_for_branch {
    my ($branchcode) = @_;
    return [] unless ($branchcode);

    my $response = [];
    
    #my @holds = C4::Reserves::GetReservesForBranch($branchcode);
    my $pending_hold_biblionumbers = C4::HoldsQueue::GetBibsWithPendingHoldRequests();
    my @pending_hold_biblionumbers2 = GetHoldsQueueItems($branchcode);
    foreach my $pending_hold_biblionumber (@$pending_hold_biblionumbers) {
        # my $holds = C4::HoldsQueue::GetPendingHoldRequestsForBib($pending_hold_biblionumber);
        my $reserves = C4::Reserves::GetReservesFromBiblionumber($pending_hold_biblionumber);
        foreach my $reserve (@$reserves) {
            my $biblio = (C4::Biblio::GetBiblio($reserve->{biblionumber}))[-1];
            my $item = (C4::Items::GetItem($reserve->{itemnumber}))[-1];
            push @$response, {
                hold_id => $reserve->{reserve_id},
                priority => $reserve->{priority},
                lowestPriority => $reserve->{lowestPriority},
                reservedate => $reserve->{reservedate},
                reservenotes => $reserve->{reservenotes},
                reservedate => $reserve->{reservedate},
                reservetime => $reserve->{reservetime},
                biblionumber => $reserve->{biblionumber},
                branchcode => $reserve->{branchcode},
                itemnumber => $reserve->{itemnumber},
                title => $biblio ? $biblio->{title} : '',
                barcode => $item ? $item->{barcode} : '',
                itemcallnumber => $item ? $item->{itemcallnumber} : '',
                branchname => C4::Branch::GetBranchName($reserve->{branchcode}),
                expirationdate => $reserve->{expirationdate},
                found => $reserve->{found},
                suspend => $reserve->{suspend},
                suspend_until => $reserve->{suspend_until},
                constrainttype => $reserve->{constrainttype},
            };
        };
    };
    return $response;
}

1;
