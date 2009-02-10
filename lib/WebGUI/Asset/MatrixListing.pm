package WebGUI::Asset::MatrixListing;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use Class::C3;
use base qw(WebGUI::AssetAspect::Comments WebGUI::Asset);
use WebGUI::Utility;



=head1 NAME

Package WebGUI::Asset::MatrixListing

=head1 DESCRIPTION

Describe your New Asset's functionality and features here.

=head1 SYNOPSIS

use WebGUI::Asset::MatrixListing;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 addRevision

   This method exists for demonstration purposes only.  The superclass
   handles revisions to MatrixListing Assets.

=cut

sub addRevision {
	my $self = shift;
	my $newSelf = $self->next::method(@_);
	return $newSelf;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for MatrixListing instances.  

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_MatrixListing");
	%properties = (
        screenshots => {
            tab             =>"properties",
            fieldType       =>"image",
            defaultValue    =>undef,
            maxAttachments  =>20,
            label           =>$i18n->get("screenshots label"),
            hoverHelp       =>$i18n->get("screenshots description")
            },
        description => {
            tab             =>"properties",
            fieldType       =>"HTMLArea",
            defaultValue    =>undef,
            label           =>$i18n->get("description label"),
            hoverHelp       =>$i18n->get("description description")
            },
        version => {
            tab             =>"properties",
            fieldType       =>"text",
            defaultValue    =>undef,
            label           =>$i18n->get("version label"),
            hoverHelp       =>$i18n->get("version description")
            },
        score => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        views => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        compares => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        clicks => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        viewsLastIp => {
            defaultValue    =>undef,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        comparesLastIp => {
            defaultValue    =>undef,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        clicksLastIp => {
            defaultValue    =>undef,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        maintainer => {
            tab             =>"properties",
            fieldType       =>"user",
            defaultValue    =>$session->user->userId,
            label           =>$i18n->get("maintainer label"),
            hoverHelp       =>$i18n->get("maintainer description")
            },
        manufacturerName => {
            tab             =>"properties",
            fieldType       =>"text",
            defaultValue    =>undef,
            label           =>$i18n->get("manufacturerName label"),
            hoverHelp       =>$i18n->get("manufacturerName description")
            },
        manufacturerURL => {
            tab             =>"properties",
            fieldType       =>"url",
            defaultValue    =>undef,
            label           =>$i18n->get("manufacturerURL label"),
            hoverHelp       =>$i18n->get("manufacturerURL description")
            },
        productURL => {
            tab             =>"properties",
            fieldType       =>"url",
            defaultValue    =>undef,
            label           =>$i18n->get("productURL label"),
            hoverHelp       =>$i18n->get("productURL description")
            },
        lastUpdated => {
            defaultValue    =>time(),
            autoGenerate    =>0,
            noFormPost      =>1,
            },
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'MatrixListing.gif',
		autoGenerateForms=>1,
		tableName=>'MatrixListing',
		className=>'WebGUI::Asset::MatrixListing',
		properties=>\%properties
	});
	return $class->next::method($session, $definition);
}


#-------------------------------------------------------------------

=head2 duplicate

   This method exists for demonstration purposes only.  The superclass
   handles duplicating MatrixListing Assets.  This method will be called 
   whenever a copy action is executed

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->next::method(@_);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId

Gets the WebGUI::VersionTag workflow to use to automatically commit MatrixListings. 
By specifying this method, you activate this feature.

=cut

sub getAutoCommitWorkflowId {
    my $self = shift;
    return $self->getParent->get("submissionApprovalWorkflowId");
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
    my $self        = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    my $matrixId    = $self->getParent->getId;
    my $i18n        = WebGUI::International->new($session, 'Asset_MatrixListing');
    my $func        = $session->form->process("func");

    my $form = WebGUI::HTMLForm->new($session);
    
    if ($func eq "add" || ( $func eq "editSave" && $session->form->process("assetId") eq "new")) {
        $form->hidden(
            -name           =>'assetId',
            -value          =>'new',
        );
        $form->hidden(
            -name           =>'class',
            -value          =>'WebGUI::Asset::MatrixListing',
        );
    }
    $form->hidden(
        -name           =>'func',
        -value          =>'editSave',
        );
    $form->text(
        -name           =>'title',
        -defaultValue   =>'Untitled',
        -label          =>$i18n->get("product name label"),
        -hoverHelp      =>$i18n->get('product name description'),
        -value          =>$self->getValue('title'),
        );
    $form->image(
        -name           =>'screenshots',
        -defaultValue   =>undef,
        -maxAttachments =>20,
        -label          =>$i18n->get("screenshots label"),
        -hoverHelp      =>$i18n->get("screenshots description"),,
        -value          =>$self->getValue('screenshots'),
        );
    $form->HTMLArea(
        -name           =>'description',
        -defaultValue   =>undef,
        -label          =>$i18n->get("description label"),
        -hoverHelp      =>$i18n->get("description description"),
        -value          =>$self->getValue('description'),
        );
    $form->text(        
        -name           =>'version',
        -defaultValue   =>undef,
        -label          =>$i18n->get("version label"),
        -hoverHelp      =>$i18n->get("version description"),
        -value          =>$self->getValue('version'),
        );
    $form->text(
        -name           =>'manufacturerName',
        -defaultValue   =>undef,
        -label          =>$i18n->get("manufacturerName label"),
        -hoverHelp      =>$i18n->get("manufacturerName description"),
        -value          =>$self->getValue('manufacturerName'),
        );
    $form->url(
        -name           =>'manufacturerURL',
        -defaultValue   =>undef,
        -label          =>$i18n->get("manufacturerURL label"),
        -hoverHelp      =>$i18n->get("manufacturerURL description"),
        -value          =>$self->getValue('manufacturerURL'),
        );
    $form->url(
        -name           =>'productURL',
        -defaultValue   =>undef,
        -label          =>$i18n->get("productURL label"),
        -hoverHelp      =>$i18n->get("productURL description"),
        -value          =>$self->getValue('productURL'),
        );

    foreach my $category (keys %{$self->getParent->getCategories}) {
        $form->raw('<tr><td colspan="2"><b>'.$category.'</b></td></tr>');
        my $attributes;
        if ($session->form->process('func') eq 'add'){
            $attributes = $db->read("select * from Matrix_attribute where category = ? and assetId = ?",
                [$category,$matrixId]);
        }
        else{
            $attributes = $db->read("select * from Matrix_attribute as a 
                left join MatrixListing_attribute as l on (a.attributeId = l.attributeId and l.matrixListingId = ?) 
                where category =? and a.assetId = ?",
                [$self->getId,$category,$matrixId]);
        }
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label}     = $attribute->{name};
            $attribute->{subtext}   = $attribute->{description};
            $attribute->{name}      = 'attribute_'.$attribute->{attributeId}; 
            $form->dynamicField(%{$attribute});           
        }
    }

    $form->submit();

    return $form;
}

#-------------------------------------------------------------------

=head2 hasRated ( )

Returns whether the user has already rated this listing or not.

=cut

sub hasRated {
    my $self    = shift;
    my $session = $self->session;

    my $hasRated = $self->session->db->quickScalar("select count(*) from MatrixListing_rating where
        ((userId=? and userId<>'1') or (userId='1' and ipAddress=?)) and listingId=?",
        [$session->user->userId,$session->env->get("HTTP_X_FORWARDED_FOR"),$self->getId]);
    return $hasRated;

}

#-------------------------------------------------------------------

=head2 incrementCounter ( counter )

Increments one of the Matrix Listing's counters.

=head3 counter

The name of the counter to increment this should be 'views', 'clicks' or 'compares').

=cut

sub incrementCounter {
    my $self    = shift;
    my $db      = $self->session->db;
    my $counter = shift;
    
    my $currentIp = $self->session->env->get("HTTP_X_FORWARDED_FOR");
    
    unless ($self->get($counter."LastIp") eq $currentIp) {
        $self->update({ 
            $counter."LastIp"   => $currentIp,
            $counter            => $self->get($counter)+1
        });
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->next::method;
	$indexer->setIsPublic(0);
    return undef;
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->next::method();
	my $template = WebGUI::Asset::Template->new($self->session, $self->getParent->get('detailTemplateId'));
    $template->prepare;
	$self->{_viewTemplate} = $template;
    return undef;
}


#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  

=cut

sub processPropertiesFromFormPost {
	my $self    = shift;
    my $session = $self->session;
    my $score   = 0;

	$self->next::method(@_);

    my $attributes = $session->db->read("select * from Matrix_attribute where assetId = ?",[$self->getParent->getId]);
    while (my $attribute = $attributes->hashRef) {
        my $name = 'attribute_'.$attribute->{attributeId};
        my $value;
        if ($attribute->{fieldType} eq 'MatrixCompare'){
            $value = $session->form->process($name);
            $score = $score + $value;
        }
        else{
            $value = $session->form->process($name,$attribute->{fieldType},$attribute->{defaultValue},$attribute);
        }
        $session->db->write("replace into MatrixListing_attribute (matrixId, matrixListingId, attributeId, value) 
            values (?, ?, ?, ?)",
            [$self->getParent->getId,$self->getId,$attribute->{attributeId},$value]);
    }
    $self->update({score => $score});    

    $self->requestAutoCommit;
    return undef;
}


#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a MatrixListing when the system
purges it's data.  

=cut

sub purge {
	my $self    = shift;
    my $db      = $self->session->db;

    $db->write("delete from MatrixListing_attribute     where matrixListingId=?",[$self->getId]);    
    $db->write("delete from MatrixListing_rating        where listingId=?"      ,[$self->getId]);
    $db->write("delete from MatrixListing_ratingSummary where listingId=?"      ,[$self->getId]);

	return $self->next::method;
}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

sub purgeRevision {
	my $self = shift;
	return $self->next::method;
}

#-------------------------------------------------------------------

=head2 setRatings ( ratings  )

Sets the ratings for a matrix listing

=head3 ratings

A hashref containing the ratings to set for this listing.

=cut

sub setRatings {
    my $self        = shift;
    my $ratings     = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    my $matrixId    = $self->getParent->getId;
    
    foreach my $category (keys %{$self->getParent->getCategories}) {
        if ($ratings->{$category}) {
            $db->write("insert into MatrixListing_rating 
                (userId, category, rating, timeStamp, listingId, ipAddress, assetId) values (?,?,?,?,?,?,?)",
                [$session->user->userId,$category,$ratings->{$category},$session->datetime->time(),$self->getId,
                $session->env->get("HTTP_X_FORWARDED_FOR"),$matrixId]);
        }
        my $sql     = "from MatrixListing_rating where listingId=? and category=?";
        my $sum     = $db->quickScalar("select sum(rating) $sql", [$self->getId,$category]);
        my $count   = $db->quickScalar("select count(*) $sql", [$self->getId,$category]);
        
        my $half    = round($count/2);
        my $mean    = $sum / ($count || 1);
        my $median  = $db->quickScalar("select rating $sql limit $half,$half",[$self->getId,$category]);
        
        $db->write("replace into MatrixListing_ratingSummary 
            (listingId, category, meanValue, medianValue, countValue, assetId) 
            values (?,?,?,?,?,?)",[$self->getId,$category,$mean,$median,$count,$matrixId]);
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 view ( hasRated )

Updates the score of a MatrixListing. 

=cut

sub updateScore {
    my $self = shift;
    my $score = $self->session->db->quickScalar("select sum(value) from MatrixListing_attribute 
            left join Matrix_attribute using(attributeId) 
            where matrixListingId = ? and fieldType = 'MatrixCompare'",[$self->getId]);
    $self->update({score => $score});
    return undef;
}

#-------------------------------------------------------------------

=head2 view ( hasRated )

method called by the container www_view method. 

=head3 hasRated

A boolean indicating if the user has rated this listing.

=head3 emailSent 

A boolean indicating if an email to the listing maintianer was sent.

=cut

sub view {
	my $self        = shift;
    my $hasRated    = shift || $self->hasRated;
    my $emailSent   = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    my $i18n        = WebGUI::International->new($self->session, "Asset_MatrixListing");
    my @categories  = keys %{$self->getParent->getCategories};
   
    # Increment views before getting template var hash so that the views tmpl_var has the incremented value. 
    $self->incrementCounter("views");

	my $var = $self->get;
    if ($emailSent){
    	$var->{emailSent}       = 1;
    }
    $var->{controls}            = $self->getToolbar;
    $var->{comments}            = $self->getFormattedComments();
    $var->{productName}         = $var->{title};
    $var->{lastUpdated_epoch}   = $self->get('lastUpdated');
    $var->{lastUpdated_date}    = $session->datetime->epochToHuman($self->get('lastUpdated'),"%z");

    $var->{manufacturerUrl_click}  = $self->getUrl("func=click;manufacturer=1");
    $var->{productUrl_click}       = $self->getUrl("func=click");

    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo/yahoo-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/dom/dom-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/event/event-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/connection/connection-min.js'),
        {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/get/get-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/element/element-beta-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datasource/datasource-min.js'),
    {type => 'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/datatable/datatable-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/button/button-min.js'),
    {type =>'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('wobject/Matrix/matrixListing.js'), {type =>
    'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'),
        {type =>'text/css', rel=>'stylesheet'});

    # Attributes

    foreach my $category (@categories) {
        my $attributes;
        my @attribute_loop;
        my $categoryLoopName = $session->url->urlize($category)."_loop";
        $attributes = $db->read("select * from Matrix_attribute as a
            left join MatrixListing_attribute as l on (a.attributeId = l.attributeId and l.matrixListingId = ?)
            where category =? and a.assetId = ?",
            [$self->getId,$category,$self->getParent->getId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label} = $attribute->{name};
            if ($attribute->{fieldType} eq 'MatrixCompare'){
                $attribute->{value} = WebGUI::Form::MatrixCompare->new($session,$attribute)->getValueAsHtml;
            }
            push(@attribute_loop,$attribute);
        }
        $var->{$categoryLoopName} = \@attribute_loop;
        push(@{$var->{category_loop}},{
            categoryLabel   => $category,
            attribute_loop  => \@attribute_loop,
        });
    }

    # Screenshots

    if ($var->{screenshots}) {
        my $file = WebGUI::Form::File->new($session,{ value=>$var->{screenshots} });
        my $storage = $file->getStorageLocation;
        my @files;
        @files = @{ $storage->getFiles } if (defined $storage);
        
        $var->{screenshots} = qq|
<script language="javascript">AC_FL_RunContent = 0;</script>
<script src="/extras/ukplayer/AC_RunActiveContent.js" language="javascript"></script>
<script language="javascript">
    if (AC_FL_RunContent == 0) {
        alert("This page requires AC_RunActiveContent.js.");
    } else {
        AC_FL_RunContent(
            'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0',
            'width', '400',
            'height', '300',
            'src', 'swc/assets',
            'quality', 'high',
            'pluginspage', 'http://www.macromedia.com/go/getflashplayer',
            'align', 'middle',
            'play', 'true',
            'loop', 'true',
            'scale', 'showall',
            'wmode', 'window',
            'devicefont', 'false',
            'id', 'slideShow',
            'bgcolor', '#ffffff',
            'name', 'coverflow',
            'menu', 'true',
            // note: the width & height in the flashVars below MUST match the width & height set above
            'flashVars',
'config=?func=getScreenshotsConfig&width=400&height=300&backgroundColor=0xCCCCCC&fontColor=&textBorderColor=&textBackgroundColor=&controlsColor=&controlsBorderColor=&controlsBackgroundColor=',
            'allowFullScreen', 'false',
            'allowScriptAccess','sameDomain',
            'movie', '/extras/ukplayer/slideShow',
            'salign', ''
            ); //end AC code
    }
</script>
<noscript>
    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="400"
height="300" id="swc/assets" align="middle">
    <param name="allowScriptAccess" value="sameDomain" />
    <param name="allowFullScreen" value="false" />
    <param name="flashVars" value="config=?func=getScreenshotsConfig" />
    <param name="movie" value="/extras/ukplayer/slideShow.swf" /><param name="quality" value="high" /><param
name="bgcolor" value="#ffffff" />   <embed src="/extras/ukplayer/slideShow.swf" quality="high" bgcolor="#ffffff"
width="400" height="300" name="swc/assets" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false"
flashvars="config=?func=getScreenshotsConfig" type="application/x-shockwave-flash"
pluginspage="http://www.macromedia.com/go/getflashplayer" />
    </object>
</noscript>
|;
    }

    # Rating form

    my %rating;
    tie %rating, 'Tie::IxHash';
    %rating = (
        1=>"1 - ".$i18n->get('worst label'),
                2=>2,
                3=>3,
                4=>4,
                5=>"5 - ".$i18n->get('respectable label'),
                6=>6,
                7=>7,
                8=>8,
                9=>9,
                10=>"10 - ".$i18n->get('best label')
        );
    my $ratingsTable = "<table class='ratingForm'><tbody>\n
        <tr><th></th><th>".$i18n->get('mean label')."</th>
        <th>".$i18n->get('median label')."</th>
        <th>".$i18n->get('count label')."</th></tr>\n";

    my $ratingForm = WebGUI::HTMLForm->new($session,
        -extras     =>'class="content"',
        -tableExtras=>'class="content"'
        );
    $ratingForm = WebGUI::HTMLForm->new($session,
        -extras     =>'class="ratingForm"',
        -tableExtras=>'class="ratingForm"'
        );
    $ratingForm->hidden(
        -name       =>"listingId",
        -value      =>$self->getId
        );
    $ratingForm->hidden(
        -name       =>"func",
        -value      =>"rate"
        );
    foreach my $category (@categories) {
        my ($mean,$median,$count) = $db->quickArray("select meanValue, medianValue, countValue 
            from MatrixListing_ratingSummary
            where listingId=? and category=?",[$self->getId,$category]);
        $ratingsTable .= '<tr><th>'.$category.'</th><td>'.$mean.'</td><td>'.$median.'</td><td>'.$count.'</td></tr>';
        $ratingForm->selectBox(
            -name   =>$category,
            -label  =>$category,
            -value  =>[5],
            -extras =>'class="ratingForm"',
            -options=>\%rating
            );
    }
    $ratingsTable .= '</tbody></table>';
    $ratingForm->submit(
        -extras =>'class="ratingForm"',
        -value  =>$i18n->get('rate submit label'),
        -label  =>'<a href="'.$self->getUrl("showRatings=1").'">'.$i18n->get('show ratings').'</a>'
        );
    if ($hasRated || $session->form->process('showRatings')) {
        $var->{ratings} = $ratingsTable;
    } else {
        $var->{ratings} = $ratingForm->print;
    }

    # Mail form

    my $mailForm = WebGUI::HTMLForm->new($session,
        -extras     =>'class="content"',
        -tableExtras=>'class="content"'
        );
    $mailForm->hidden(
        -name       =>"func",
        -value      =>"sendEmail"
        );
    $mailForm->captcha(
        -name       =>"verify"
        );
    $mailForm->email(
        -extras     =>'class="content"',
        -name       =>"from",
        -value      =>$session->user->profileField("email"),
        -label      =>$i18n->get('your email label'),
        );
    $mailForm->selectBox(
        -name       =>"subject",
        -extras     =>'class="content"',
        -options    =>{
            $i18n->get('report error label')      =>$i18n->get('report error label'),
            $i18n->get('general comment label')   =>$i18n->get('general comment label'),
            },
        -label      =>$i18n->get('request type label'),
        );
    $mailForm->textarea(
        -rows       =>4,
        -extras     =>'class="content"',
        -columns    =>35,
        -name       =>"body",
        -label      =>$i18n->get('comment label'),
        );
    $mailForm->submit(
        -extras     =>'class="content"',
        -value      =>$i18n->get('send button label'),
        );
    $var->{emailForm} = $mailForm->print;

	return $self->getParent->processStyle($self->processTemplate($var,undef, $self->{_viewTemplate}));
}


#-------------------------------------------------------------------

=head2 www_click ( )

Redirects to the manufacturerUrl or productUrl and increments clicks.

=cut

sub www_click {
    my $self    = shift;

    return $self->session->privilege->noAccess() unless $self->canView;

    my $session = $self->session;

    $self->incrementCounter('clicks');
    if ($session->form->process("manufacturer")) {
        $session->http->setRedirect( $self->get('manufacturerURL') );
    }
    else {
        $session->http->setRedirect( $self->get('productURL') );
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 www_deleteStickied  (  )

Sets the sort scratch variable.

=cut

sub www_deleteStickied {

    my $self = shift;
    
    return $self->session->privilege->noAccess() unless $self->canView;
    $self->getParent->www_deleteStickied();

    return undef;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page

=cut

sub www_edit {
    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->getParent->canAddMatrixListing();

    my $i18n = WebGUI::International->new($self->session, "Asset_MatrixListing");
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;

    my $var         = $self->get;
    my $matrix      = $self->getParent;
    $var->{form}    = $self->getEditForm->print;
        
    return $matrix->processStyle($self->processTemplate($var,$matrix->get("editListingTemplateId")));
}

#-------------------------------------------------------------------

=head2 www_getAttributes ( )

Gets a listings attributes grouped by category as json.

=cut

sub www_getAttributes {
    
    my $self    = shift;
    my $session = $self->session;
    my $db      = $session->db;

    return $session->privilege->noAccess() unless $self->canView;

    $session->http->setMimeType("application/json");

    my @results;
    my @categories  = keys %{$self->getParent->getCategories};
    foreach my $category (@categories) {
        push(@results,{label=>$category,fieldType=>'category'});
        my $attributes;
        my @attribute_loop;
        $attributes = $db->read("select * from Matrix_attribute as a
            left join MatrixListing_attribute as l on (a.attributeId = l.attributeId and l.matrixListingId = ?)
            where category =? and a.assetId = ?",
            [$self->getId,$category,$self->getParent->getId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label} = $attribute->{name};
            $attribute->{attributeId} =~ s/-/_____/g;
            if ($attribute->{fieldType} eq 'MatrixCompare'){
                $attribute->{compareColor} = $self->getParent->getCompareColor($attribute->{value});
                $attribute->{value} = WebGUI::Form::MatrixCompare->new($self->session,$attribute)->getValueAsHtml;
            }
            if($session->scratch->get('stickied_'.$attribute->{attributeId})){
                $attribute->{checked} = 'checked';
            }
            else{
                $attribute->{checked} = '';
            }
            push(@results,$attribute);
        }
    }
    my $jsonOutput;
    $jsonOutput->{ResultSet} = {Result=>\@results};

    return JSON->new->encode($jsonOutput);
}

#-------------------------------------------------------------------

=head2 www_getScreenshots ( )

Returns the screenshots as xml.

=cut

sub www_getScreenshots {
    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->canView;

    $self->session->http->setMimeType('text/xml');

    my $xml = qq |<?xml version="1.0" encoding="UTF-8"?>
<content>
    <slides>
|;

    if ( $self->get('screenshots') ) {
        my $fileObject = WebGUI::Form::File->new($self->session,{ value=>$self->get('screenshots') });
        my $storage = $fileObject->getStorageLocation;
        my $path = $storage->getPath;
        my @files;
        @files = @{ $storage->getFiles } if (defined $storage);
        foreach my $file (@files) {
        unless ($file =~ m/^thumb-/){
            my $thumb = 'thumb-'.$file;
            $xml .= "
        <slide>
            <width>400</width>
            <height>300</height>
            <title><![CDATA[<b>Slide</b> One]]></title>
            <description><![CDATA[ Screenshots ]]></description>
            <image_source>".$storage->getUrl($file)."</image_source>
            <duration>5</duration>
            <thumb_source>".$storage->getUrl($thumb)."</thumb_source>
        </slide>            
            ";
            }
        }
    }

    $xml .= qq |
    </slides>
</content>
|;

    return $xml;
}

#-------------------------------------------------------------------

=head2 www_getScreenshotsConfig ( )

Returns the xml config file for the ukplayer that displays the screenshots.

=cut

sub www_getScreenshotsConfig {
    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->canView;

    $self->session->http->setMimeType('text/xml');

    my $xml = qq|<?xml version="1.0" encoding="UTF-8"?>
<config>

    <content_url>?func=getScreenshots</content_url>
    
    <width>400</width><!-- this value is overwritten by the flashVars but the tag needs to be here (and it is
useful for offline testing) -->
    <height>300</height><!-- this value is overwritten by the flashVars but the tag needs to be here (and it is
useful for offline testing) -->
    <background_color>0xDDDDEE</background_color>
    <default_duration>20</default_duration>
    <default_slidewidth>100</default_slidewidth>
    <default_slideheight>100</default_slideheight>
    
    <font>Verdana</font>
    <font_size>12</font_size>
    <font_color>0xCCCCCC</font_color>
    <text_border_color>0xCCCCCC</text_border_color>
    <text_bg_color>0x000000</text_bg_color>
    <text_autohide>true</text_autohide>
    
    <controls_color>0xCCCCCC</controls_color>
    <controls_border_color>0xCCCCCC</controls_border_color>
    <controls_bg_color>0x000000</controls_bg_color>
    <controls_autohide>false</controls_autohide>
    
    <thumbnail_width>48</thumbnail_width>
    <thumbnail_height>36</thumbnail_height>
    <thumbnail_border_color>0x000000</thumbnail_border_color>
    <menu_autohide>true</menu_autohide>
    <menu_dead_zone_width>100</menu_dead_zone_width>
    <menu_gaps>5</menu_gaps>
    
    <mute_at_start>false</mute_at_start>
    <autostart>true</autostart>
    <autopause>false</autopause>
    <loop>false</loop>
    <error_message_content><![CDATA[XML not found: ]]></error_message_content>
    <error_message_image><![CDATA[Image not found]]></error_message_image>
    
</config>
|;

    return $xml;
}

#-------------------------------------------------------------------

=head2 www_rate ( )

Saves a rating of a matrix listing and returns the listing view.

=cut

sub www_rate {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->noAccess() unless $self->canView;
    
    my $hasRated    = $self->hasRated;
    my $sameRating  = 1;
    my $first       = 1;
    my $lastRating;
    
    foreach my $category (keys %{$self->getParent->getCategories}) {
        if ($first) {
            $first=0;
        } else {
            if ($lastRating != $form->process($category)) {
                $sameRating = 0;
            }
        }
        $lastRating = $form->process($category);
    }
    
    # Throw out ratings that are all the same number, or if the user rates twice.
    unless ($hasRated || $sameRating) {
        $self->setRatings($self->session->form->paramsHashRef);
    }

    $self->prepareView;
    return $self->view;
}

#-------------------------------------------------------------------

=head2 www_sendEmail ( )

Sends an email to the maintainer of this matrix listing and returns www_view

=cut

sub www_sendEmail {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->noAccess() unless $self->canView;
    
    if ($form->process("verify","captcha")) {
        if ($form->process("body") ne "") {
            my $user = WebGUI::User->new($self->session, $self->get('maintainerId'));
            my $mail = WebGUI::Mail::Send->create($self->session,{
                        to      =>$user->profileField("email"),
                        subject =>$self->get('productName')." - ".$form->process("subject"),
                        from=>$form->process("from")
                });
            $mail->addText($form->process("body"));
            $mail->addFooter;
            $mail->queue;
        }
    }

    $self->prepareView;
    return $self->view(0,1);
}
#-------------------------------------------------------------------

=head2 www_setStickied  (  )

Sets the sort scratch variable.

=cut

sub www_setStickied {

    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->canView;
    $self->getParent->www_setStickied();

    return undef;
}
#-------------------------------------------------------------------

=head2 www_view ( )

Web facing method which is the default view page.  This method does a 
302 redirect to the "showPage" file in the storage location.

=cut

sub www_view {
	my $self = shift;

	return $self->session->privilege->noAccess() unless $self->canView;

    $self->prepareView;
	return $self->view;
}


1;

#vim:ft=perl
