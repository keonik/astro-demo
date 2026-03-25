---
title: "Shipping a React Native App While Sleep Deprived"
date: "Mar 25 2026"
draft: false
summary: Building Diaper Diaries — an Expo app that helps parents track and teach their newborns' bathroom patterns. Built out of necessity at 3am.
tldr: Expo's DX is incredible for side projects. Build something you actually need. Sleep deprivation is a surprisingly effective motivator and scope-creep killer.
tags:
  - react-native
  - expo
  - typescript
  - mobile
---

## The 3am problem

When you have a newborn, you track everything. Feedings, sleep, and yes — pee and poo. Pediatricians want to know. Your partner wants to know. And at 3am when you can barely remember your own name, you definitely can't remember the last diaper change.

![Michael Scott - I am Beyonce always](https://media.giphy.com/media/l0HlPystfePnAI3G8/giphy.gif)

There are existing apps for this. They're all bloated with features I didn't need — breastfeeding timers, growth charts, milestone trackers, social sharing (?). I just wanted to log diapers and see patterns. That's it.

So I built [Diaper Diaries](https://github.com/keonik/diaper-diaries). Because apparently I can't just download an app like a normal person.

## Why Expo?

I've built React apps for years, and Expo makes the jump to mobile feel almost unfair. The key wins:

**File-based routing.** Expo Router works like Next.js or TanStack Router. Define a file in `app/`, get a route. No navigation boilerplate. When your brain is running on 3 hours of sleep, less boilerplate = survival.

**Hot reload that actually works.** Change a component, see it instantly on your phone. When your coding windows are measured in 20-minute nap intervals, fast iteration is everything.

**EAS Build.** Push to a branch, get a build on your phone. No Xcode, no Android Studio, no signing certificate nightmares. For a side project, this is the difference between shipping and abandoning.

![Dwight - I am fast. I am very fast.](https://media.giphy.com/media/TL6poLzwbHuF2/giphy.gif)

## The feature set

Intentionally minimal:

- **Log a change** — wet, dirty, or both, with a timestamp
- **Pattern view** — see trends over days and weeks  
- **Quick entry** — one tap from the home screen

That's it. No accounts, no cloud sync, no social features. Local data on a phone that's always in your hand anyway.

## Building for one-handed use

Here's something you don't think about until you're holding a baby: you have one hand. Maybe. The UI had to work with a single thumb on a phone held in one hand while the other hand is... occupied.

![Jim - Camera look](https://media.giphy.com/media/6JB4v4xPTAQFi/giphy.gif)

This meant:

- **Bottom navigation** — thumbs reach the bottom of the screen, not the top
- **Large tap targets** — minimum 48px, preferably bigger
- **Minimal text input** — preset buttons over free-form fields
- **"Just now" as default** — with the option to adjust the timestamp if needed

These aren't fancy UX decisions. They're survival decisions made at 3am with one hand while a baby screams.

## What I learned

### Build what you need RIGHT NOW

I started Diaper Diaries because I needed it that week. Not "someday it would be cool" — I literally needed to track diapers that night. That urgency cuts through scope creep instantly. You don't add a social feed feature when you're exhausted and the baby just pooped again.

### Expo is production-ready for indie apps

I had reservations about going all-in on Expo instead of bare React Native. For this kind of app, the managed workflow is perfect. The times you need to eject are getting rarer with every SDK release.

### Side projects don't need to scale

Diaper Diaries has two users — me and my partner. That's fine. Not every project needs to be a SaaS business. Sometimes you just need an app that works.

### Sleep deprivation makes you write simpler code

When you can barely think straight, you naturally avoid over-engineering. Every abstraction has to justify its existence because you don't have the mental bandwidth for unnecessary complexity.

![Kevin - Why waste time say lot word when few word do trick](https://media.giphy.com/media/TfWhFbURIirNtbOlas/giphy.gif)

Honestly? More code should be written this way.

## The stack

- **Framework**: Expo (React Native)
- **Language**: TypeScript
- **Routing**: Expo Router (file-based)
- **Storage**: Local (AsyncStorage)

Nothing fancy. That's the whole point. Ship it, use it, sleep when you can 🎉

![Michael Scott - I love this](https://media.giphy.com/media/OcZp0maz6ALok/giphy.gif)
