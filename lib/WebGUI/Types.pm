package WebGUI::Types;

use Moose;
use Moose::Util::TypeConstraints;

subtype 'WebGUI::Type::JSONArray'
    => as 'ArrayRef'
;

coerce 'WebGUI::Type::JSONArray'
    => from Str
    => via  { my $struct = eval { JSON::from_json($_); }; $struct ||= []; return $struct; },
;

coerce 'WebGUI::Type::JSONArray'
    => from Undef
    => via  { return []; },
;

1;
