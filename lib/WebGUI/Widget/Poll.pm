package WebGUI::Widget::Poll;

our $namespace = "Poll";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _viewPoll {
        my (%poll, $i, $output, $widgetId);
	tie %poll, 'Tie::CPHash';
        $widgetId = shift;
        %poll = WebGUI::SQL->quickHash("select * from widget,Poll where widget.widgetId=Poll.widgetId and widget.widgetId='$widgetId'",$session{dbh});
        if (defined %poll) {
                if ($poll{displayTitle} == 1) {
                        $output = "<h1>".$poll{title}."</h1>";
                }
                if ($poll{description} ne "") {
                        $output .= $poll{description}.'<p>';
                }
		$output .= '<form method="post" action="'.$session{page}{url}.'">';
		$output .= WebGUI::Form::hidden('wid',$widgetId);
		$output .= WebGUI::Form::hidden('func','vote');
                $output .= '<span class="pollQuestion">'.$poll{question}.'</span><br>';
                for ($i=1; $i<=20; $i++) {
                        if ($poll{'a'.$i} =~ /\w/) {
                                $output .= WebGUI::Form::radio("answer",'a'.$i).' <span class="pollAnswer">'.$poll{'a'.$i}.'</span><br>';
                        }
                }
		$output .= '<br>'.WebGUI::Form::submit('Vote!');

		$output .= '</form>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub _viewResults {
        my (%poll, @data, $i, $output, $widgetId, $totalResponses);
	tie %poll, 'Tie::CPHash';
        $widgetId = shift;
        %poll = WebGUI::SQL->quickHash("select * from widget,Poll where widget.widgetId=Poll.widgetId and widget.widgetId='$widgetId'",$session{dbh});
        if (defined %poll) {
                if ($poll{displayTitle} == 1) {
                        $output = "<h1>".$poll{title}."</h1>";
                }
                if ($poll{description} ne "") {
                        $output .= $poll{description}.'<p>';
                }
		$output .= '<span class="pollQuestion">'.$poll{question}.'</span>';
		($totalResponses) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where widgetId=$widgetId",$session{dbh});
		if ($totalResponses < 1) {
			$totalResponses = 1;
		}
		for ($i=1; $i<=20; $i++) {
			if ($poll{'a'.$i} =~ /\w/) {
				$output .= '<span class="pollAnswer"><hr size=1>'.$poll{'a'.$i}.'<br></span>';
                		@data = WebGUI::SQL->quickArray("select count(*), answer from Poll_answer where answer='a$i' and widgetId=$widgetId group by answer",$session{dbh});
				$output .= '<table cellpadding=0 cellspacing=0 border=0><tr><td width="'.round($poll{graphWidth}*$data[0]/$totalResponses).'" class="pollColor"><img src="'.$session{setting}{lib}.'/spacer.gif" height="1" width="1"></td><td class="pollAnswer">&nbsp;&nbsp;'.round(100*$data[0]/$totalResponses).'%</td></tr></table>';
			}
                }
		$output .= '<span class="pollAnswer"><hr size=1><b>Total Votes:</b> '.$totalResponses.'</span>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from Poll_answer where widgetId=$_[0]",$_[1]);
        WebGUI::SQL->write("delete from Poll where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(250);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash, @array);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(251).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,'Poll').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(252).'</td><td>'.WebGUI::Form::checkbox("active",1,1).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = 1;
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(253).'</td><td>'.WebGUI::Form::selectList("voteGroup",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(254).'</td><td>'.WebGUI::Form::text("graphWidth",20,3,150).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(255).'</td><td>'.WebGUI::Form::text("question",50,255).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(256).'<span><br>'.WebGUI::International::get(257).'</span></td><td>'.WebGUI::Form::textArea("answers",'',50,8,0,'on').'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_addSave {
	my ($widgetId, @answer);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create();
		@answer = split("\n",$session{form}{answers});	
		WebGUI::SQL->write("insert into Poll values ($widgetId, '$session{form}{active}', '$session{form}{graphWidth}', '$session{form}{voteGroup}', ".quote($session{form}{question}).", ".quote($answer[0]).", ".quote($answer[1]).", ".quote($answer[2]).", ".quote($answer[3]).", ".quote($answer[4]).", ".quote($answer[5]).", ".quote($answer[6]).", ".quote($answer[7]).", ".quote($answer[8]).", ".quote($answer[9]).", ".quote($answer[10]).", ".quote($answer[11]).", ".quote($answer[12]).", ".quote($answer[13]).", ".quote($answer[14]).", ".quote($answer[15]).", ".quote($answer[16]).", ".quote($answer[17]).", ".quote($answer[18]).", ".quote($answer[19]).")",$session{dbh});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, %hash, @array);
	tie %hash, "Tie::IxHash";
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget,Poll where widget.widgetId=Poll.widgetId and widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(258).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,$data{processMacros}).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description},50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(252).'</td><td>'.WebGUI::Form::checkbox("active",1,$data{active}).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $array[0] = $data{voteGroup};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(253).'</td><td>'.WebGUI::Form::selectList("voteGroup",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(254).'</td><td>'.WebGUI::Form::text("graphWidth",20,3,$data{graphWidth}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(255).'</td><td>'.WebGUI::Form::text("question",50,255,$data{question}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(256).'<span><br>'.WebGUI::International::get(257).'</span></td><td>'.WebGUI::Form::textArea("answers",$data{a1}."\n".$data{a2}."\n".$data{a3}."\n".$data{a4}."\n".$data{a5}."\n".$data{a6}."\n".$data{a7}."\n".$data{a8}."\n".$data{a9}."\n".$data{a10}."\n".$data{a11}."\n".$data{a12}."\n".$data{a13}."\n".$data{a14}."\n".$data{a15}."\n".$data{a16}."\n".$data{a17}."\n".$data{a18}."\n".$data{a19}."\n".$data{a20}."\n",50,8,0,'on').'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).' &nbsp;&nbsp;&nbsp; <a href="'.$session{page}{url}.'?func=resetVotes&wid='.$session{form}{wid}.'">'.WebGUI::International::get(305).'</a></td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
	my (@answer);
        if (WebGUI::Privilege::canEditPage()) {
		update();
		@answer = split("\n",$session{form}{answers});	
		WebGUI::SQL->write("update Poll set active='$session{form}{active}', voteGroup='$session{form}{voteGroup}', graphWidth=$session{form}{graphWidth}, question=".quote($session{form}{question}).", a1=".quote($answer[0]).", a2=".quote($answer[1]).", a3=".quote($answer[2]).", a4=".quote($answer[3]).", a5=".quote($answer[4]).", a6=".quote($answer[5]).", a7=".quote($answer[6]).", a8=".quote($answer[7]).", a9=".quote($answer[8]).", a10=".quote($answer[9]).", a11=".quote($answer[10]).", a12=".quote($answer[11]).", a13=".quote($answer[12]).", a14=".quote($answer[13]).", a15=".quote($answer[14]).", a16=".quote($answer[15]).", a17=".quote($answer[16]).", a18=".quote($answer[17]).", a19=".quote($answer[18]).", a20=".quote($answer[19])." where widgetId=$session{form}{wid}",$session{dbh});
		return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_resetVotes {
	if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from Poll_answer where widgetId='$session{form}{wid}'",$session{dbh});
	}
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($hasVoted, %data, $output);
	tie %data, 'Tie::CPHash';
	%data = WebGUI::SQL->quickHash("select * from widget,Poll where widget.widgetId=Poll.widgetId and widget.widgetId='$_[0]'",$session{dbh});
	if ($data{active} eq "0") {
		$output = _viewResults($_[0]);
	} elsif (WebGUI::Privilege::isInGroup($data{voteGroup},$session{user}{userId})) {
		($hasVoted) = WebGUI::SQL->quickArray("select count(*) from Poll_answer where widgetId=$_[0] and ((userId=$session{user}{userId} and userId<>1) or (userId=1 and ipAddress='$session{env}{REMOTE_ADDR}'))",$session{dbh});
		if ($hasVoted) {
			$output = _viewResults($_[0]);
		} else {
			$output = _viewPoll($_[0]);
		}
	} else {
		$output = _viewResults($_[0]);
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_vote {
	my ($voteGroup);
	($voteGroup) = WebGUI::SQL->quickArray("select voteGroup from Poll where widgetId='$session{form}{wid}'",$session{dbh});
        if (WebGUI::Privilege::isInGroup($voteGroup,$session{user}{userId})) {
        	WebGUI::SQL->write("insert into Poll_answer values ($session{form}{wid}, '$session{form}{answer}', $session{user}{userId}, '$session{env}{REMOTE_ADDR}')",$session{dbh});
	}
	return "";
}






1;
