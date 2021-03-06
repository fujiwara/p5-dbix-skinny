package DBIx::Skinny::DBD::Pg;
use strict;
use warnings;
use DBIx::Skinny::SQL;

sub last_insert_id {
    my ($self, $dbh, $sth, $args) = @_;
    $dbh->last_insert_id(undef, undef, $args->{table}, undef);
}

sub sql_for_unixtime {
    "TRUNC(EXTRACT('epoch' from NOW()))";
}

sub quote    { '"' }
sub name_sep { '.' }

sub bulk_insert {
    my ($skinny, $table, $args) = @_;

    $skinny->dbh->begin_work;

        for my $arg ( @{$args} ) {
            $skinny->insert($table, $arg);
        }

    $skinny->dbh->commit;

    return 1;
}

sub query_builder_class { 'DBIx::Skinny::SQL' }

1;
