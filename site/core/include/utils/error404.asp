<!--#include file="../global.asp"-->

<%
'**
'*	A List Apart - The Perfect 404 
'*		http://alistapart.com/articles/perfect404/
'*
'*	Original Author	: Ian Lloyd (Javascript)
'*	Modified by	: Andrew Waer (PHP)
'*	Rewritten by	: Ed Knittel (ASP)
'*	Last Modified	: 01-28-2004
'*	
'*	Basically just an ASP conversion of Andrew's PHP script from Ian's Javascript
'*	With some extras
'**
const formAction = "http://www.mysite.com/formprocessing/forms.asp"
const UNKNOWN_REFERER = "UNKNOWN"


	on error resume next
	
	dim strReferer, strURL, blnSearchReferral, blnInsiteReferral, strError, strSite, result
	strReferer = lCase(request.serverVariables("HTTP_REFERER"))
	strURL = lCase(request.serverVariables("QUERY_STRING"))
	blnSearchReferral = false
	blnInsiteReferral = false
	strError = "404"
	strSite = ""
	set result = new FastString
	

	if len(strReferer)<>0 then
		'We have been referred to this page some another web page ...
		if (inStr(strReferer,".looksmart.co") > 0) OR (InStr(strReferer,".ifind.freeserve") > 0) OR (InStr(strReferer,".ask.co") > 0) OR (inStr(strReferer,"google.co") > 0) OR (inStr(strReferer,"altavista.co") > 0) OR (inStr(strReferer,"msn.co") > 0) OR (inStr(strReferer,"hotbot.co") > 0) OR (inStr(strReferer,"yahoo.co") > 0) then
			'we have been referred to from a known search engine
			blnSearchReferral = true
			dim arrSite : arrSite = split(strReferer,"/")
			dim arrParams : arrParams = split(strReferer,"?")
			dim strSearchTerms : strSearchTerms = arrParams(1)
			dim sQryStr : sQryStr = ""
			arrParams = split(strSearchTerms,"&")
			strSite = arrSite(2)
			
			' Define what search terms are in use
			' Be sure to Dim the array length appropriately
			dim arrQueryStrings(5)
			arrQueryStrings(0) = "q="	'google, altavista, msn
			arrQueryStrings(1) = "p="	'yahoo
			arrQueryStrings(2) = "ask="	'ask jeeves
			arrQueryStrings(3) = "qt="	'looksmart
			arrQueryStrings(4) = "query="	'hotbot
			
			dim i,q
			for i=0 to uBound(arrParams)
				'loop through all the parameters in the referring page's URL
				for q=0 to uBound(arrQueryStrings)
					sQryStr = arrQueryStrings(q)
					if (inStr(arrParams(i),sQryStr)) then
						'we've found a search term!
						strSearchTerms = split(strSearchTerms,sQryStr)(1)
						strSearchTerms = replace(strSearchTerms,"+"," ")
					end if
				next
			next
			
			result.add "<p>You did a search on <strong><a href=""" & strReferer & """>" & strSite & "</a></strong> "
			result.add "for <strong>" & strSearchTerms & "</strong>. However, their index appears to be out of date.</p>" & vbcrlf
			result.add "<h2>All is not lost!</h2>" & vbcrlf
			result.add "<p>We think that the following page(s) on our site will be able to help you:</p>" & vbcrlf
			result.add "<ul>" & vbcrlf
				
			'--------------------------------------------------------------
			' Edit and repeat for all pages you want to match to the search phrases found
			if ((inStr(strSearchTerms,"usability") > 0) OR (inStr(strSearchTerms,"accessibility") > 0)) then
				result.add "<li><a href="""&objLinks.item("SITEURL")&"/usability/"">topic directory: usability</a></li>" & vbcrlf
				result.add "<li><a href="""&objLinks.item("SITEURL")&"/accessibility/"">topic directory: accessibility</a></li>" & vbcrlf
			else
				result.add "<li>Sorry, but we can't seem to find any pages that may be useful.</li>"& vbcrlf
			end if
			'---------------------------------------------------------------------	
			result.add "</ul>"& vbcrlf
			
		end if 'End of section dealing with referral from known search engine
	
		if blnSearchReferral = false then
			' ------------------------------------------------
			' for referrals from other sites with broken links
			arrSite = split(strReferer,"/")
			strSite = arrSite(2)
			result.add "<p>You were incorrectly referred to this page by: <strong><a href=""" & strReferer & """>" & strSite & "</a></strong><br />"& vbcrlf
			result.add "We suggest you try one of the links below:</p>"& vbcrlf
		end if
	else
		'the referer string is empty 
		strReferer = UNKNOWN_REFERER
	end if
	
	if blnSearchReferral = true then
		result.add "<p>Or you could try one of the following pages:</p>" & vbcrlf
		result.add "<p><a href="""&objLinks.item("SITEURL")&""" title=""Go to the home page for "&objLinks.item("SITENAME")&""">Home Page</a><br />" & vbcrlf
		'result.add "<a href=""site_map.asp"" title=""View the complete site map for "&objLinks.item("SITENAME")&""">Site Map</a></p>" & vbcrlf
	else
		' for referrals from other sites with broken links
		' ------------------------------------------------
		blnInsiteReferral = ((inStr(strReferer,objLinks.item("SITEURL")) > 0))
		debugInfo("Insite Referral is "&blnInsiteReferral)
		result.add "<div class=""form"">"& vbcrlf
		result.add "<h2>Help us to help you ...</h2>"& vbcrlf
		result.add "<form method=""post"" action="""&formAction&""" onsubmit=""alert('Thank you for letting us know!');"">"& vbcrlf
		
		if blnInsiteReferral = true then
			result.add "<p>It looks like one of our own links is broken - we're very sorry about this, "& vbcrlf
			result.add "and we will ensure that this is passed on so that the links can be fixed. "& vbcrlf
			result.add "All you need to do is press the button below.</p>"& vbcrlf
			result.add "<input type=""hidden"" name=""Referring Site"" value=""" & strReferer & """ />"& vbcrlf
			arrURL = split(strURL,";")
			strError = arrURL(0)
			strURL = arrURL(1)
		elseif strReferer <> UNKNOWN_REFERER then
			result.add "<p>In order to improve our service, you can inform us that someone else has an incorrect link to our site. "& vbcrlf
			result.add "We will do our best to notify them that this page has moved and ask them to update the link. <strong>Just press the button!</strong></p>"& vbcrlf
			result.add "<input type=""hidden"" name=""Referring Site"" value=""" & strReferer & """ />"& vbcrlf
		else
			result.add "<p>We were unable to determine the source of this faulty link.  It is possible that you have misspelled the address "& vbcrlf
			result.add "of the page or file you are looking for. <strong>Please review the following URL and fix any spelling mistakes:</strong></p>"& vbcrlf
			result.add "<p>The faulty URL was:</p>"& vbcrlf
			arrURL = split(strURL,";")
			strError = arrURL(0)
			strURL = arrURL(1)
			result.add "<div style=""text-align:center;margin:2em auto;""><code>"&strURL&"</code></div>"& vbcrlf
			result.add "<p>However, if you were redirected to the URL from another website, business card, or elsewhere, please "& vbcrlf
			result.add "help us to improve our service, by specifying in the textbox below the location where you encountered this URL."& vbcrlf
			result.add "<div class=""required""><label for=""Referring Site"">Source of Faulty Referral</label><input type=""text"" name=""Referring Site"" value="""" /></div>"& vbcrlf

		end if 
		
		result.add "<input type=""hidden"" name=""Page Requested"" value=""" & strURL & """ />"& vbcrlf
		result.add "<input type=""hidden"" name=""Error Type"" value=""" & strError & """ />"& vbcrlf
		result.add "<div class=""submit""><input type=""submit"" name=""cmdSubmit"" class=""inputSubmit button"" value=""Report this broken link &raquo;"" /></div>"& vbcrlf
		result.add "</form>"& vbcrlf
		result.add "</div>"& vbcrlf
	end if
	result.add "<p>QueryString String was: "&strURL&"</p>"
	result.add "<p>URL was: "&request.ServerVariables("URL")&"</p>"
	
	debugInfo("referer was "&strReferer)
	debugInfo("site url is: "&objLinks.item("SITEURL"))
	debugInfo("requested url is: "&strURL)
	session.contents(CUSTOM_MESSAGE) = session(CUSTOM_MESSAGE) & result.value

%>
