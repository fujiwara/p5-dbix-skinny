package DBIx::Skinny::DBD::mysql;
use strict;
use warnings;
use DBIx::Skinny::SQL;

sub last_insert_id {
    $_[1]->{mysql_insertid} || $_[1]->{insertid}
}

sub sql_for_unixtime {
    return "UNIX_TIMESTAMP()";
}

sub quote    { '`' }
sub name_sep { '.' }

sub bulk_insert {
    my ($skinny, $table, $args) = @_;

    my (@cols, @bind);
    for my $arg (@{$args}) {
        # deflate
        for my $col (keys %{$arg}) {
            $arg->{$col} = $skinny->schema->call_deflate($col, $arg->{$col});
        }

        if (scalar(@cols)==0) {
            for my $col (keys %{$arg}) {
                push @cols, $col;
            }
        }

        for my $col (keys %{$arg}) {
            push @bind, $skinny->schema->utf8_off($col, $arg->{$col});
        }
    }

    my $sql = "INSERT INTO $table\n";
    $sql .= '(' . join(', ', @cols) . ')' . "\nVALUES ";

    my $values = '(' . join(', ', ('?') x @cols) . ')' . "\n";
    $sql .= join(',', ($values) x (scalar(@bind) / scalar(@cols)));

    $skinny->profiler($sql, \@bind);
    $skinny->_execute($sql, \@bind);

    return 1;
}

sub query_builder_class { 'DBIx::Skinny::SQL' }

1;

