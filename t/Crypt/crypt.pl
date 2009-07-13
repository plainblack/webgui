sub make_string {
    my $length = shift;
    my @chars=('a'..'z','A'..'Z','0'..'9','_');
    my $key = q{};
    for (0..$length) {
        $key .= $chars[rand @chars];
    }
    return $key;
}

sub test_provider {
    my ($crypt, $plaintext) = @_;
    isa_ok( $crypt, 'WebGUI::Crypt', 'constructor works' );
    my $encrypted_hex = $crypt->encrypt_hex($plaintext);
    my $decrypted = $crypt->decrypt_hex($encrypted_hex);
    is($decrypted, $plaintext, "got back our original text: $decrypted");
}

1;
