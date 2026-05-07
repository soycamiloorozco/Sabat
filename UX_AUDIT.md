# Sabat — UX/UI Audit Report
**Auditor:** Senior UX Designer (Apple HIG perspective)  
**Date:** May 7, 2026  
**App Version:** Current build (post-tab-refactor)

---

## Executive Summary

Sabat is a sleep ritual app with a strong atmospheric identity — dark palette, serif typography, and a calm voice. The recent refactor to a 3-tab horizontal architecture (Rest / Analytics / Settings) with bottom navigation is a significant step forward. However, several UX gaps remain that prevent the app from feeling truly "designed by Apple." The core issues are: **missing empty states**, **inconsistent button hierarchy**, **weak information scent**, and **onboarding friction points** that break the calming promise.

**Overall Grade: 6.8 / 10** — Good foundation, needs polish to feel premium.

---

## Scores by Dimension

| Dimension | Score | Notes |
|-----------|-------|-------|
| **Information Architecture** | 7/10 | 3-tab structure works. Missing "Today's status" indicator. |
| **Visual Hierarchy** | 6/10 | Cards compete. Labels vs values need clearer weight separation. |
| **Interaction Design** | 7/10 | Haptics are great. Missing pull-to-refresh and loading skeletons. |
| **Typography** | 8/10 | Serif for headings is intentional and works. Mono for labels is sharp. |
| **Color & Contrast** | 6/10 | sabatMuted at 0.64 opacity may fail WCAG on dark backgrounds. |
| **Accessibility** | 5/10 | Missing Dynamic Type support, VoiceOver labels on charts, Reduce Motion. |
| **Onboarding** | 6/10 | 5 steps feel long. No value preview before auth. No skip path. |
| **Empty States** | 3/10 | Analytics shows fake data. No "first night" guidance. Critical gap. |
| **Motion & Feedback** | 8/10 | Haptics on tabs and CTAs. Good spring animations. |
| **Thumb Zone / Ergonomics** | 7/10 | Bottom tab bar is correct. Some cards have CTAs too high. |

---

## Critical Issues (Fix Immediately)

### 1. Analytics Shows Fake Data as Default
**File:** `InsightsView.swift`  
**Severity:** HIGH  
The `isPreviewData` flag shows fabricated bars and scores. This is deceptive. Users will distrust the app when they realize the "week rhythm" was never real. Apple HIG: *"Don't present fake data as real."*

**Fix:** Show a true empty state — a calm illustration, a "Your first night" message, and a CTA to start the ritual. Remove all fake bar data.

### 2. No "First Night" Empty State Anywhere
**Severity:** HIGH  
HomeView shows `lastSessionPanel` only if a session exists. When it doesn't, there's no guidance on what to do. The user lands on a blank-ish screen with two cards and no clear next step.

**Fix:** Add a prominent empty-state card when no sessions exist: "No nights tracked yet. Tap 'Begin ritual' to start your first wind-down."

### 3. Sign-In Gate Before Value Demonstration
**Severity:** MEDIUM-HIGH  
The onboarding forces Apple Sign-In at step 3, before the user has experienced any value. This creates drop-off. The "Continue in development" button is a dev escape hatch that should not exist in production.

**Fix:** Move sign-in to *after* the first ritual, or make it optional with a "Skip for now" path. The first experience should be the voice orb speaking — that is the hook.

### 4. `sabatMuted` Contrast May Fail Accessibility
**Severity:** MEDIUM  
`sabatMuted = Color.sabatPaper.opacity(0.64)` on `sabatInk` background. WCAG 2.1 AA requires 4.5:1 for normal text. With white at 64% opacity on near-black, the ratio is approximately 4.2:1 — borderline failing for small text.

**Fix:** Increase `sabatMuted` to 0.72 opacity or use a slightly lighter ink background.

### 5. RitualView Lacks Feedback During Processing
**Severity:** MEDIUM  
When the user taps the mic or send button, there is no loading indicator. The `isBusy` flag disables buttons but gives no visual feedback that Sabat is "thinking." Users will tap repeatedly.

**Fix:** Add a subtle pulsing animation on the VoiceOrbView or a "Sabat is listening..." text state while `isBusy` is true.

---

## Moderate Issues (Fix Before Beta)

### 6. SmartAlarmView Uses `.toolbar` on a Sheet
**Severity:** MEDIUM  
`SmartAlarmView` is presented as a `.sheet` but uses `.toolbar { ToolbarItem(placement: .topBarLeading) }` for a back button. On sheets, the standard iOS pattern is a dismiss button in the top-trailing corner, or a swipe-to-dismiss indicator. A leading chevron feels like a pushed navigation view.

**Fix:** Move dismiss button to top-trailing. Add a `DragGesture` for swipe-to-dismiss on the sheet.

### 7. ProfileView Save Button Has No Success Feedback
**Severity:** MEDIUM  
Tapping "Save profile" calls `viewModel.save()` but gives no confirmation. The `statusMessage` only appears if there was an error. Users won't know if it worked.

**Fix:** Show a transient toast or checkmark animation. Use `HapticEngine.success()` on save.

### 8. SleepTrackingView Shows "Wake up flow" Button Prematurely
**Severity:** MEDIUM  
The "Wake up flow" button is visible immediately when tracking starts. A user might tap it accidentally 10 minutes into sleep. There should be a safeguard or the button should be de-emphasized until the wake window approaches.

**Fix:** Replace with a subtle "End session" primary action. Move "Wake up now" to an overflow or require a long-press.

### 9. DatePicker Wheel in SleepTrackingView Is Jarring
**Severity:** MEDIUM  
A full wheel picker in the middle of a dark sleep-tracking screen breaks the calm atmosphere. It also forces the user to scroll in a modal UI while half-awake.

**Fix:** Use a compact time display with +/- stepper buttons, or a horizontal wheel with larger touch targets. Consider moving alarm config entirely to SmartAlarmView and only showing the *set* time here.

### 10. NameCollectionView Progress Is Wrong
**Severity:** LOW-MEDIUM  
`OnboardingProgressView(current: 3, total: 5)` appears in both `SignInView` and `NameCollectionView`. If the user skips sign-in via "Continue in development," the progress jumps from 3 to 3 — the user can't tell they advanced.

**Fix:** Make `NameCollectionView` step 4, or remove the progress indicator from `SignInView` if it's optional.

---

## Design Polish (Nice to Have)

### 11. Inconsistent Card Padding
**Severity:** LOW  
`SacredCard` uses `SabatSpacing.lg` (24pt) padding. `MetricTile` inside `InsightsView` adds its own `SabatSpacing.md` (16pt) padding inside the card, creating nested spacing that feels cramped on small screens.

**Fix:** Standardize inner padding. Cards that contain tiles should use `SabatSpacing.md` outer padding and let tiles breathe with their own spacing.

### 12. RestScoreRing Is Static
**Severity:** LOW  
The ring draws instantly with no animation. A score of 0 and a score of 85 look the same for 1 frame. The ring should animate from 0 to the score value on appear.

**Fix:** Add `.animation(.spring(response: 0.6), value: score)` with an `@State` progress variable.

### 13. No Pull-to-Refresh
**Severity:** LOW  
The Home and Analytics tabs have no way to manually refresh data. If the user backgrounded the app and returned, stale data may display.

**Fix:** Add `.refreshable` to ScrollViews with a spinning indicator in `sabatDawn`.

### 14. Missing VoiceOver Context on Charts
**Severity:** LOW (Accessibility)  
The week rhythm bars and phase bars have no `accessibilityLabel` or `accessibilityValue`. A screen reader user hears nothing.

**Fix:** Add `.accessibilityLabel("Sleep duration: \(night.hours) hours, score: \(night.score)")` to each bar.

### 15. OnboardingCompleteView Says Step 4 of 5
**Severity:** LOW  
The final screen shows step 4 of 5. There is no step 5. This creates cognitive dissonance — the user expects another screen.

**Fix:** Change to step 5 of 5, or remove the progress indicator on the final celebration screen.

---

## What's Working Well

- **Atmospheric consistency:** The dark ink palette with cream text is distinctive and calming. The HandmadeTextureView adds craft without noise.
- **Typography pairing:** Serif display + sans body + mono labels is sophisticated. It elevates the app above typical health apps.
- **Haptic feedback:** The tabTick on every tab change makes the app feel physical and responsive. Good use of light impact — not overbearing.
- **Button press animations:** `PillPressButtonStyle` with scale + brightness is satisfying. The 0.22s spring is crisp.
- **Tab architecture:** 3 tabs with horizontal swipe is the right choice for this content. It reduces cognitive load vs the previous deep navigation.
- **SmartAlarm as sheet:** Separating alarm config into a modal keeps the Home tab focused on the primary CTA (Begin ritual).

---

## Recommendations Priority Matrix

| Priority | Issue | Effort | Impact |
|----------|-------|--------|--------|
| P0 | Remove fake analytics data | Low | Very High |
| P0 | Add empty state to Home + Analytics | Low | Very High |
| P0 | Fix `sabatMuted` contrast | Low | High |
| P1 | Add RitualView loading feedback | Medium | High |
| P1 | Move sign-in after first ritual | Medium | Very High |
| P1 | Add save confirmation in Profile | Low | Medium |
| P2 | Animate RestScoreRing | Low | Medium |
| P2 | Fix SmartAlarm sheet dismiss pattern | Low | Medium |
| P2 | Add pull-to-refresh | Low | Medium |
| P3 | Accessibility labels on charts | Low | Medium |
| P3 | Standardize card padding | Low | Low |

---

## Suggested Copy / Tone Improvements

The app's voice is poetic and warm. A few places where it clashes:

- **SleepTrackingView:** "Wake up flow" sounds like a developer term. Suggest: "I'm awake" or "Rise gently."
- **ProfileView "Sleep" section:** "Phase 2 settings" is internal jargon. Users don't know what "Phase 2" means. Suggest: "Smart alarm" or "Wake-up settings."
- **WakeUpView:** "Your first reflection will close the loop here." This is abstract. Suggest: "How did you sleep?" or a direct prompt.

---

## Conclusion

Sabat has a strong identity and the recent navigation refactor puts it on the right track. The biggest risks before launch are **trust** (fake data in analytics) and **accessibility** (contrast + screen reader support). Fix the P0 items and the app will feel significantly more polished and trustworthy.

The app is 70% there. The remaining 30% is the hard work of empty states, edge cases, and accessibility — the things users don't notice until they're missing.
