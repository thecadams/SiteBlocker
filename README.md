# SiteBlocker

SiteBlocker is a very simple little app designed to let you block sites from yourself.

# But why?

I (as well as many other people I'm sure) have an unhealthy obsession with getting out my phone to do an "Internet loop". This is referring to a set of websites one goes to during any period of downtime, such as when waiting in line. It seems likely that most people have an internet loop - check Facebook, check emails, check cat videos, check Instagram... then forget you already checked Facebook and start the loop again until you remember what you were actually trying to do in the first place. Big time waster.

For most things I care about being up-to-date about, I've found ways to get news without needing to constantly check certain sites. So the only sites left are centred around Apple (who doesn't love tech news!) and Trump (because the level of crazy is hard to believe).

I badly needed to ditch my reddit habit too, because it was eating up hours each day.

- [Daring Fireball](https://daringfireball.net/)
- [MacRumors](https://macrumors.com/
- [WTF Just Happened Today?](https://wtfjht.com/)
- [Reddit](https://reddit.com/)

This app is in service of a broader experiment to eliminate my entire Internet loop, replacing a polling-based approach ("check this site, check that site") with an automatic push.

For all the sites above except reddit, I block them from myself in a few ways:

- iOS: this app
- PC/Mac: hosts file entries: eg. `127.0.0.1 reddit.com` and `127.0.0.1 www.reddit.com`

Then, for each site that is blocked, I arrange to have a daily digest of each site's RSS feed sent to my inbox using [this IFTTT rule](https://ifttt.com/applets/77234314d-turn-rss-feed-into-daily-digest). That way I can read the email whenever I want, or file it to read at some later time, such as on the weekend.

# So what were the results?

It worked! I no longer find myself going to the sites that were wasting my time - I know the news I would've read is coming to my inbox at 7am tomorrow and I won't miss anything. In fact sometimes I will find myself with my phone unlocked having unconsciously retrieved it from my pocket, then realize there's nothing to check, lock it and put it back.

A couple of fascinating observations have occurred as a result of this experiment.

1. I don't magically get more work done or even have more productivity. I procrastinate the same amount! It's amazing how creative my brain got at finding new and different ways to fill that time. In fact sometimes to procrastinate now, I'll just stare at the wall.

2. What I do have is more energy. Avoiding an accidental long session of paging through reddit posts leaves me with only my own thoughts, which has led me to feel invigorated instead of exhausted and thus to spend more time writing.

3. It's possible the effects will change over the coming months and years, but it's been so amazing to outsource something that takes a lot of willpower (not compulsively checking your phone) so you don't deplete the willpower you have.

4. Big lesson for addicted people of all kinds: if you can outsource your willpower, you'll be able to use the energy it would've taken to kill your bad habit immediately for other purposes, which assists in the process of kicking the habit.

# Usage

Enter regexes of the sites you want to block and it will install a Safari content blocker for you.

# What it will do

Every time you change the list of blocked sites, SiteBlocker generates a Safari [Content Blocker JSON](https://developer.apple.com/library/content/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.html#//apple_ref/doc/uid/TP40016265-CH2-SW1) script containing all the sites you entered.

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
