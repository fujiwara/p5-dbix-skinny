use t::Utils;
use Mock::Basic;
use Test::Declare;
use Data::Dumper;

plan tests => blocks;

describe 'insert test' => run {
    init {
        Mock::Basic->setup_test_db;
        Mock::Basic->attribute->{profile} = 1;
    };

    test 'quote sql by sqlite' => run {
        my $row = Mock::Basic->insert('mock_basic',{
            id   => 1,
            name => 'perl',
        });
        is +Mock::Basic->profiler->query_log->[0] , 'INSERT INTO mock_basic (`name`, `id`) VALUES (?, ?) :binds perl, 1';
        $row->update({name => 'ruby'});
        is +Mock::Basic->profiler->query_log->[2], 'UPDATE mock_basic SET `name` = ? WHERE (id = ?) :binds ruby, 1';
    };
};

