//----------------------------------------------------------------------------------------------------
//	RichTextEditor.as
//----------------------------------------------------------------------------------------------------
package As
{
import fl.controls.ColorPicker;
import flash.display.MovieClip;
import flash.events.*;
import flash.text.*;

//----------------------------------------------------------------------------------------------------
//	class defintion
//----------------------------------------------------------------------------------------------------
public class RichTextEditor extends MovieClip
{
//private var format1:TextFormat = new TextFormat();
//----------------------------------------------------------------------------------------------------
//	constants
//----------------------------------------------------------------------------------------------------
private const kFontSize_StartRange : int = 14;
private const kFontSize_EndRange : int = 20;

//----------------------------------------------------------------------------------------------------
//	member data
//----------------------------------------------------------------------------------------------------
private var xTextFormat : TextFormat;
private var xList : Array = new Array();
private var xLineList : Array = new Array();
private var xColorPickerOpen : Boolean;

//----------------------------------------------------------------------------------------------------
//	constructor
//----------------------------------------------------------------------------------------------------
public function
RichTextEditor(
) : void
{
	//trace("*** cRichTextEditor();");

	if (tfText) init();
	/*format1.bold = format1.italic = format1.underline = false;
	Bold_btn.addEventListener(MouseEvent.CLICK, changeBold);
	Italic_btn.addEventListener(MouseEvent.CLICK, changeItalic);
	Underline_btn.addEventListener(MouseEvent.CLICK, changeUnderline);*/
}

public function init():void {
	var i : int;
	var vList : Array;
	
	addEventListener(Event.CHANGE, xfOnEvent, false, 0, true);
	addEventListener(MouseEvent.MOUSE_DOWN, xfOnEvent, false, 0, true);
	addEventListener(MouseEvent.CLICK, xfOnEvent, false, 0, true);
	if (stage != null)
		stage.addEventListener(MouseEvent.MOUSE_UP, xfOnEvent, false, 0, true);	
	addEventListener(MouseEvent.MOUSE_MOVE, xfOnEvent, false, 0, true);
	addEventListener(KeyboardEvent.KEY_UP, xfOnEvent, false, 0, true);
	cxOption_Size.addEventListener(Event.CHANGE, xfOnEvent, false, 0, true);
	cxOption_Font.addEventListener(Event.CHANGE, xfOnEvent, false, 0, true);
	
//	tfText.htmlText = '<P ALIGN="RIGHT"><FONT FACE="Arial" SIZE="14" COLOR="#000000" LETTERSPACING="0" KERNING="1">abc<U>d ef</U>ghi</FONT></P><P ALIGN="LEFT"><FONT FACE="Arial" SIZE="14" COLOR="#000000" LETTERSPACING="0" KERNING="1">z<FONT COLOR="#6666FF"><B>xcvbn</B></FONT></FONT></P>'

	vList = Font.enumerateFonts(true);
	vList.sort();
	for (i = 0; i < vList.length; i++) 
		cxOption_Font.addItem( { label: vList[i].fontName, data: vList[i].fontName } );
	for (i = kFontSize_StartRange; i < kFontSize_EndRange + 1; i++)
		cxOption_Size.addItem( { label: i, data: i } );	
	tfText.embedFonts = false;	
	tfText.useRichTextClipboard = true;
	if (stage != null)
		stage.focus = tfText;
	tfText.setSelection(tfText.length, tfText.length);
	fSetUI(tfText.getTextFormat(tfText.length - 1, tfText.length));
}

public function set SetTfText(value:TextField):void 
{
	tfText = value;
	tfText.autoSize = TextFieldAutoSize.LEFT;
	//tfText.wordWrap = true;
	tfText.addEventListener(Event.CHANGE, checkWidth);
	//tfText.addEventListener(TextEvent.TEXT_INPUT, checkWidth);
	init();
	tfText.text = "";
}

private function checkWidth(e:Event):void 
//private function checkWidth(e:TextEvent):void 
{	trace(tfText.width , tfText.textWidth,tfText.length, tfText.text.charAt(tfText.length-1));
	//tfText.width = tfText.textWidth + tfText.textWidth / 2;	trace(tfText.width , tfText.textWidth);
	//tfText.appendText("\n");
	 var ss:String = "\n" + tfText.text.charAt(tfText.length-1);
	//在指定位置插入换行
	if(tfText.length>1)tfText.replaceText(tfText.length-1,tfText.length,ss);
	//if(tfText.length>0)tfText.replaceText(tfText.length, tfText.length, "\n");
}

/*private function changeBold(e:MouseEvent):void 
{
	format1.bold = !format1.bold;
	trace(format1.bold);
	tfText.setTextFormat(format1);
}

private function changeItalic(e:MouseEvent):void 
{
	format1.italic = !format1.italic;
	tfText.setTextFormat(format1);
}

private function changeUnderline(e:MouseEvent):void 
{
	format1.underline = !format1.underline;
	tfText.setTextFormat(format1);
}*/

//----------------------------------------------------------------------------------------------------
// fGetParaLine
//----------------------------------------------------------------------------------------------------
private function 
fGetParaLine(
	vTextField : TextField,
	vCaretIndex : int
) : String 
{
	var n : int;
	var s : String;
	
	n = vTextField.getFirstCharInParagraph(vCaretIndex);
	s = vTextField.text.substring(n, n + vTextField.getParagraphLength(vCaretIndex));
	
	return s;
}

//----------------------------------------------------------------------------------------------------
// fGetParaIndexFromCaret
//----------------------------------------------------------------------------------------------------
private function 
fGetParaIndexFromCaret(
	vTextField : TextField,
	vCaretIndex : int
) : int 
{
	var vList : Array;
	var i, n : int;

	vList = vTextField.text.split("\r");
	
	for (i = 0; i < vList.length; i++) 
	{
		n += vList[i].length;
		vList[i] = { vText: vList[i], vLength: n };
	}
	
	for (i = 0; i < vList.length; i++) 
		if (vCaretIndex <= vList[i].vLength)
			break;
	
	return i;
}

//----------------------------------------------------------------------------------------------------
// fSetUI
//----------------------------------------------------------------------------------------------------
private function 
fSetUI(
	vTextFormat : TextFormat
) : void 
{
	var i, vCaretIndex : int;
	var vList : Array;
	var s : String;	
	
	if (vTextFormat.font != null)
	{
		s = vTextFormat.font == "_sans" ? "Arial" : vTextFormat.font;
		cxOption_Font.selectedIndex = fComboItemToIndex(cxOption_Font, s);
	}
	
	vCaretIndex = tfText.caretIndex;
	if (tfText.caretIndex == tfText.length)
		vCaretIndex -= 1

	if (vTextFormat.size != null)
		cxOption_Size.selectedIndex = fComboItemToIndex(cxOption_Size, vTextFormat.size);
	cbOption_Underline.selected = vTextFormat.underline;
	cbOption_Bold.selected = vTextFormat.bold;
	cbOption_Italic.selected = vTextFormat.italic;
	cpOption_Color.selectedColor = parseInt(String(vTextFormat.color));
	vList = tfText.text.split("\r");
	for (i = 0; i < vList.length; i++) 
		if (vList[i].replace(/\s+/g, "") == fGetParaLine(tfText, vCaretIndex).replace(/\s+/g, ""))	
			break;
	this["rbAlign_" + fGetLineAlign(tfText.htmlText, i)].selected = true;
}

//----------------------------------------------------------------------------------------------------
// fComboItemToIndex
//----------------------------------------------------------------------------------------------------
private function 
fComboItemToIndex(
	vComboBox : * ,
	vData : Object
) : int 
{
	var i : int;

	for (i = 0; i < vComboBox.length; i++)
		if (String(vComboBox.getItemAt(i).data) == String(vData))
			return i;
	return -1;
}

//----------------------------------------------------------------------------------------------------
// fGetLineAlign
//----------------------------------------------------------------------------------------------------
private function 
fGetLineAlign(
	vHtml : String,
	vLineN : int
) : String 
{
	var vPrefix, s, t : String;

	t = vHtml.split("</P>")[vLineN];

	vPrefix = t.substring(0, t.indexOf("<P ALIGN", 0));
	s = t.substring(vPrefix.length, t.indexOf("<FONT", 0));

	switch (s.toUpperCase())
	{
	case "<P ALIGN=\"LEFT\">": s = "Left"; break;
	case "<P ALIGN=\"CENTER\">": s = "Center"; break;
	case "<P ALIGN=\"RIGHT\">": s = "Right"; break;
	}

	return s;
}

//----------------------------------------------------------------------------------------------------
// fSetLineAlign
//----------------------------------------------------------------------------------------------------
private function 
fSetLineAlign(
	vTextField : TextField,
	vParaN : int,
	vAlign : String
) : void 
{
	var i : int;
	var vPrefix, s, t : String;
	var vList : Array;
	
	t = vTextField.htmlText;
	vPrefix = t.substring(0, t.indexOf("<P ALIGN", 0));
	vList = t.split("</P>");								// get num of lines
	
	t = vList[vParaN];										// raw html for vParaN
	s = t.substring(t.indexOf("<FONT", 0), t.length);		// extract suffix minus p align
	t = vPrefix + "<P ALIGN=\"" + vAlign.toUpperCase() + "\">" + s;	// prefix new p align + extracted suffix
	s = "";
	for (i = 0; i < vList.length; i++) 
		if (vList[i] != "")
			s += ((i == vParaN ? t : vList[i]) + "</P>");
	if (s.substr( -17) == "</TEXTFORMAT></P>")				
		s = s.substring(0, s.length - 4);					// remove extra </P>
	vTextField.htmlText = s;
}

//----------------------------------------------------------------------------------------------------
// fGetLinePrefix
//----------------------------------------------------------------------------------------------------
private function 
fGetLinePrefix(
	vTextField : TextField,
	vLineN : int
) : int 
{
	var i, n : int;
	
	for (i = 0; i < vLineN; i++) 
		n += vTextField.getLineLength(i);
	return n;
}

//----------------------------------------------------------------------------------------------------
// fOnSignal
//----------------------------------------------------------------------------------------------------
protected function
xfOnEvent(
	e : *
) : void
{
	var i, j, n : int;
	var vTarget : * ;
	var vList : Array;
	
	vTarget = e.target;
	
	switch (e.type)
	{
	case MouseEvent.MOUSE_MOVE:
		e.updateAfterEvent();	// for extra smoothing
		break;
	case KeyboardEvent.KEY_UP:
	case MouseEvent.MOUSE_UP:
		xList[0] = tfText.selectionBeginIndex;
		xList[1] = tfText.selectionEndIndex;
		xLineList[0] = tfText.getLineIndexOfChar(xList[0] == tfText.length ? xList[0] - 1 : xList[0]);
		xLineList[1] = tfText.getLineIndexOfChar(xList[1] == tfText.length ? xList[1] - 1 : xList[1]);
		xLineList.sort(Array.NUMERIC);
		xList.sort(Array.NUMERIC);
		if (xList[0] == xList[1])	// same caret no selection
		{			
			xList[0] -= 1;			// get previous caret					
			if (xList[0] == -1)		// if its the first caret
			{
				xList[0] = 0;		// return 0
				return;
			}
			xTextFormat = tfText.getTextFormat(xList[0], xList[1]);		
			xList[0] += 1;
		}
		else
			xTextFormat = tfText.getTextFormat(xList[0], xList[0] + 1);
			//xTextFormat = tfText.getTextFormat(xList[0], xList[1]);
			
		if (vTarget.parent is ColorPicker)
			xColorPickerOpen = true;
		if (!xColorPickerOpen)
			fSetUI(xTextFormat);
		break;
		
	case MouseEvent.CLICK:
		if (vTarget.name.substring(0, 8) == "rbAlign_")
		{		
			for (i = xLineList[0]; i < xLineList[1] + 1; i++)
				fSetLineAlign(tfText, fGetParaIndexFromCaret(tfText, fGetLinePrefix(tfText, i)), vTarget.name.substring(vTarget.name.lastIndexOf("_") + 1, vTarget.name.length));
			stage.focus = tfText;
			tfText.setSelection(xList[0], xList[1]);
		}		
		break;
		
	case Event.CHANGE:
		if (vTarget == tfText) 
		{
			xTextFormat = new TextFormat();
			xTextFormat.underline = cbOption_Underline.selected;
			xTextFormat.bold = cbOption_Bold.selected;
			xTextFormat.italic = cbOption_Italic.selected;
			xTextFormat.size = cxOption_Size.selectedItem.data;
			xTextFormat.font = cxOption_Font.selectedItem.data;
			xTextFormat.color = cpOption_Color.selectedColor;
			if (tfText.caretIndex - 1 != -1)
				tfText.setTextFormat(xTextFormat, tfText.caretIndex - 1, tfText.caretIndex);
		}
		if (vTarget.name.substring(2, vTarget.name.lastIndexOf("_")) == "Option")
		{
			stage.focus = tfText;
			tfText.setSelection(xList[0], xList[1]);
			if (xList[0] == xList[1]) return;
			xTextFormat = new TextFormat();
			xTextFormat = tfText.getTextFormat(xList[0], xList[1]);
			switch (vTarget.name.substring(vTarget.name.lastIndexOf("_") + 1, vTarget.name.length))
			{
			case "Underline": xTextFormat.underline = vTarget.selected; break;
			case "Bold": xTextFormat.bold = vTarget.selected; break;
			case "Italic": xTextFormat.italic = vTarget.selected;	break;
			case "Size": xTextFormat.size = vTarget.selectedItem.data; break;
			case "Font": xTextFormat.font = vTarget.selectedItem.data; break;
			case "Color": xTextFormat.color = vTarget.selectedColor; break;
			}
			tfText.setTextFormat(xTextFormat, xList[0], xList[1]);
			xColorPickerOpen = false;			
		}
		break;		
	}
}

//----------------------------------------------------------------------------------------------------
}	// class

//----------------------------------------------------------------------------------------------------
}	// package