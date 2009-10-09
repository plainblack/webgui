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
use WebGUI::Cache;
use WebGUI::Config;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Session::DateTime;
use WebGUI::Session::Env;
use WebGUI::Session::ErrorHandler;
use WebGUI::Session::Form;
use WebGUI::Session::Http;
use WebGUI::Session::Icon;
use WebGUI::Session::Id;
use WebGUI::Session::Os;
use WebGUI::Session::Output;
use WebGUI::Session::Privilege;
use WebGUI::Session::Request;
use WebGUI::Session::Scratch;
use WebGUI::Session::Setting;
use WebGUI::Session::Stow;
use WebGUI::Session::Style;
use WebGUI::Session::Url;
use WebGUI::Session::Var;

=head1 NAME

Package WebGUI::Session

=head1 DESCRIPTION

This package is the heart and lifeblood of WebGUI; it is the glue that holds WebGUI together. When you create a session object, you'll immediately have access to all sorts of other objects. By passing the session object around in code you'll have access to the default database connection, error handler, user and more without having to create it each time. The lends much speed to WebGUI.

B<NOTE:> It is important to distinguish the difference between a WebGUI session and a user session. A user session is just part of a WebGUI session. A WebGUI session is all of the basic data the WebGUI needs to operate.

=head1 SYNOPSIS

 use WebGUI::Session;

 $session = WebGUI::Session->open($webguiRoot, $configFile);
 $sessionId = $session->getId;
 ($form, $db, $user) = $session->quick("form", "db", "user");
 $session->close;

 $session->asset
 $session->config
 $session->datetime
 $session->db
 $session->dbSlave
 $session->env
 $session->log
 $session->form
 $session->http
 $session->icon
 $session->id
 $session->output
 $session->os
 $session->privilege
 $session->request
 $session->scratch
 $session->server
 $session->setting
 $session->stow
 $session->style
 $session->url
 $session->user
 $session->var
 

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

Returns a WebGUI::Cache object, which is connected to the WebGUI memcached server.

=cut

sub cache {
	my $self = shift;
	unless (exists $self->{_cache}) {
        my $cache = WebGUI::Cache->new($self);
		if (defined $cache) {
			$self->{_cache} = $cache;
		}
		else {
		    $self->log->fatal("Couldn't connect to WebGUI memcached server, and can't continue without it.");
		}
	}
	return $self->{_cache};
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
	foreach my $key (qw/_asset _datetime _icon _slave _db _env _form _http _id _output _os _privilege _scratch _setting _stow _style _url _user _var _cache _errorHandler/) {
		delete $self->{$key};
	}
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
			$self->errorHandler->warn("Main DB down, resorting to using failover.");
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
				$self->errorHandler->fatal("Couldn't connect to WebGUI database, and can't continue without it.");
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
    return $self->db if $self->var->isAdminOn;
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
        $self->config->getWebguiRoot,
        $self->config->getFilename,
        undef,
        undef,
        $self->getId,
    );
    return $newSession;
}


#-------------------------------------------------------------------

=head2 env ( )

Returns a WebGUI::Session::Env object.

=cut

sub env {
	my $self = shift;
	unless (exists $self->{_env}) {
		$self->{_env} = WebGUI::Session::Env->new;
	}
	return $self->{_env};
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
		$self->{_id} = WebGUI::Session::Id->new($self);
	}
	return $self->{_id};
}


#-------------------------------------------------------------------

=head2 log ( )

Returns a WebGUI::Session::ErrorHandler object, which is used for logging.

=cut

sub log {
	my $self = shift;
	unless (exists $self->{_errorHandler}) {
		$self->{_errorHandler}  = WebGUI::Session::ErrorHandler->new($self);
	}
	return $self->{_errorHandler};
}

#-------------------------------------------------------------------

=head2 open ( webguiRoot, configFile [, requestObject, serverObject, sessionId, noFuss ] )

Constructor. Opens a closed ( or new ) WebGUI session.

=head3 webguiRoot

The path to the WebGUI files.

=head3 configFile

The filename of the config file that WebGUI should operate from.

=head3 requestObject

The Apache request object (aka $r). If this session is being instanciated from the web, this is required.

=head3 serverObject

The Apache server object (Apache2::ServerUtil). If this session is being instanciated from the web, this is required.

=head3 sessionId

Optionally retrieve a specific session id. Normally this is set by a cookie in the user's browser.

=head3 noFuss

Uses simple session vars. See WebGUI::Session::Var::new() for more details.

=cut

sub open {
	my $class = shift;
	my $webguiRoot = shift;
	my $configFile = shift;
	my $request = shift;
	my $server = shift;
	my $config = WebGUI::Config->new($webguiRoot,$configFile);
	my $self = {_config=>$config, _server=>$server};
	bless $self , $class;
	$self->{_request} = WebGUI::Session::Request->new( r => $request, env => {}, session => $self ) if $request;
	my $sessionId = shift || $self->http->getCookies->{$config->getCookieName} || $self->id->generate;
	$sessionId = $self->id->generate unless $self->id->valid($sessionId);
	my $noFuss = shift;
	$self->{_var} = WebGUI::Session::Var->new($self,$sessionId, $noFuss);
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

=head2 os ( ) 

Returns a WebGUI::Session::Os object.

=cut

sub os {
	my $self = shift;
	unless (exists $self->{_os}) {
		$self->{_os} = WebGUI::Session::Os->new();
	}
	return $self->{_os};
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

Returns the Apache request (aka $r) object, or undef if it doesn't exist.

=cut

sub request {
	my $self = shift;
	return $self->{_request};
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

Returns the Apache server object (Apache2::ServerUtil), or undef if it doesn't exist.

=cut

sub server {
	my $self = shift;
	return $self->{_server};
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
   		$self->var->start($userId,$self->getId);
		if ($self->setting->get("passiveProfilingEnabled")) {
			$self->db->write("update passiveProfileLog set userId = ? where sessionId = ?",[$userId,$self->getId]);
		}	
		delete $self->{_stow};
		$self->{_user} = $option->{user} || WebGUI::User->new($self, $userId);
		$self->request->user($self->{_user}->username) if $self->request;
	} elsif (!exists $self->{_user}) {
		$self->{_user} = WebGUI::User->new($self, $self->var->get('userId'));
		$self->request->user($self->{_user}->username) if $self->request;
	} 
    return $self->{_user};
}


#-------------------------------------------------------------------

=head2 var ( )

Returns a reference to the WebGUI::Session::Var object.

=cut

sub var {
	my $self = shift;
	unless ($self->{_var}) {
		$self->{_var} = WebGUI::Session::Var->new($self);
	}
	return $self->{_var};
}

1;
