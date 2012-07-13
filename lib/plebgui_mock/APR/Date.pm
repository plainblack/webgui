package APR::Date;

use DateTime::Format::HTTP;

sub parse_http {
    return DateTime::Format::HTTP->parse_datetime( shift )->epoch;
}

1;
