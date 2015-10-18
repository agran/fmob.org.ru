// bbCode control by
// subBlue design
// www.subBlue.com

// Startup variables
var theSelection = false;
var windop;
// Check for Browser & Platform for PC & IE specific bits
// More details from: http://www.mozilla.org/docs/web-developer/sniffer/browser_type.html
var clientPC = navigator.userAgent.toLowerCase(); // Get client info
var clientVer = parseInt(navigator.appVersion); // Get browser version

var seltxt = '';
var is_ie = ((clientPC.indexOf("msie") != -1) && (clientPC.indexOf("opera") == -1));
var is_nav = ((clientPC.indexOf('mozilla')!=-1) && (clientPC.indexOf('spoofer')==-1)
                && (clientPC.indexOf('compatible') == -1) && (clientPC.indexOf('opera')==-1)
                && (clientPC.indexOf('webtv')==-1) && (clientPC.indexOf('hotjava')==-1));
var is_moz = 0;

var is_win = ((clientPC.indexOf("win")!=-1) || (clientPC.indexOf("16bit") != -1));
var is_mac = (clientPC.indexOf("mac")!=-1);

// Define the bbCode tags
bbcode = new Array();
bbtags = new Array('[b]','[/b]','[i]','[/i]','[u]','[/u]','[img]','[/img]');

// Shows the help messages in the helpline window

// Replacement for arrayname.length property
function getarraysize(thearray) {
  for (i = 0; i < thearray.length; i++) {
          if ((thearray[i] == "undefined") || (thearray[i] == "") || (thearray[i] == null))
            return i;
          }
  return thearray.length;
}

function arraypush(thearray,value) {
  thearray[ getarraysize(thearray) ] = value;
}

function arraypop(thearray) {
  thearraysize = getarraysize(thearray);
  retval = thearray[thearraysize - 1];
  delete thearray[thearraysize - 1];
  return retval;
}

function arraypop2(thearray, nomer) {
  retval = thearray[nomer];
  delete thearray[nomer];
  return retval;
}

function add_smilie(text) {
  text += " ";
  var txtarea = document.post.message;
  if (txtarea.createTextRange && txtarea.caretPos) {
          var caretPos = txtarea.caretPos;
          caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ? text + ' ' : text;
          txtarea.focus();
  } else {
          txtarea.value  += text;
          txtarea.focus();
  }
}

function bbstyle(thetag, theval) {

  document.post.addcodefont.selectedIndex  = 0;
  document.post.addcodesize.selectedIndex  = 0;
  document.post.addcodecolor.selectedIndex = 0;


  var txtarea = document.post.message;

  if (theval != '')
  {
    theval = '=' + theval;
  }

  donotinsert = false;
  theSelection = false;
  bblast = 0;

  if (thetag == '') {
          while (bbcode[0]) {
            butnumber = arraypop(bbcode);
            txtarea.value += '[/' + butnumber + ']';
            buttext = eval('document.post.addcode' + butnumber + '.value');
            eval('document.post.addcode' + butnumber + '.value ="' + buttext.substr(0,(buttext.length - 1)) + '"');
          }
          txtarea.focus();
          return;
  }


  if ((clientVer >= 4) && is_ie && is_win)
  {
          theSelection = document.selection.createRange().text; // Get text selection
          if (theSelection) {
            // Add tags around selection
            document.selection.createRange().text = '[' +thetag + theval + ']' + theSelection + '[/' +thetag + ']';
            txtarea.focus();
            theSelection = '';
            return;
          }
  }
  else if (txtarea.selectionEnd && (txtarea.selectionEnd - txtarea.selectionStart > 0))
  {
          mozWrap(txtarea, '[' +thetag + theval + ']', '[/' +thetag + ']');
          return;
  }


  for (i = 0; i < bbcode.length; i++) {
        if (bbcode[i] == thetag) {
            bblast = i;
            donotinsert = true;
          }
  }

  if (donotinsert) {
          butnumber = arraypop2(bbcode, bblast);


    if (txtarea.createTextRange && txtarea.caretPos) {
      var caretPos = txtarea.caretPos;
      var text = '[/' + butnumber + ']';
      caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ? text + ' ' : text;
    }
    else
    {
      txtarea.value += '[/' + butnumber + ']';
    }

    buttext = eval('document.post.addcode' + butnumber + '.value');
          eval('document.post.addcode' + butnumber + '.value ="' + buttext.substr(0,(buttext.length - 1)) + '"');
    txtarea.focus();
    return;
  } else {

    if (txtarea.createTextRange && txtarea.caretPos) {
      var caretPos = txtarea.caretPos;
      var text = '[' +thetag + theval + ']';
      caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ? text + ' ' : text;
    }
    else
    {
      txtarea.value += '[' +thetag + theval + ']';
    }
          arraypush(bbcode, thetag );
          eval('document.post.addcode'+thetag+'.value += "*"');
          txtarea.focus();
          return;
  }
  storeCaret(txtarea);
}

// From http://www.massless.org/mozedit/
function mozWrap(txtarea, open, close)
{
  var selLength = txtarea.textLength;
  var selStart = txtarea.selectionStart;
  var selEnd = txtarea.selectionEnd;
  if (selEnd == 1 || selEnd == 2)
          selEnd = selLength;

  var s1 = (txtarea.value).substring(0,selStart);
  var s2 = (txtarea.value).substring(selStart, selEnd)
  var s3 = (txtarea.value).substring(selEnd, selLength);
  txtarea.value = s1 + open + s2 + close + s3;
  return;
}

function storeCaret(textEl) {
  if (textEl.createTextRange) textEl.caretPos = document.selection.createRange().duplicate();
}


function ShowHide(id1, id2) {
  if (id1 != '') expMenu(id1);
  if (id2 != '') expMenu(id2);
}

function expMenu(id) {
  var itm = null;
  if (document.getElementById) {
        itm = document.getElementById(id);
  } else if (document.all){
        itm = document.all[id];
  } else if (document.layers){
        itm = document.layers[id];
  }

  if (!itm) {
   // do nothing
  }
  else if (itm.style) {
        if (itm.style.display == "none") { itm.style.display = ""; }
        else { itm.style.display = "none"; }
  }
  else { itm.visibility = "show"; }
}

function bbc_pop(tip)
{
  if(tip == "taghelp")
  {
    var sizetemp = "width=700,height=500";
  }
  if(tip == "smiles")
  {
    var sizetemp = "width=300,height=500";
  }
  if(tip == "mobbereslist")
  {
    var sizetemp = "width=300,height=500";
  }
   if(tip == "newprivate")
  {
    var sizetemp = "width=300,height=150";
  }
  if(tip == "newreg")
  {
    var sizetemp = "width=300,height=150";
  }
  windop=window.open('?mode='+tip, tip, sizetemp + ',resizable=yes,scrollbars=yes');
//  windop.close();

}

function close_pop()
{
  windop.close();
}

function get_selection() {
  seltxt='';
  if (document.getSelection) {seltxt=document.getSelection();}
  else if (document.selection) {seltxt=document.selection.createRange().text;}
}

function quote(name, sex) {
  if(seltxt != "")
  {
    if(sex == "1")
    { sex = "написал: "

    }
    else if(sex == "0")
    {
      sex = "написала: "
    }
    else
    {
      sex = "написал(а): "
    }

  }

  if (name!="")
  {
    if (seltxt == "")
    {
      document.forms.post.message.value+="[b]"+name+"[/b], ";
    }
    else
    {
      document.forms.post.message.value+="[quote][b]"+name+"[/b] " + sex + seltxt +"[/quote]";
    }
  }
  document.forms.post.message.focus();
}


function add_smilie2(text) {
  text += " ";
  var txtarea = opener.document.post.message;
  if (txtarea.createTextRange && txtarea.caretPos) {
    var caretPos = txtarea.caretPos;
          caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ? text + ' ' : text;
          txtarea.focus();
  }
  else
  {
          txtarea.value  += text;
          txtarea.focus();
  }

}

function submit1() {
  document.post.submit.disabled = true;
}

function SelectAll(mark)
{
  for (i = 0; i < document.main.elements.length; i++)
   {
    var item = document.main.elements[i];
    if (item.type == "checkbox")
     {
      item.checked = mark;
     }
   }
}

function reloadad(par){
document.forma.qs.value=par;
ad();
}

function ad(){
document.forma.qs.value++;
var numq=document.forma.qs.value;
if(numq<26)
{
  document.getElementById('div').innerHTML=document.getElementById('div').innerHTML+
  '<table border=0 cellspacing=0 cellpadding=2><tr><td>'+numq+'. <td><input type=text name=variant'+numq+' size=50 maxlength=100></tr></table>';
}
else
{
  alert('Слишком много вариантов!');
}
}


