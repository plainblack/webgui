package WebGUI::Workflow::Instance::GenericObject;

sub new {
    my ($class, $session, $properties) = @_;
    bless { session => $session, %$properties }, $class;
}

1;