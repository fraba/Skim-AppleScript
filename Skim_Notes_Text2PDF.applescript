(* AppleScript to add highlights to PDF from text

The script requires an input file with one highlight on each line

*)

--Watch out for problematic characters, such as the dash character. You might need to replace them before processing the text

-- Set Variables
set numberOfChars to 30
set numberOfTotalMatches to 0
set numberOfPartialMatches to 0
set numberOfNotes to 0
set missedNotes to {}


set theFile to (choose file with prompt "Select file with annotations:" of type {"txt"})

open for access theFile

-- Set encoding to utf8 (Change if necessary)
set fileContent to (read theFile as Çclass utf8È)

close access theFile

set theContentList to paragraphs of fileContent

set numberOfNotes to (theContentList's length)

repeat with theItem in theContentList
	
	tell application "Skim"
		activate
		
		if (count of documents) is 0 then
			beep
			display dialog "No documents found."
			return
		end if
		
		tell document 1
			
			set numberOfChar to count (theItem)
			
			if numberOfChar > 60 then
				
				set firstPart to ((characters 1 thru numberOfChars of theItem) as string)
				
				set lastPart to ((characters -numberOfChars thru -1 of theItem) as string)
				
				set firstSel to find text firstPart
				
				if firstSel is not {} then
					
					set firstNote to make note with properties {type:highlight note, selection:firstSel}
					set text of firstNote to firstPart
					
					set lastSel to find text lastPart
					
					if lastSel is not {} then
						
						set lastNote to make note with properties {type:highlight note, selection:lastSel}
						set text of lastNote to lastPart
						
						set theSel to {}
						
						set theSel to firstSel join to lastSel with continuous selection
						
						make note with properties {type:highlight note, selection:theSel, text:(get text for theSel) as text}
						delete lastNote
						delete firstNote
						
						set numberOfTotalMatches to numberOfTotalMatches + 1
						
					else
						set numberOfPartialMatches to numberOfPartialMatches + 1
						
					end if
					
				else
					
					set end of missedNotes to theItem
					
				end if
				
			else
				set theText to theItem
				
				if theText is missing value then
					
					set theText to ""
					
					set end of missedNotes to theItem
					
				end if
				
				set theSel to find text theText
				
				repeat while theSel is not {}
					
					set theNote to make note with properties {type:highlight note, selection:theSel}
					set text of theNote to theText
					set theSel to find text theText from theSel
					
				end repeat
				
				set numberOfTotalMatches to numberOfTotalMatches + 1
				
			end if
			
		end tell
		
	end tell
	
end repeat

display dialog "Done! 
	Number of notes: " & numberOfNotes & "; 
	Number of total matches: " & numberOfTotalMatches & "; 
	Number of partial matches: " & numberOfPartialMatches & "; 
	Number of missed notes: " & numberOfNotes - numberOfTotalMatches - numberOfPartialMatches & ";
	Missed notes: " & missedNotes
return


