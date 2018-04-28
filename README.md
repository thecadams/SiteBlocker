# SiteBlocker

SiteBlocker is a very simple little app designed to let you block sites from yourself.

# Usage

Enter regexes of the sites you want to block and it will install a Safari content blocker for you.

# What it will do

Every time you change the list of blocked sites, SiteBlocker generates a Safari Content Blocker JSON script containing all the sites you entered.

For example, if the list view contains two rows, and both are enabled:
```
^https://(www.)?site1.com/ [✅]
^https://(www.)?site2.com/ [✅]
```
Then, SiteBlocker will generate this JSON:
```
[
  {
    "trigger": { "url-filter": "^https://(www.)?site1.com/" },
    "action": { "type": "block" }
  },
  {
    "trigger": { "url-filter": "^https://(www.)?site2.com/" },
    "action": { "type": "block" }
  }
]
```

# Ideas, areas for improvement

This isn't intended as a portfolio app. It was built as quickly as possible to validate a hypothesis.

If you base my coding skills off the work I've done on this app, you're going to think I'm trolling you.

Here's some of the stuff that could be done:

- Error handling
- Move more logic into its own class (right now it's only a few lines of code)
- Better way of handling the enable/disable toggles in the rows (tap events only register for a certain type of accessory mark, but I still liked this approach because there is a simple way to handle the tap events)
- Pull more code out of the ViewController
- Night/day time block list - so you can have sites you're only allowed to access when you're not at work
- Geofence based block list? Can we set ourselves a geofence (or timer) trigger then call `SFContentBlockerManager.reloadContentBlocker` in a handler when the trigger fires?

If you'd like to add a feature, reach out! Gladly accepting pull requests.
