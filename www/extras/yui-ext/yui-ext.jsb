<?xml version="1.0" encoding="utf-8"?>
<project path="" name="YUI Extensions" author="Jack Slocum" version=".32" copyright="$projectName&#xD;&#xA;Copyright(c) 2006, $author.&#xD;&#xA;&#xD;&#xA;This code is licensed under BSD license. Use it as you wish, &#xD;&#xA;but keep this copyright intact.&#xD;&#xA;&#xD;&#xA;http://www.opensource.org/licenses/bsd-license.php" output="C:\apache\htdocs\blog\javascript\build\" source="true" source-dir="$output\source" minify="False" min-dir="$output\build" doc="True" doc-dir="$output\docs">
  <directory name="" />
  <file name="anim\Actor.js" path="anim" />
  <file name="anim\Animator.js" path="anim" />
  <file name="data\AbstractDataModel.js" path="data" />
  <file name="data\DefaultDataModel.js" path="data" />
  <file name="data\JSONDataModel.js" path="data" />
  <file name="data\LoadableDataModel.js" path="data" />
  <file name="data\XMLDataModel.js" path="data" />
  <file name="grid\editor\CellEditor.js" path="grid\editor" />
  <file name="grid\editor\CheckboxEditor.js" path="grid\editor" />
  <file name="grid\editor\DateEditor.js" path="grid\editor" />
  <file name="grid\editor\NumberEditor.js" path="grid\editor" />
  <file name="grid\editor\SelectEditor.js" path="grid\editor" />
  <file name="grid\editor\TextEditor.js" path="grid\editor" />
  <file name="grid\AbstractColumnModel.js" path="grid" />
  <file name="grid\DefaultColumnModel.js" path="grid" />
  <file name="grid\EditorGrid.js" path="grid" />
  <file name="grid\EditorSelectionModel.js" path="grid" />
  <file name="grid\Grid.js" path="grid" />
  <file name="grid\GridDD.js" path="grid" />
  <file name="grid\GridView.js" path="grid" />
  <file name="grid\PagedGridView.js" path="grid" />
  <file name="grid\SelectionModel.js" path="grid" />
  <file name="widgets\DatePicker.js" path="widgets" />
  <file name="widgets\SplitBar.js" path="widgets" />
  <file name="widgets\TabPanel.js" path="widgets" />
  <file name="Element.js" path="" />
  <file name="EventManager.js" path="" />
  <file name="UpdateManager.js" path="" />
  <file name="yutil.js" path="" />
  <target name="Core" file="$output\yui-ext-core.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="yutil.js" />
    <include name="Element.js" />
    <include name="EventManager.js" />
    <include name="UpdateManager.js" />
  </target>
  <target name="Animator Lib" file="$output\animator-lib.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="anim\Actor.js" />
    <include name="anim\Animator.js" />
  </target>
  <target name="Basic Grid w/ Paging" file="$output\basic-grid-lib.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="grid\Grid.js" />
    <include name="grid\GridDD.js" />
    <include name="widgets\SplitBar.js" />
    <include name="widgets\Toolbar.js" />
    <include name="grid\GridView.js" />
    <include name="grid\PagedGridView.js" />
    <include name="grid\AbstractColumnModel.js" />
    <include name="grid\DefaultColumnModel.js" />
    <include name="data\AbstractDataModel.js" />
    <include name="data\DefaultDataModel.js" />
    <include name="data\LoadableDataModel.js" />
    <include name="data\XMLDataModel.js" />
    <include name="data\JSONDataModel.js" />
    <include name="grid\SelectionModel.js" />
  </target>
  <target name="Editor Grid" file="$output\editor-grid-lib.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="grid\Grid.js" />
    <include name="grid\GridDD.js" />
    <include name="widgets\SplitBar.js" />
    <include name="grid\GridView.js" />
    <include name="widgets\Toolbar.js" />
    <include name="grid\PagedGridView.js" />
    <include name="grid\EditorGrid.js" />
    <include name="grid\AbstractColumnModel.js" />
    <include name="grid\DefaultColumnModel.js" />
    <include name="data\AbstractDataModel.js" />
    <include name="data\DefaultDataModel.js" />
    <include name="data\LoadableDataModel.js" />
    <include name="data\XMLDataModel.js" />
    <include name="data\JSONDataModel.js" />
    <include name="grid\SelectionModel.js" />
    <include name="grid\EditorSelectionModel.js" />
    <include name="grid\editor\CellEditor.js" />
    <include name="grid\editor\CheckboxEditor.js" />
    <include name="grid\editor\DateEditor.js" />
    <include name="grid\editor\NumberEditor.js" />
    <include name="widgets\DatePicker.js" />
    <include name="grid\editor\SelectEditor.js" />
    <include name="grid\editor\TextEditor.js" />
  </target>
  <target name="Tabs Only" file="$output\tabs-lib.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="widgets\TabPanel.js" />
  </target>
  <target name="SplitBar Only" file="$output\splitbar-lib.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="widgets\SplitBar.js" />
  </target>
  <target name="Everything" file="$output\yui-ext.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="yutil.js" />
    <include name="Element.js" />
    <include name="EventManager.js" />
    <include name="UpdateManager.js" />
    <include name="widgets\TabPanel.js" />
    <include name="anim\Animator.js" />
    <include name="anim\Actor.js" />
    <include name="widgets\Toolbar.js" />
    <include name="widgets\SplitBar.js" />
    <include name="grid\Grid.js" />
    <include name="grid\GridDD.js" />
    <include name="grid\GridView.js" />
    <include name="grid\PagedGridView.js" />
    <include name="grid\EditorGrid.js" />
    <include name="grid\AbstractColumnModel.js" />
    <include name="grid\DefaultColumnModel.js" />
    <include name="data\AbstractDataModel.js" />
    <include name="data\DefaultDataModel.js" />
    <include name="data\LoadableDataModel.js" />
    <include name="data\XMLDataModel.js" />
    <include name="data\JSONDataModel.js" />
    <include name="grid\SelectionModel.js" />
    <include name="grid\EditorSelectionModel.js" />
    <include name="grid\editor\CellEditor.js" />
    <include name="grid\editor\CheckboxEditor.js" />
    <include name="grid\editor\DateEditor.js" />
    <include name="grid\editor\NumberEditor.js" />
    <include name="widgets\DatePicker.js" />
    <include name="grid\editor\SelectEditor.js" />
    <include name="grid\editor\TextEditor.js" />
  </target>
  <target name="Local Dev Output" file="C:\apache\htdocs\build\yui-ext.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="yutil.js" />
    <include name="Element.js" />
    <include name="EventManager.js" />
    <include name="UpdateManager.js" />
    <include name="widgets\Toolbar.js" />
    <include name="widgets\TabPanel.js" />
    <include name="anim\Animator.js" />
    <include name="anim\Actor.js" />
    <include name="widgets\SplitBar.js" />
    <include name="grid\Grid.js" />
    <include name="grid\GridDD.js" />
    <include name="grid\GridView.js" />
    <include name="grid\PagedGridView.js" />
    <include name="grid\EditorGrid.js" />
    <include name="grid\AbstractColumnModel.js" />
    <include name="grid\DefaultColumnModel.js" />
    <include name="data\AbstractDataModel.js" />
    <include name="data\DefaultDataModel.js" />
    <include name="data\LoadableDataModel.js" />
    <include name="data\XMLDataModel.js" />
    <include name="data\JSONDataModel.js" />
    <include name="grid\SelectionModel.js" />
    <include name="grid\EditorSelectionModel.js" />
    <include name="grid\editor\CellEditor.js" />
    <include name="grid\editor\CheckboxEditor.js" />
    <include name="grid\editor\DateEditor.js" />
    <include name="grid\editor\NumberEditor.js" />
    <include name="widgets\DatePicker.js" />
    <include name="grid\editor\SelectEditor.js" />
    <include name="grid\editor\TextEditor.js" />
  </target>
  <file name="widgets\Toolbar.js" path="widgets" />
  <target name="Local Dev Output 32" file="C:\apache\htdocs\build\yui-ext_32.js" shorthand="False" shorthand-list="YAHOO.util.Dom.setStyle&#xD;&#xA;YAHOO.util.Dom.getStyle&#xD;&#xA;YAHOO.util.Dom.getRegion&#xD;&#xA;YAHOO.util.Dom.getViewportHeight&#xD;&#xA;YAHOO.util.Dom.getViewportWidth&#xD;&#xA;YAHOO.util.Dom.get&#xD;&#xA;YAHOO.util.Dom.getXY&#xD;&#xA;YAHOO.util.Dom.setXY&#xD;&#xA;YAHOO.util.CustomEvent&#xD;&#xA;YAHOO.util.Event.addListener&#xD;&#xA;YAHOO.util.Event.getEvent&#xD;&#xA;YAHOO.util.Event.getTarget&#xD;&#xA;YAHOO.util.Event.preventDefault&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Event.stopPropagation&#xD;&#xA;YAHOO.util.Event.stopEvent&#xD;&#xA;YAHOO.util.Anim&#xD;&#xA;YAHOO.util.Motion&#xD;&#xA;YAHOO.util.Connect.asyncRequest&#xD;&#xA;YAHOO.util.Connect.setForm&#xD;&#xA;YAHOO.util.Dom&#xD;&#xA;YAHOO.util.Event">
    <include name="yutil.js" />
    <include name="Element.js" />
    <include name="EventManager.js" />
    <include name="UpdateManager.js" />
    <include name="widgets\Toolbar.js" />
    <include name="widgets\TabPanel.js" />
    <include name="anim\Animator.js" />
    <include name="anim\Actor.js" />
    <include name="widgets\SplitBar.js" />
    <include name="grid\Grid.js" />
    <include name="grid\GridDD.js" />
    <include name="grid\GridView.js" />
    <include name="grid\PagedGridView.js" />
    <include name="grid\EditorGrid.js" />
    <include name="grid\AbstractColumnModel.js" />
    <include name="grid\DefaultColumnModel.js" />
    <include name="data\AbstractDataModel.js" />
    <include name="data\DefaultDataModel.js" />
    <include name="data\LoadableDataModel.js" />
    <include name="data\XMLDataModel.js" />
    <include name="data\JSONDataModel.js" />
    <include name="grid\SelectionModel.js" />
    <include name="grid\EditorSelectionModel.js" />
    <include name="grid\editor\CellEditor.js" />
    <include name="grid\editor\CheckboxEditor.js" />
    <include name="grid\editor\DateEditor.js" />
    <include name="grid\editor\NumberEditor.js" />
    <include name="widgets\DatePicker.js" />
    <include name="grid\editor\SelectEditor.js" />
    <include name="grid\editor\TextEditor.js" />
  </target>
</project>