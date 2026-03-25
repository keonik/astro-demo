---
title: "Shipping a React Native App While Sleep Deprived"
date: "Mar 25 2026"
draft: false
summary: Building Diaper Diaries — an Expo app that helps parents track and teach their newborns' bathroom patterns. Built out of necessity at 3am.
tldr: Expo's DX is incredible for side projects. Build something you actually need. Sleep deprivation is a surprisingly effective motivator.
tags:
  - react-native
  - expo
  - typescript
  - mobile
---

## The 3am Problem

When you have a newborn, you track everything. Feedings, sleep, and yes — pee and poo. Pediatricians want to know. Your partner wants to know. And at 3am when you can barely remember your own name, you definitely can't remember when the last diaper change was.

There are existing apps for this, but they're all bloated with features I didn't need — breastfeeding timers, growth charts, milestone trackers, social sharing (?). I just wanted to log diapers and see patterns.

So I built [Diaper Diaries](https://github.com/keonik/diaper-diaries).

## Why Expo?

I've built React apps for years, and Expo makes the jump to mobile feel effortless. The key wins:

**File-based routing.** Expo Router works like Next.js or TanStack Router. Define a file in `app/`, get a route. No navigation boilerplate.

**Hot reload that actually works.** Change a component, see it instantly on your phone. When your coding windows are measured in 20-minute nap intervals, fast iteration matters.

**EAS Build.** Push to a branch, get a build on your phone. No Xcode, no Android Studio, no signing certificate nightmares. For a side project, this is the difference between shipping and abandoning.

## The Feature Set

Intentionally minimal:

- **Log a change** — wet, dirty, or both, with a timestamp
- **Pattern view** — see trends over days and weeks
- **Quick entry** — one tap from the home screen (it's a common operation at 3am)

That's it. No accounts, no cloud sync, no social features. Local data on a phone that's always in your hand anyway.

## Building for One-Handed Use

Here's something you don't think about until you're holding a baby: you have one hand. Maybe. The UI had to work with a single thumb on a phone held in one hand while the other hand is... occupied.

This meant:

- **Bottom navigation** — thumbs reach the bottom of the screen, not the top
- **Large tap targets** — minimum 48px, preferably bigger
- **Minimal text input** — preset buttons over free-form fields
- **Confirmation over precision** — "just now" as a default timestamp, with the option to adjust

## What I Learned

**Build what you need right now.** I started Diaper Diaries because I needed it that week. Not "someday it would be cool" — I literally needed to track diapers that night. That urgency cuts through scope creep instantly.

**Expo is production-ready for indie apps.** I had reservations about going all-in on Expo instead of bare React Native, but for this kind of app, the managed workflow is perfect. The times you need to eject are getting rarer with every SDK release.

**Side projects don't need to scale.** Diaper Diaries has one user (well, two — my partner uses it too). That's fine. Not every project needs to be a SaaS business. Sometimes you just need an app that works.

**Sleep deprivation makes you write simpler code.** When you can barely think straight, you naturally avoid over-engineering. Every abstraction has to justify its existence because you don't have the mental bandwidth for unnecessary complexity. Honestly, more code should be written this way.

## The Stack

- **Framework**: Expo (React Native)
- **Language**: TypeScript
- **Routing**: Expo Router (file-based)
- **Storage**: Local (AsyncStorage)

Nothing fancy. That's the point.
