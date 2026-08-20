# Kiosk RFID — Portrait Responsive Design System

## 1. Project Overview

Design specification for a **portrait, responsive, touchscreen RFID self-service kiosk**.

The kiosk is the physical terminal used by customers to:

1. Identify themselves using an RFID card.
2. Register when the RFID card is not yet associated with a member.
3. Capture a face photo to confirm physical presence.
4. Complete a check-in.
5. Receive loyalty points when the check-in is valid.
6. Return automatically to the welcome screen.

The kiosk is **not an admin dashboard** and should not look like a traditional enterprise dashboard.

The visual direction is inspired by the provided reference:

- clean white/off-white background
- large whitespace
- simple typography
- rounded cards
- subtle shadows
- restrained use of brand color
- friendly but professional
- minimal illustrations
- clear primary actions
- touchscreen-first interaction

The interface should feel like a polished consumer self-service terminal rather than an AI-generated dashboard.

---

# 2. Product Identity

## Product Type

RFID Loyalty & Presence Kiosk

## Primary User

Customers / visitors using a physical RFID member card.

## Primary Hardware

- Portrait touchscreen
- RFID reader
- Camera
- Speaker
- Network connection
- Optional QR scanner

## Primary Flow

```text
WELCOME
  ↓
RFID SCAN
  ↓
IDENTIFY MEMBER
  ├── Existing Member
  │      ↓
  │   CAMERA CAPTURE
  │      ↓
  │   PHOTO CONFIRMATION
  │      ↓
  │   PRESENCE VERIFICATION
  │      ↓
  │   CHECK-IN
  │      ↓
  │   POINTS EARNED
  │      ↓
  │   SUCCESS
  │
  └── New / Unregistered RFID
         ↓
      REGISTRATION
         ↓
      CAMERA CAPTURE
         ↓
      CONFIRMATION
         ↓
      RFID BINDING
         ↓
      CHECK-IN
         ↓
      SUCCESS
```

---

# 3. Design Principles

## 3.1 One Screen, One Goal

Every screen should communicate one primary action.

Examples:

- Welcome → Start / scan RFID
- Registration → Enter personal information
- Camera → Position face
- Confirmation → Confirm information/photo
- Success → Show result

Avoid multiple competing CTAs.

---

## 3.2 Touchscreen First

The kiosk is operated primarily by touch.

Use:

- large buttons
- generous spacing
- large text
- clear states
- obvious tap areas
- no tiny controls
- no hover-dependent interactions

Recommended minimum touch target:

- Primary buttons: 52–64 px high
- Secondary buttons: 48–56 px high
- Icon buttons: minimum 48 × 48 px

---

## 3.3 Calm Visual Hierarchy

Do not fill the screen.

Use whitespace intentionally.

The visual hierarchy should generally be:

```text
Brand
  ↓
Context / greeting
  ↓
Main instruction
  ↓
Main interaction
  ↓
Secondary action
  ↓
System status
```

---

## 3.4 Human-Made Visual Language

Avoid:

- excessive gradients
- glassmorphism
- neon colors
- excessive floating cards
- random 3D AI illustrations
- overly complex illustrations
- excessive shadows
- dashboard-like layouts

Prefer:

- flat/soft visual treatment
- subtle shadows
- simple illustrations
- clean cards
- restrained accent colors
- consistent spacing

---

# 4. Responsive Strategy

## 4.1 Primary Design Target

Create the Figma master design at:

```text
1080 × 1920 px
```

Aspect ratio:

```text
9:16
```

This represents the target portrait kiosk.

---

## 4.2 Responsive Behavior

The Flutter implementation must not depend on fixed screen dimensions.

The same interface should adapt to:

```text
Small Portrait
600 × 1000

Medium Portrait
720 × 1280

Target Kiosk
1080 × 1920

Large Portrait
1200 × 1920

Landscape Development
1280 × 720
1920 × 1080
```

Portrait is the primary experience.

Landscape is a supported development/adaptive mode.

---

## 4.3 Layout Rules

Use responsive constraints rather than hardcoded dimensions.

Recommended structure:

```text
Screen
└── SafeArea
    └── Responsive Page Container
        ├── Header
        ├── Main Content
        └── Footer / System Status
```

Use:

- `LayoutBuilder`
- `MediaQuery`
- `SafeArea`
- `Expanded`
- `Flexible`
- `ConstrainedBox`
- max-width containers

Avoid:

```text
fixed width = 1080
fixed height = 1920
```

---

# 5. Portrait Layout Grid

## 5.1 Safe Area

Recommended minimum horizontal padding:

```text
24 px
```

For large screens:

```text
32–48 px
```

---

## 5.2 Content Width

Do not stretch content to the entire display.

Recommended maximum content width:

```text
720–860 px
```

The main interaction should remain visually centered.

---

## 5.3 Vertical Structure

Example:

```text
┌──────────────────────────┐
│        Safe Area         │
│                          │
│          LOGO            │
│                          │
│     Language Switch      │
│                          │
│       Greeting           │
│                          │
│      Main Heading        │
│                          │
│     Primary Content      │
│                          │
│      Secondary CTA       │
│                          │
│      Need Help?          │
│                          │
│      System Status       │
│                          │
└──────────────────────────┘
```

---

# 6. Design Tokens

## 6.1 Colors

Use a neutral base.

### Background

```text
Background Primary
#FAFAF9
```

### Surface

```text
Surface
#FFFFFF
```

### Primary Brand

Use a dark teal / green accent.

```text
Primary
#0F5C5A
```

### Primary Dark

```text
Primary Dark
#084744
```

### Text

```text
Text Primary
#171717
```

### Text Secondary

```text
#6B6B6B
```

### Text Muted

```text
#9A9A9A
```

### Border

```text
#E8E8E8
```

### Success

```text
#168A5A
```

### Warning

```text
#C88719
```

### Error

```text
#C94848
```

Do not use all colors at once.

Primary brand color should be used mainly for:

- active states
- primary CTA
- success confirmation
- important highlights
- brand logo

---

# 7. Typography

Use a modern neutral sans-serif.

Preferred:

```text
Inter
```

Fallback:

```text
system-ui
```

## Display

```text
48–64 px
Weight: 600–700
Line Height: 1.1
```

## Heading

```text
32–40 px
Weight: 600–700
Line Height: 1.2
```

## Subheading

```text
22–28 px
Weight: 500–600
```

## Body

```text
18–22 px
Weight: 400–500
Line Height: 1.4
```

## Caption

```text
14–16 px
Weight: 400–500
```

For a kiosk, prefer larger typography than a conventional website.

---

# 8. Spacing System

Use an 8 px base grid.

```text
8
16
24
32
40
48
64
80
96
```

Recommended:

- screen padding: 24–48
- section spacing: 32–64
- card padding: 24–40
- button padding: 16–24
- text-to-control spacing: 16–24

---

# 9. Border Radius

Use a soft but restrained radius.

```text
Small
12 px

Medium
16 px

Large Card
24 px

Hero / Main Card
28–32 px

Pill
999 px
```

Do not use excessive rounding on every element.

---

# 10. Shadows

Use subtle shadows only.

### Card

```text
0 8px 24px rgba(0,0,0,0.06)
```

### Elevated Card

```text
0 12px 32px rgba(0,0,0,0.08)
```

Avoid dark or dramatic shadows.

---

# 11. Core Components

## 11.1 Logo

Position:

Top center.

Use:

- brand logo
- optional wordmark

Recommended width:

```text
140–220 px
```

---

## 11.2 Language Selector

Style inspired by the provided reference.

Example:

```text
┌────────────────────────────┐
│ 🇮🇩 Indonesia │ 🇬🇧 English │
└────────────────────────────┘
```

Use a compact segmented control.

Active language:

- white surface
- subtle shadow
- dark text

Inactive:

- transparent/soft background
- muted text

---

## 11.3 Primary Button

Example:

```text
┌──────────────────────────┐
│        CONTINUE          │
└──────────────────────────┘
```

Properties:

- minimum height: 56 px
- radius: 16 px
- large text
- strong contrast
- full-width within constrained content

---

## 11.4 Secondary Button

Use outlined or soft neutral treatment.

Example:

```text
┌──────────────────────────┐
│         CANCEL           │
└──────────────────────────┘
```

---

## 11.5 Help Button

Keep small and unobtrusive.

Example:

```text
       Need help?
```

Use pill styling.

---

## 11.6 Status Indicator

Example:

```text
● System Ready
```

States:

```text
● Ready
● Processing
● Offline
● Error
```

Use text plus indicator, not color alone.

---

# 12. Screen Specifications

# 12.1 Welcome Screen

## Purpose

Initial screen shown when kiosk is idle.

## Content

```text
Logo

Language Selector

Hello, Welcome to KUTUKU

What do you want today?

[ Check In ]
[ Register ]

Need help?

● System Ready
```

Alternative for RFID-first flow:

```text
Hello, Welcome to KUTUKU

Tap your RFID card to continue.

[ RFID illustration / animation ]

Waiting for card...

Need help?
```

## Visual

Use large whitespace.

Do not make it look like an admin dashboard.

---

# 12.2 RFID Scan Screen

## Purpose

Tell the user how to interact with the RFID reader.

```text
Check In

Tap your RFID card

[ RFID CARD ILLUSTRATION ]

Hold your card near
the reader

Waiting for card...

Cancel
```

Optional animated RFID waves.

Animation should be subtle.

---

# 12.3 RFID Processing

```text
Checking your card...

[ Loading indicator ]

Please wait
```

Do not allow repeated interactions during processing.

---

# 12.4 Existing Member Screen

```text
Welcome back

[ Member Avatar / Photo ]

Muhammad Habib

Member ID
MEM-00123

Your card is ready.

[ CONTINUE ]
```

The screen should quickly transition into presence capture.

---

# 12.5 RFID Not Registered

```text
Card not registered

This RFID card is not connected
to a member account yet.

[ REGISTER NOW ]

[ CANCEL ]
```

Use a simple illustration or RFID icon.

---

# 12.6 Registration — Personal Information

Use one field group per screen where possible.

```text
Create your account

What is your name?

┌──────────────────────────┐
│ Full name                │
└──────────────────────────┘

[ CONTINUE ]

1 of 3
```

---

# 12.7 Registration — Contact

```text
Contact information

What is your phone number?

┌──────────────────────────┐
│ 08xxxxxxxxxx             │
└──────────────────────────┘

[ CONTINUE ]

2 of 3
```

Use a large numeric-friendly keypad if appropriate.

---

# 12.8 Registration — Confirmation

```text
Review your information

Name
Muhammad Habib

Phone
08xxxxxxxxxx

RFID
•••• 2391

[ CREATE ACCOUNT ]

[ BACK ]
```

---

# 12.9 Camera Preparation

```text
Let's confirm you're here

We need a quick photo
to confirm your presence.

[ CAMERA / PERSON ILLUSTRATION ]

Please look at the camera.

[ CONTINUE ]
```

---

# 12.10 Camera Capture

## Full-screen camera experience

```text
Take your photo

┌──────────────────────────┐
│                          │
│                          │
│       FACE AREA          │
│                          │
│           3              │
│                          │
└──────────────────────────┘

Keep your face inside
the frame.
```

Use a face guide.

Do not overlay excessive controls.

---

# 12.11 Photo Confirmation

```text
Is this photo okay?

[ PHOTO ]

[ USE PHOTO ]

[ RETAKE ]
```

Primary action should be "Use Photo".

---

# 12.12 Presence Verification

```text
Confirming your presence...

[ Progress indicator ]

Please wait
```

Do not allow accidental navigation.

---

# 12.13 Check-in Success

```text
✓

You're checked in!

Welcome, Muhammad.

19 August 2026
14:32

[ CONTINUE ]
```

Use subtle success animation.

---

# 12.14 Points Earned

This is a key reward moment.

```text
You earned

+50 POINTS

Your total

1,250 POINTS

Thanks for visiting!

[ DONE ]
```

Make the earned points visually dominant.

Do not overuse confetti or gamification.

---

# 12.15 Duplicate Check-in

```text
You're already checked in

You have already checked in
at this location today.

No additional points were added.

[ BACK TO HOME ]
```

Tone should be informative, not alarming.

---

# 12.16 Error

```text
Something went wrong

We couldn't complete
your check-in.

Please try again.

[ TRY AGAIN ]

[ BACK TO HOME ]
```

---

# 12.17 Offline

```text
Connection unavailable

The kiosk cannot reach
the server right now.

Please try again later.

● System Offline

[ RETRY ]
```

---

# 12.18 Camera Error

```text
Camera unavailable

We couldn't access the camera.

Please make sure the camera
is not being used by another app.

[ TRY AGAIN ]

[ BACK TO HOME ]
```

---

# 12.19 Session Timeout

```text
Session expired

For your privacy, this session
has been closed.

[ START AGAIN ]
```

Automatically return to welcome after a short delay.

---

# 13. Camera UI Guidelines

Camera screen is different from standard form screens.

Use:

- dark camera preview
- clear face guide
- large countdown
- minimal text
- no unnecessary cards

Example:

```text
┌──────────────────────────┐
│ Take your photo          │
│                          │
│ ┌──────────────────────┐ │
│ │                      │ │
│ │       ◯ FACE ◯       │ │
│ │                      │ │
│ │         3            │ │
│ │                      │ │
│ └──────────────────────┘ │
│                          │
│ Look at the camera       │
└──────────────────────────┘
```

---

# 14. RFID Interaction

The RFID interaction should be visually obvious.

Possible visual treatment:

```text
      ╭──────────╮
      │  RFID    │
      │   CARD   │
      ╰──────────╯

       ))  ))  ))
        RFID
```

Use a subtle pulse animation.

Do not use flashing or distracting animations.

---

# 15. Navigation Rules

Kiosk navigation is not like a normal mobile application.

Do not show:

- bottom navigation
- side navigation
- hamburger menu
- admin menu

unless there is a specific operator mode.

Most screens should have:

- one primary action
- one secondary action
- optional help

---

# 16. Session Rules

Every kiosk interaction should be treated as a temporary session.

Example:

```text
session_id
device_id
location_id
user_id
rfid_id
```

At completion:

```text
Clear user state
Clear temporary photo
Clear RFID state
Reset camera
Reset scanner
Return to Welcome
```

Never expose the previous customer's information to the next customer.

---

# 17. Responsive Layout Rules

## Portrait

Primary layout:

```text
Column
```

Content is centered.

## Landscape

Use adaptive split layout where appropriate:

```text
┌───────────────────────────────────┐
│                                   │
│  Information     Main Interaction│
│                                   │
└───────────────────────────────────┘
```

Camera can become a larger side panel.

## Large Displays

Use a maximum content width.

Do not stretch cards infinitely.

---

# 18. Accessibility

Ensure:

- high text contrast
- large touch targets
- readable typography
- clear focus/active state
- icons paired with text where meaning matters
- color is not the only status indicator
- language selector is easy to find

---

# 19. Motion

Use short, functional animations.

Recommended:

```text
Fade
150–250ms

Scale
150–250ms

Page transition
200–300ms

Success
300–500ms
```

RFID animation:

- subtle pulse
- 1–2 second loop

Avoid excessive motion.

---

# 20. Figma File Structure

Create the Figma file with these pages:

```text
00 — Cover
01 — Design System
02 — Components
03 — Welcome
04 — RFID Flow
05 — Registration Flow
06 — Camera Flow
07 — Check-in Flow
08 — Points Flow
09 — Error & Recovery
10 — Responsive Variants
11 — Prototype
```

---

# 21. Figma Components

Create reusable components:

```text
Button / Primary
Button / Secondary
Button / Ghost

Language Selector

Status Indicator

RFID Card Illustration

RFID Scan Animation

Input Field

Numeric Keypad

Progress Indicator

Step Indicator

Member Card

Photo Frame

Face Guide

Success Message

Error Message

Help Button

Kiosk Header

Kiosk Footer
```

Use component variants for:

```text
Default
Pressed
Disabled
Loading
Success
Error
```

---

# 22. Prototype Flow

Prototype the main happy path:

```text
Welcome
 ↓
RFID Scan
 ↓
Member Found
 ↓
Camera Preparation
 ↓
Camera Capture
 ↓
Photo Confirmation
 ↓
Presence Verification
 ↓
Check-in Success
 ↓
Points Earned
 ↓
Welcome
```

Also prototype:

```text
RFID Not Registered
 ↓
Registration
 ↓
Camera
 ↓
Confirmation
 ↓
Success
```

And:

```text
RFID
 ↓
Already Checked In
 ↓
Welcome
```

---

# 23. Design Quality Checklist

Before considering the design complete:

- [ ] Portrait 1080 × 1920 master frame
- [ ] Responsive rules documented
- [ ] Touch targets are large enough
- [ ] No dashboard-style navigation
- [ ] Visual hierarchy is obvious
- [ ] Primary action is clear
- [ ] Background is clean and calm
- [ ] Shadows are subtle
- [ ] Cards are consistent
- [ ] Typography is consistent
- [ ] RFID interaction is obvious
- [ ] Camera interaction is obvious
- [ ] Success state feels rewarding
- [ ] Error state is understandable
- [ ] Offline state is understandable
- [ ] Session timeout exists
- [ ] All major states have designs
- [ ] Existing and new member flows are covered
- [ ] Point reward flow is covered
- [ ] Responsive landscape behavior is documented
- [ ] Figma components are reusable

---

# 24. Final Visual Direction

The final kiosk should feel like:

```text
Clean
Friendly
Professional
Minimal
Touch-first
Trustworthy
Modern
Calm
```

It should NOT feel like:

```text
AI dashboard
Enterprise admin panel
Gaming interface
Crypto/Web3 UI
Over-designed SaaS dashboard
```

Use the provided visual reference as the main inspiration for spacing, simplicity, typography, card treatment, and overall composition.

The goal is to create a **real-world self-service kiosk interface** that feels natural when a person stands in front of a physical portrait touchscreen.

---

# 25. Implementation Principle

Figma is the visual source of truth.

Flutter is the implementation.

Do not copy Figma coordinates into Flutter as fixed screen dimensions.

Instead:

```text
Figma
1080 × 1920
      ↓
Design tokens
      ↓
Responsive constraints
      ↓
Flutter widgets
      ↓
Adaptive kiosk experience
```

The business logic remains independent from UI layout.

```text
UI
 ↓
State / Controller
 ↓
Services
 ↓
Laravel API
```

The kiosk UI must remain flexible enough to run on different portrait and landscape displays without rewriting the business logic.
