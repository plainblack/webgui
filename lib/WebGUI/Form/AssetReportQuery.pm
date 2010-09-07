package WebGUI::Form::AssetReportQuery;

use strict;
use base 'WebGUI::Form::Control';
use JSON;
use WebGUI::International;

=head1 NAME

WebGUI::Form::AssetReportQuery -- Builds a form to collect query information used by Asset Report

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut


#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "MEDIUMTEXT".

=cut 

sub getDatabaseFieldType {
    return "MEDIUMTEXT";
}

#----------------------------------------------------------------------------

=head2 getAnyList

Get the operator list.

=cut

sub getAnyList {
    my $self        = shift;
    my $i18n        = $self->i18n;
    
    tie my %options, 'Tie::IxHash', (
        'or'  => $i18n->get("any option"),
        'and' => $i18n->get("all option"),
    );

    return \%options;
}

#----------------------------------------------------------------------------

=head2 getDirs

Get the direction list.

=cut

sub getDirs {
    my $self        = shift;
    my $i18n        = $self->i18n;
    
    tie my %options, 'Tie::IxHash', (
        'asc'  => $i18n->get("ascending option"),
        'desc' => $i18n->get("descending option"),
    );

    return \%options;
}


#----------------------------------------------------------------------------

=head2 getOps

Get the operator list.

=cut

sub getOps {
    my $self        = shift;
    
    tie my %options, 'Tie::IxHash', (
        '='             => '=',
        '<>'            => '<>',
        '>'             => '>',
        '>='            => '>=',
        '<'             => '<',
        '<='            => '<=',
        'LIKE'          => 'LIKE',
        'NOT LIKE'      => 'NOT LIKE',
        'IS NULL'       => 'IS NULL',
        'IS NOT NULL'   => 'IS NOT NULL',
    );

    return \%options;
}

#----------------------------------------------------------------------------

=head2 getValue ()

Get the value of the form

=cut

sub getValue {
    my $self       = shift;
    my $session    = $self->session;
    my $form       = $session->form;

    my $propCount  = $form->process("propCount","hidden");
    my $orderCount = $form->process("orderCount","hidden");

    if($propCount) {
        my $where      = {};
        my $whereCount = 1;
        for(my $i = 0; $i < $propCount; $i++ ) {
            my $propSelect = $form->process("propSelect_".$i,"selectBox");
            if($propSelect ne "") {
                my $opSelect = $form->process("opSelect_".$i,"selectBox");
                my $valText  = $form->process("valText_".$i,"text");
                $where->{$whereCount} = {
                    propSelect => $propSelect,
                    opSelect   => $opSelect,
                    valText    => $valText,
                };
                $whereCount++;
            }
        }

        my $orderBy      = {};
        my $orderByCount = 1;
        for(my $i = 0; $i < $orderCount; $i++ ) {
            my $orderSelect = $form->process("orderSelect_".$i,"selectBox");
            if($orderSelect ne "") {
                my $dirSelect = $form->process("dirSelect_".$i,"selectBox");
                $orderBy->{$orderByCount} = {
                    "orderSelect" => $orderSelect,
                    "dirSelect"   => $dirSelect,
                };
                $orderByCount++;
            }        
        }

        my $jsonHash    = {
            isNew       => "false",
            className   => $form->process("className","selectBox"),
            startNode   => $form->process("startNode","asset"),
            anySelect   => $form->process("anySelect","selectBox"),
            where       => $where,
            whereCount  => $whereCount,
            order       => $orderBy,
            orderCount  => $orderByCount,
            limit       => $form->process("limit","integer"),
        };

        my $jsonStr     = JSON->new->canonical->encode($jsonHash);

        #Set the value in the form
        $self->set('value',$jsonStr);
    }

    return $self->get('value') || $self->get('defaultValue');
}

#-------------------------------------------------------------------

=head2 i18n

Returns the i18n object for the form

=cut

sub i18n {
   my $self    = shift;
   my $session = $self->session;
   
   unless ($self->{_i18n}) {
      $self->{_i18n} 
          = WebGUI::International->new($session,'Form_AssetReportQuery');
   }
   
   return $self->{_i18n};
}
#----------------------------------------------------------------------------

=head2 toHtml

Render the form control.

=cut

sub toHtml {
    my $self    = shift;
    my $session = $self->session;
    my $db      = $session->db;
    my $style   = $session->style;
    my $i18n    = $self->i18n;

    #Build a JSON Array of all the possible classes and their fields
    my $json    = {};
    #Get all of the classes being used in the WebGUI instance
    my $classes = $db->buildArrayRef(q{
        SELECT
            distinct className
        FROM
            asset
        ORDER BY
            className
    });

    #Hard code these for now
    my %asset = (
        "asset.creationDate"   => $i18n->get("creationDate (asset)"),
        "asset.createdBy"      => $i18n->get("createdBy (asset)"),
        "asset.stateChanged"   => $i18n->get("stateChanged (asset)"),
        "asset.stateChangedBy" => $i18n->get("stateChangedBy (asset)"),
        "asset.isLockedBy"     => $i18n->get("isLockedBy (asset)"),
    );

    #Get the fields from the definition of each class
    foreach my $class (@{$classes}) {
        my $definitions = $class->definition($session);
        tie my %fields, "Tie::IxHash", ();
        foreach my $definition (@{$definitions}) {
            my $properties  = $definition->{properties};
            my $tableName   = $definition->{tableName};
            foreach my $property (keys %{$properties}) {
                my $key = $tableName.".".$property;
                $fields{$key} = qq{$property ($tableName)};
            }
        }

        %fields = (%asset,%fields);
        %fields =
            map { @$_ }
            sort { $a->[1] cmp $b->[1] }
            map { [ $_, $fields{$_} ] }
            keys %fields;

        $json->{$class} = \%fields;
    }

    #Encode the JSON and add it to the end of the body
    my $first_row_error_msg = $i18n->get("first_row_error_msg");
    my $jsonStr             = JSON->new->encode($json);
    $style->setRawHeadTags(qq|<script type="text/javascript">var classValues = $jsonStr; </script>|);
    my $jsonData            = $self->get("value") || q|{ "isNew" : "true" }|;
    $style->setRawHeadTags(qq|<script type="text/javascript">var dataValues  = $jsonData; var first_row_error_msg = '$first_row_error_msg';</script>|);
    $session->style->setScript($session->url->extras("yui-webgui/build/form/assetReportQuery.js"),{ type=>"text/javascript" });    

    #Decode JSON data for filling in some of the fields
    my $jsonDataHash = JSON->new->decode($jsonData);
    
    #Class select list
    my $classSelect    = WebGUI::Form::selectBox($session,{
        name           =>"className",
        value          => "",
        options        => {},
        extras         => q{onchange="loadClassName(this.value);"},
    });

    #Start Node
    my $startNode      = WebGUI::Form::asset($session,{
        name           =>"startNode",
        value          => $jsonDataHash->{startNode},
    });

    #Any Select
    my $anySelect      = WebGUI::Form::selectBox($session, {
        name           => "anySelect",
        value          => $jsonDataHash->{anySelect},
        options        => $self->getAnyList,
    });

    #Property Select
    my $propSelect     = WebGUI::Form::selectBox($session,{
        name           => "propSelect",
        value          => "",
        options        => { ""=>$i18n->get("choose one option") },
    });

    #Op Select
    my $opSelect       = WebGUI::Form::selectBox( $session, {
        name           => "opSelect",
        value          => "",
        options        => $self->getOps,
    });

    #Value Test
    my $valText        = WebGUI::Form::text($session,{
        name           => "valText"
    });

    #Delete Button
    my $deleteButton   = WebGUI::Form::button($session,{
        value          => "-",
        extras         => q{id="deleteButton_formId"}
    });

    #Add Button
    my $addButton      = WebGUI::Form::button($session,{
        value          => "+",
        extras         => q{ onclick="addRow(document.getElementById('row_1'),document.getElementById('whereBody'),'propCount_id');" },
    });

    #Order Select
    my $orderSelect    = WebGUI::Form::selectBox($session,{
        name           => "orderSelect",
        value          => "",
        options        => { ""=>$i18n->get("choose one option") },
    });

    #Dir Select
    my $dirSelect      = WebGUI::Form::selectBox($session, {
        name           => "dirSelect",
        value          => "",
        options        => $self->getDirs,
    });

    #Delete Button
    my $orderDelButton = WebGUI::Form::button($session,{
        value          => "-",
        extras         => q{id="orderDelButton_formId"}
    });

    #Add Button
    my $orderAddButton = WebGUI::Form::button($session,{
        value          => "+",
        extras         => q{ onclick="addRow(document.getElementById('order_1'),document.getElementById('orderBody'),'orderCount_id');" },
    });

    #Prop Count
    my $propCount     = WebGUI::Form::hidden($session, {
        name           => "propCount",
        value          => 1,
        extras         => q{id="propCount_id"},
    });

    #Order Count
    my $orderCount     = WebGUI::Form::hidden($session, {
        name           => "orderCount",
        value          => 1,
        extras         => q{id="orderCount_id"},
    });

    #Limit
    my $limit          = WebGUI::Form::integer($session,{
        name           => "limit",
        value          => $jsonDataHash->{limit},
    });


    my $classSelectLabel = $i18n->get("class select label");
    my $startNodeLabel   = $i18n->get("start node label");
    my $anySelectLabel   = sprintf($i18n->get("any select label"), $anySelect);
    my $orderByLabel     = $i18n->get("order by label");
    my $limitLabel       = $i18n->get("limit label");
    my $limitSubText     = $i18n->get("limit subtext");

    #Choose a class
    my $output = qq{
        $propCount
        $orderCount
        <table>
            <thead>
                <tr><th>$classSelectLabel</th></tr>
            </thead>
            <tbody>
                <tr><td>$classSelect</td></tr>
            </tbody>
        </table>
        <table>
            <thead>
                <tr><th>$startNodeLabel</th></tr>
            </thead>
            <tbody>
                <tr><td>$startNode</td></tr>
            </tbody>
        </table>
        <table>
            <thead>
                <tr><th>$anySelectLabel</th><tr>
            </thead>
        </table>
        <table>
            <tbody id="whereBody">
                <tr>
                    <td>$propSelect</td>
                    <td>$opSelect</td>
                    <td>$valText</td>
                    <td>$deleteButton</td>
                    <td>$addButton</td>
                </tr>
            </tbody>
        </table>
        <table>
            <thead>
                <tr><th colspan="4">$orderByLabel</th></tr>
            </thead>
            <tbody id="orderBody">
                <tr>
                    <td>$orderSelect</td>
                    <td>$dirSelect</td>
                    <td>$orderDelButton</td>
                    <td>$orderAddButton</td>
                </tr>
            </tbody>
        </table>
        <table>
            <thead>
                <tr><th>$limitLabel</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>$limit <span style="font-size:10px">($limitSubText)</span></td>
                </tr>
            </tbody>
        </table>
    };

    return $output;
}

1;
