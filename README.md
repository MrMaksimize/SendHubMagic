###App TODOs
* Better validation on text fields.
* Currently when there's an api error, only AFIS knows about it.  I'd like to adjust it so that I can provide feedback to the user.
* In Core Data model, I'm storing the contact id as id_str, and AFIS is storing it in its own methods.  I'd like to store it only once, need to figure out how.
* Abstract the API client out and make it its own Pod so other people can use it.
* Use Autolayout for the views.

###APP Notes
* `SHMSendHubAPIConstants.h` stores the Phone Number and API Key.
* In order to run it, you will need to set up CocoaPods:
  * [More Info](http://cocoapods.org/)
  * git clone the repository
  * [sudo] gem install cocoapods
  * cd {repo folder}
  * `pod install`
  * `open SendHubMagic.xcworkspace`
* I have tested it Across 3.5 and 4 inch iPhone on iOS 6.1, and the large iPad both retina and not.  But really it should have better compatibility once I can enable AutoLayout.
* In order to send a message, I'm currently storing it, and AFIS automatically takes care of creation and by extension sending the message.  I figured this was a good pattern since then that opens up the ability to display sent messages to the user.  However this would need an expansion of the Message Core Data model to include attributes like `to`, `time,` etc.
* For adding new contacts, I have written a good chunk of the `SHMContactDetailsViewController` to be able to handle that, I just haven't gotten around to it and the functionality didn't seem to be outlined in the mockups.  So really, the only thing I'd need to do is add the + button somewhere on the TableViewController, initialize the `SHMContactDetailsTableViewController` with no contact (which it can already handle), update the core data call
  and make any necessary AFIS adjustments.

###API Notes
* It makes me a bit nervous that every request I signed isn't signed with any authentication tokens or even cookies, but rather with just my phone number and API key.  I'd like to see the API grow to use OAuth and possibly provide methods to get capability tokens. I have several ideas on how to do this, but I really think it would be so much better if I didn't have to store the API key and my phone number hardcoded in the app since that can be reverse engineered and the account hijacked.


