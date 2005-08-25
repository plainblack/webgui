package WebGUI::Form;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::IxHash;
use WebGUI::Asset;
use WebGUI::Asset::RichEdit;
use WebGUI::Asset::Template;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Form

=head1 DESCRIPTION

This is a convenience package which provides a simple interface to use all of the form controls without having to load each one seperately, create objects, and call methods.

=head1 SYNOPSIS

 use WebGUI::Form;

 $html = WebGUI::Form::formFooter();
 $html = WebGUI::Form::formHeader();

 $html = WebGUI::Form::anyFieldType(%properties);

 Example:

 $html = WebGUI::Form::text(%properties);

=head1 METHODS 

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 AUTOLOAD ()

Dynamically creates functions on the fly for all the different form control types.

=cut

sub AUTOLOAD {
	our $AUTOLOAD;
	my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);	
	my @params = @_;
	my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);
        if ($@) {
        	WebGUI::ErrorHandler::error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }
	my $class = "WebGUI::Form::".$name;
	return $class->new(@params)->toHtml;
}

#-------------------------------------------------------------------
sub _fixMacros {
	my $value = shift;
	$value =~ s/\^/\&\#94\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _fixQuotes {
        my $value = shift;
	$value =~ s/\"/\&quot\;/g;
        return $value;
}

#-------------------------------------------------------------------
sub _fixSpecialCharacters {
	my $value = shift;
	$value =~ s/\&/\&amp\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _fixTags {
	my $value = shift;
	$value =~ s/\</\&lt\;/g;
        $value =~ s/\>/\&gt\;/g;
	return $value;
}



#-------------------------------------------------------------------

=head2 dynamicField ( fieldType , hashRef )
                                                                                                                         
Returns a dynamic configurable field.
                                                                                                                         
=head3 fieldType

The field type to use. The field name is the name of the method from this forms package.

=head3 options

The field options. See the documentation for the desired field for more information.
                                                                                                                         
=cut

sub dynamicField {
	my $fieldType = ucfirst(shift);
	my $param = shift;

        # Set options for fields that use a list.
        if (isIn($fieldType,qw(SelectList CheckList RadioList))) {
                delete $param->{size};
                my %options;
                tie %options, 'Tie::IxHash';
                foreach (split(/\n/, $param->{possibleValues})) {
                        s/\s+$//; # remove trailing spaces
                        $options{$_} = $_;
                }
		if (exists $param->{options} && ref($param->{options}) eq "HASH") {
			%options = (%{$param->{options}} , %options);
		}
                $param->{options} = \%options;
        }
        # Convert value to list for selectList / checkList
        if (isIn($fieldType,qw(SelectList CheckList)) && ref $param->{value} ne "ARRAY") {
                my @defaultValues;
                foreach (split(/\n/, $param->{value})) {
                                s/\s+$//; # remove trailing spaces
                                push(@defaultValues, $_);
                }
                $param->{value} = \@defaultValues;
        }

	# Return the appropriate field.
	no strict 'refs';
	return &$fieldType($param);
}



#-------------------------------------------------------------------

=head2 formFooter ( )

Returns a form footer.

=cut

sub formFooter {
	return "</div></form>\n\n";
}


#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Returns a form header.

=head3 action

The form action. Defaults to the current page.

=head3 method

The form method. Defaults to "post".

=head3 enctype

The form enctype. Defaults to "multipart/form-data".

=head3 extras

If you want to add anything special to the form header like javascript actions or stylesheet info, then use this.

=cut

sub formHeader {
	my $params = shift;
        my $action = $params->{action} || WebGUI::URL::page();
	my $hidden;
	if ($action =~ /\?/) {
		my ($path,$query) = split(/\?/,$action);
		$action = $path;
		my @params = split(/\;/,$query);
		foreach my $param (@params) {
			$param =~ s/amp;(.*)/$1/;
			my ($name,$value) = split(/\=/,$param);
			$hidden .= hidden({name=>$name,value=>$value});
		}
	}
        my $method = $params->{method} || "post";
        my $enctype = $params->{enctype} || "multipart/form-data";
	return '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$params->{extras}.'><div class="formContents">'.$hidden;
}





1;


