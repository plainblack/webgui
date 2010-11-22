package WebGUI::Session;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use 5.010;

use CHI;
use File::Temp qw( tempdir );
use HTTP::Message::PSGI;
use HTTP::Request::Common;
use WebGUI::Config;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Session::DateTime;
use WebGUI::Session::Log;
use WebGUI::Session::Form;
use WebGUI::Session::Http;
use WebGUI::Session::Icon;
use WebGUI::Session::Id;
use WebGUI::Session::Output;
use WebGUI::Session::Privilege;
use WebGUI::Session::Request;
use WebGUI::Session::Scratch;
use WebGUI::Session::Setting;
use WebGUI::Session::Stow;
use WebGUI::Session::Style;
use WebGUI::Session::Url;

=head1 NAME

Package WebGUI::Session

=head1 DESCRIPTION

This package is the heart and lifeblood of WebGUI; it is the glue that holds WebGUI together. When you create a session object, you'll immediately have access to all sorts of other objects. By passing the session object around in code you'll have access to the default database connection, error handler, user and more without having to create it each time. The lends much speed to WebGUI.

B<NOTE:> It is important to distinguish the difference between a WebGUI session and a user session. A user session is just part of a WebGUI session. A WebGUI session is all of the basic data the WebGUI needs to operate.

=head1 SYNOPSIS

 use WebGUI::Session;

 $session = WebGUI::Session->open($configFile);
 $sessionId = $session->getId;
 ($form, $db, $user) = $session->quick("form", "db", "user");
 $session->close;

 $session->asset
 $session->config
 $session->datetime
 $session->db
 $session->dbSlave
 $session->log
 $session->form
 $session->http
 $session->icon
 $session->id
 $session->output
 $session->privilege
 $session->request
 $session->response
 $session->scratch
 $session->setting
 $session->stow
 $session->style
 $session->url
 $session->user


=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 asset ( [ asset ] )

A reference to the default asset. The default asset is whatever one is being currently requested via the URL.

=head3 asset

You may optionally replace the default asset by passing in an asset object reference.

=cut

sub asset {
	my $self = shift;
	my $asset = shift;
	if ($asset) {
		$self->{_asset} = $asset;
	}
	return $self->{_asset};
}

#-------------------------------------------------------------------

=head2 cache ( ) 

Returns a CHI object, configured according to the settings in the config file.

=cut

sub cache {
    my $self = shift;
    unless (exists $self->{_cache}) {
        my $cacheConf    = $self->config->get('cache') || { driver => "Memory", global => 1 };

        # Default values
        my $resolveConf = sub {
            my ($config) = @_;
            given ( $config->{driver} ) {
                when ( /DBI/ ) {
                    $config->{ dbh } = $self->db->dbh;
                    continue;
                }
                when ( /File|FastMmap|BerkeleyDB/ ) {
                    $config->{ root_dir } ||= tempdir();
                    continue;
                }
                when ( /FastMmap/ ) {
                    #$config->{ cache_size } = '64m';
                    continue;
                }
            }
            $config->{namespace} ||= $self->config->get('sitename')->[0];
        };

        $resolveConf->( $cacheConf );
        if ( $cacheConf->{l1_cache} ) {
            $resolveConf->( $cacheConf->{l1_cache} );
        }

        my $cache   = CHI->new( %{$cacheConf} );
        $self->{_cache} = $cache;
    }
    return $self->{_cache};
}

#-------------------------------------------------------------------

=head2 clearAsset ( )

Clears out the session asset.

=cut

sub clearAsset {
    my $self        = shift;
    $self->{_asset} = undef;
}

#-------------------------------------------------------------------

=head2 close

Cleans up a WebGUI session information from memory and disconnects from any resources opened by the session.

=cut

sub close {
	my $self = shift;
	$self->db->disconnect if (exists $self->{_db});

	# Kill circular references.  The literal list is so that the order
	# can be explicitly shuffled as necessary.
	foreach my $key (qw/_asset _datetime _icon _slave _db _form _http _id _output _privilege _scratch _setting _stow _style _url _user _cache _log _response _request/) {
		delete $self->{$key};
	}
    $self->{closed} = 1;
}

#-------------------------------------------------------------------

=head2 closed

Returns true if this session has been closed.

=cut

sub closed {
    my $self = shift;
    return $self->{closed};
}

#-------------------------------------------------------------------

=head2 config ( ) 

Returns a WebGUI::Config object.

=cut

sub config {
	my $self = shift;
	return $self->{_config};
}


#-------------------------------------------------------------------

=head2 datetime ( )

Returns a WebGUI::Session::DateTime object.

=cut

sub datetime {
	my $self = shift;
	unless (exists $self->{_datetime}) {
		$self->{_datetime} = WebGUI::Session::DateTime->new($self);
	}
	return $self->{_datetime};
}

#-------------------------------------------------------------------

=head2 db ( [ skipFatal ] ) 

Returns a WebGUI::SQL object, which is connected to the WebGUI database.

=head3 skipFatal

If set to true, we won't throw a fatal error, just return undef.

=cut

sub db {
	my $self = shift;
	my $skipFatal = shift;
	unless (exists $self->{_db}) {
		my $db = WebGUI::SQL->connect($self,$self->config->get("dsn"), $self->config->get("dbuser"), $self->config->get("dbpass"));
		if (!defined $db && defined $self->config->get("failoverdb")) {
			$self->log->warn("Main DB down, resorting to using failover.");
			my $failover = $self->config->get("failoverdb");
			$db = WebGUI::SQL->connect($self,$failover->{dsn}, $failover->{user}, $failover->{password});
		}
		if (defined $db) {
			$self->{_db} = $db;
		}
		else {
			if ($skipFatal) {
				return undef;
			}
			else { 	
				$self->log->fatal("Couldn't connect to WebGUI database, and can't continue without it.");
			}
		}
	}
	return $self->{_db};
}

#-------------------------------------------------------------------

=head2 dbSlave ( ) 

Returns a random slave database handler, if one is defined, otherwise it returns the main one. Likewise if admin mode is on it returns the main one.

=cut

sub dbSlave {
	my $self = shift;
    return $self->db if $self->isAdminOn;
	unless (exists $self->{_slave}) {
		my @slaves = ();
		foreach (1..3) {
			my $slave = $self->config->get("dbslave".$_);
			if (exists $slave->{dsn}) {
				push (@slaves, $slave);
			}
		}
        if (scalar @slaves > 0) {
            my $slave = $slaves[rand @slaves];
            $self->{_slave} = WebGUI::SQL->connect($self, $slave->{dsn},$slave->{user},$slave->{pass});
        }
	}
    if (!exists $self->{_slave}) {
        return $self->db;
    }
    else {
        return $self->{_slave};
    }
}


#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
	$self->close;
}

#-------------------------------------------------------------------

=head2 duplicate ( )

Creates a new session using the same WebGUI root, config file, and user.

=cut

sub duplicate {
    my $self = shift;
    my $newSession = WebGUI::Session->open(
        $self->config,
        undef,
        $self->getId,
    );
    return $newSession;
}


#-------------------------------------------------------------------

=head2 end ( )

Removes the specified session from memory and database.

=cut

sub end {
    my $self = shift;
    my $id = $self->getId;
    $self->cache->remove($id);
    $self->scratch->deleteAll;
    $self->db->write("delete from userSession where sessionId=?",[$id]);
    delete $self->{_user};
}

#-------------------------------------------------------------------

=head2 errorHandler ( )

An alias for log(). Depricated. Will be removed in WebGUI 8.

=cut

sub errorHandler {
	my $self = shift;
    return $self->log;
}

#-------------------------------------------------------------------

=head2 form ( )

Returns a WebGUI::Session::Form object.

=cut

sub form {
	my $self = shift;
	unless (exists $self->{_form}) {
		$self->{_form} = WebGUI::Session::Form->new($self);
	}
	return $self->{_form};
}

#-------------------------------------------------------------------

=head2 get ( varName )

Retrieves the current value of a session variable.

=head3 varName

The name of the variable.

=head4 lastIP

The last IP address the user came from.

=head4 lastPageView

The epoch date of the last interaction with the session.

=head4 userId

The unique id of the user this session currently bound to.

=head4 adminOn

A boolean indicating whether this session has admin mode enabled or not.

=head4 sessionId

The sessionId associated with this session.

=head4 expires

The epoch date when this user session will expire if it's not accessed again by then.

=cut

sub get {
	my $self    = shift;
	my $varName = shift;
    if ($varName) {
        return $self->{_var}{$varName};
    }
    return $self->{_var};
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the current session Id.

=cut

sub getId {
	my $self = shift;
	return $self->{_sessionId};
}

#-------------------------------------------------------------------

=head2 hasSettings

Checks if the settings have been initialized yet

=cut

sub hasSettings {
    my $self = shift;
    return exists $self->{_setting};
}

#-------------------------------------------------------------------

=head2 http ( )

Returns a reference to the WebGUI::Session::Http object.

=cut

sub http {
	my $self = shift;
	unless ($self->{_http}) {
		$self->{_http} = WebGUI::Session::Http->new($self);
	}
	return $self->{_http};
}


#-------------------------------------------------------------------

=head2 icon ( )

Returns a WebGUI::Session::Icon object.

=cut

sub icon {
	my $self = shift;
	unless ($self->{_icon}) {
		$self->{_icon} = WebGUI::Session::Icon->new($self);
	}
	return $self->{_icon};
}


#-------------------------------------------------------------------

=head2 id ( )

Returns a reference to the WebGUI::Session::Id object.

=cut

sub id {
	my $self = shift;
	unless ($self->{_id}) {
		$self->{_id} = WebGUI::Session::Id->new($self->config->getFilename);
	}
	return $self->{_id};
}


#-------------------------------------------------------------------

=head2 isAdminOn  ( )

Returns a boolean indicating whether admin mode is on or not.

=cut

sub isAdminOn {
        my $self = shift;
        return $self->get("adminOn");
}

#-------------------------------------------------------------------

=head2 log ( )

Returns a WebGUI::Session::Log object, which is used for logging.

=cut

sub log {
	my $self = shift;
	unless (exists $self->{_log}) {
		$self->{_log}  = WebGUI::Session::Log->new($self);
	}
	return $self->{_log};
}

#-------------------------------------------------------------------

=head2 open ( configFile [, env, sessionId, noFuss ] )

Constructor. Opens a closed ( or new ) WebGUI session.

=head3 configFile

The filename of the config file that WebGUI should operate from, or a WebGUI::Config object

=head3 env

The L<PSGI> env hash. If this session is being instanciated from the web, this is required.

=head3 sessionId

Optionally retrieve a specific session id. Normally this is set by a cookie in the user's browser.
If you have a L<PSGI> env hash, you might find the sessionId at: $env->{'psgix.session'}->id

=head3 noFuss

Uses simple session vars. See WebGUI::Session->open() for more details.

=cut

sub open {
    my ($class, $c, $env, $sessionId, $noFuss) = @_;
    my $config = ref $c ? $c : WebGUI::Config->new($c);
    my $self = { _config => $config };
    bless $self, $class;

    ##No env was passed, so construct one
    if (! $env) {
        my $url = 'http://' . $config->get('sitename')->[0];
        my $request = HTTP::Request::Common::GET($url);
        $request->headers->user_agent('WebGUI');
        $env = $request->to_psgi;
    }

    my $request = WebGUI::Session::Request->new($env);
    $self->{_request} = $request;
    ##Set defaults
    $self->{_response} = $request->new_response( 200 );
    $self->{_response}->content_type('text/html; charset=UTF-8');

    # Use the WebGUI::Session::Request object to look up the sessionId from cookies, if it
    # wasn't given explicitly
    $sessionId ||= $request->cookies->{$config->getCookieName};

    # If the sessionId is still unset or is invalid, generate a new one
    if (!$sessionId || !$self->id->valid($sessionId)) {
        $sessionId = $self->id->generate;
    }
    $self->{_var} = $self->cache->get($sessionId);
    unless ($self->{_var}{sessionId} eq $sessionId) {
        $self->{_var} = $self->db->quickHashRef("select * from userSession where sessionId=?", [$sessionId]);
    }
    ##We have to make sure that the session variable has a sessionId, otherwise downstream users of
    ##the object will break
    if ($noFuss && $self->{_var}{sessionId}) {
        $self->{_sessionId} = $self->{_var}{sessionId};
        return $self;
    }
    if ($self->{_var}{expires} && $self->{_var}{expires} < time()) { ##Session expired, start a new one with the same Id, as visitor
        $self->end;
        $self->start(1, $sessionId);
    }
    elsif ($self->{_var}{sessionId} ne "") { ##Fetched an existing session.  Update variables with recent data.
        my $time = time();
        my $timeout = $self->setting->get("sessionTimeout");
        $self->{_sessionId}         = $self->{_var}{sessionId};
        $self->{_var}{lastPageView} = $time;
        $self->{_var}{lastIP}       = $self->request->address;
        $self->{_var}{expires}      = $time + $timeout;
        if ($self->{_var}{nextCacheFlush} > 0 && $self->{_var}{nextCacheFlush} < $time) {
            delete $self->{_var}{nextCacheFlush};
            $self->db->setRow("userSession","sessionId",$self->{_var});
        }
        else {
            $self->{_var}{nextCacheFlush} = $time + $self->config->get("hotSessionFlushToDb");
            $self->cache->set($sessionId, $self->{_var}, $timeout);
        }
    }
    else {  ##Start a new default session with the requested, non-existant id.
        $self->start(1,$sessionId);
    }

	return $self;
}

#-------------------------------------------------------------------

=head2 output ( )

Returns a WebGUI::Session::Output object.

=cut

sub output {
	my $self = shift;
	unless (exists $self->{_output}) {
		$self->{_output} = WebGUI::Session::Output->new($self);
	}
	return $self->{_output};
}


#-------------------------------------------------------------------

=head2 privilege ( )

Returns a WebGUI::Session::Privilege object.

=cut

sub privilege {
	my $self = shift;
	unless (exists $self->{_privilege}) {
		$self->{_privilege} = WebGUI::Session::Privilege->new($self);
	}
	return $self->{_privilege};
}

#-------------------------------------------------------------------

=head2 quick ( methods )

A convenience method that returns a list of object references.

=head3 methods

An array of method names of the objects you want returned.

=cut

sub quick {
	my $self = shift;
	my @methods = @_;
	my @list = ();
	foreach my $method (@methods) {
		push(@list, $self->$method);
	}
	return @list;
}

#-------------------------------------------------------------------

=head2 request ( )

Returns the L<Plack::Request> object, or undef if it doesn't exist.

=cut

sub request {
	my $self = shift;
	return $self->{_request};
}

#-------------------------------------------------------------------

=head2 response ( )

Returns the L<Plack::Response> object, or undef if it doesn't exist.

=cut

sub response {
	my $self = shift;
	return $self->{_response};
}

#-------------------------------------------------------------------

=head2 scratch ( )

Returns a WebGUI::Session::Scratch object.

=cut

sub scratch {
	my $self = shift;
	unless (exists $self->{_scratch}) {
		$self->{_scratch} = WebGUI::Session::Scratch->new($self);
	}
	return $self->{_scratch};
}

#-------------------------------------------------------------------

=head2 server ( )

DEPRECATED (used to return the Apache2::ServerUtil object)

=cut

sub server {
	my $self = shift;
	$self->log->fatal('WebGUI::Session::server is deprecated');
}

#-------------------------------------------------------------------

=head2 setting ( param ) 

Returns the associated WebGUI::Session::Setting object.

=cut

sub setting {
	my $self = shift;
	unless (exists $self->{_setting}) {
		$self->{_setting} = WebGUI::Session::Setting->new($self);
	}
	return $self->{_setting};
}


#-------------------------------------------------------------------

=head2 start ( [ userId,  sessionId ] )

Start a new user session. Returns the user session id.  The session variable's sessionId
is set to the var object's session id.  Also sets the user's CSRF token.

=head3 userId

The user id of the user to create a session for. Defaults to 1 (Visitor).

=head3 sessionId

Session id will be generated if not specified. In almost every case you should let the system generate the session id.

=cut

sub start {
	my $self = shift;
	my $userId = shift;
	$userId    = 1 if ($userId eq "");
	my $sessionId = shift;
	$sessionId    = $self->id->generate if ($sessionId eq "");
    my $timeout   = $self->setting->get('sessionTimeout');
	my $time = time();
	$self->{_var} = {
		expires      => $time + $timeout,
		lastPageView => $time,
		lastIP       => $self->request->address,
		adminOn      => 0,
		userId       => $userId
	};
    $self->{_sessionId} = $sessionId;
    $self->cache->set($sessionId, $self->{_var}, $timeout);
    delete $self->{_var}{nextCacheFlush};
	$self->db->setRow("userSession","sessionId",$self->{_var}, $sessionId);
    $self->scratch->set('webguiCsrfToken', $self->id->generate); # create cross site request forgery token
}

#-------------------------------------------------------------------

=head2 stow ( )

Returns a WebGUI::Session::Stow object.

=cut

sub stow {
	my $self = shift;
	unless (exists $self->{_stow}) {
		$self->{_stow} = WebGUI::Session::Stow->new($self);
	}
	return $self->{_stow};
}

#-------------------------------------------------------------------

=head2 style ( )

Returns a WebGUI::Session::Style object.

=cut

sub style {
	my $self = shift;	
	unless (exists $self->{_style}) {
		$self->{_style} = WebGUI::Session::Style->new($self);
	}
	return $self->{_style}
}


#-------------------------------------------------------------------

=head2 switchAdminOff ( )

Disables admin mode.

=cut

sub switchAdminOff {
    my $self = shift;
    $self->{_var}{adminOn} = 0;
    $self->cache->set($self->getId, $self->{_var}, $self->setting->get('sessionTimeout'));
    delete $self->{_var}{nextCacheFlush};
    $self->db->setRow("userSession","sessionId", $self->{_var});
}

#-------------------------------------------------------------------

=head2 switchAdminOn ( )

Enables admin mode.

=cut

sub switchAdminOn {
    my $self = shift;
    $self->{_var}{adminOn} = 1;
    $self->cache->set($self->getId, $self->{_var}, $self->setting->get('sessionTimeout'));
    delete $self->{_var}{nextCacheFlush};
    $self->db->setRow("userSession","sessionId", $self->{_var});
}

#-------------------------------------------------------------------

=head2 url ( ) 

Returns a WebGUI::Session::Url object.

=cut

sub url {
	my $self = shift;
	unless (exists $self->{_url}) {
		$self->{_url} = WebGUI::Session::Url->new($self);
	}
	return $self->{_url};
}

#-------------------------------------------------------------------

=head2 user ( [ option ] )

Returns the WebGUI::User object for the user attached to the current session.

=head3 option

A hash reference containing values to change the functionality of this method.

=head4 userId

Changes the user bound to the session to this user.

=head4 user

A user object to change the current user to.

=cut

sub user {
	my $self = shift;
	my $option = shift;
	if (defined $option) {
		my $userId = $option->{userId} || $option->{user}->userId; 
   		$self->start($userId,$self->getId);
		if ($self->setting->get("passiveProfilingEnabled")) {
			$self->db->write("update passiveProfileLog set userId = ? where sessionId = ?",[$userId,$self->getId]);
		}	
		delete $self->{_stow};
		$self->{_user} = $option->{user} || WebGUI::User->new($self, $userId);
		$self->request->env->{REMOTE_USER} = $self->{_user}->username if $self->request;
	}
    elsif (!exists $self->{_user}) {
		$self->{_user} = WebGUI::User->new($self, $self->get('userId'));
		$self->request->env->{REMOTE_USER} = $self->{_user}->username if $self->request;
	} 
    return $self->{_user};
}


#-------------------------------------------------------------------

=head2 var ( )

DEPRECATED.  Session::Var was absorbed into Session in WebGUI 8.0.

Returns a reference to the WebGUI::Session::Var object.

=cut

sub var {
	return $_->[0];
}

1;
