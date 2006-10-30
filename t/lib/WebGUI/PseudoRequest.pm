package WebGUI::PseudoRequest;

package WebGUI::PseudoRequest::Headers;

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = { headers => {} };
	bless $self, $class;
	return $self;
}

sub set {
	my $self = shift;
	my $key = shift;
	my $value = shift;
	$self->{headers}->{$key} = $value;
}

sub fetch {
	my $self = shift;
	return $self->{headers};
}

package WebGUI::PseudoRequest;

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $headers = WebGUI::PseudoRequest::Headers->new();
	my $self = {headers_out => $headers};
	bless $self, $class;
	return $self;
}

sub body {
	my $self = shift;
	my $value = shift;
	return keys %{ $self->{body} } unless defined $value;
	return $self->{body}->{$value};
}

sub setup_body {
	my $self = shift;
	my $value = shift;
	$self->{body} = $value;
}

sub content_type {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{content_type} = $value;
	}
	return $self->{content_type};
}

sub headers_out {
	my $self = shift;
	return $self->{headers_out}; ##return object for method chaining
}

sub no_cache {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{no_cache} = $value;
	}
	return $self->{no_cache};
}

sub param {
	my $self = shift;
	my $value = shift;
	return keys %{ $self->{param} } unless defined $value;
	return $self->{param}->{$value};
}

sub setup_param {
	my $self = shift;
	my $value = shift;
	$self->{param} = $value;
}

sub protocol {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{protocol} = $value;
	}
	return $self->{protocol};
}

sub status {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{status} = $value;
	}
	return $self->{status};
}

sub status_line {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{status_line} = $value;
	}
	return $self->{status_line};
}

sub uri {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{uri} = $value;
	}
	return $self->{uri};
}

sub user {
	my $self = shift;
	my $value = shift;
	if (defined $value) {
		$self->{user} = $value;
	}
	return $self->{user};
}

1;
