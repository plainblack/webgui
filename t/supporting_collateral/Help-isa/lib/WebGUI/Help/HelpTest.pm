package WebGUI::Help::HelpTest;

our $HELP = {

    'base one' => {
        title     => 'base one title',
        body      => 'base one body',
        variables => [
            { name => 'base one var1', },
            { name => 'base one var2', },
            { name => 'base one var3', },
        ],
        fields    => [],
        related   => []
    },

    'isa one' => {
        title     => 'isa one title',
        body      => 'isa one body',
        isa       => [
            {   namespace => "HelpTest",
                tag       => "base one"
            },
        ],
        variables => [
            { name => 'isa one var1', },
            { name => 'isa one var2', },
            { name => 'isa one var3', },
        ],
        fields    => [],
        related   => [],
    },

    'loop one' => {
        title     => 'loop one title',
        body      => 'loop one body',
        isa       => [
        ],
        variables => [
            { name => 'loop one var1',
              variables => [
                { name => 'loop one loop1', },
                { name => 'loop one loop2', },
              ],
            },
            { name => 'loop one var2', },
        ],
        fields    => [],
        related   => [],
    },

    'isa loop one' => {
        title     => 'isa loop one title',
        body      => 'isa loop one body',
        isa       => [
            {   namespace => "HelpTest",
                tag       => "loop one"
            },
        ],
        variables => [
            { name => 'isa loop one var1', },
        ],
        fields    => [],
        related   => [],
    },

    'deep loop' => {
        title     => 'deep loop title',
        body      => 'deep loop body',
        isa       => [
        ],
        variables => [
            { name => 'deep loop var1',
              variables => [
                { name => 'deep loop loop2',
                  variables => [
                    { name => 'deep loop loop3',
                      variables => [
                        { name => 'deep loop loop4',
                        },
                      ],
                    },
                  ],
                },
              ],
            },
        ],
        fields    => [],
        related   => [],
    },

    'isa deep loop' => {
        title     => 'isa deep loop title',
        body      => 'isa deep loop body',
        isa       => [
            {   namespace => "HelpTest",
                tag       => "deep loop"
            },
        ],
        variables => [
            { name => 'isa deep loop var1', },
        ],
        fields    => [],
        related   => [],
    },

};

1;
