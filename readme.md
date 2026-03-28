# Univunity

## Table of Contents
1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Schema](#schema)

---

## Overview

### Description
Univunity is a swipe-based college discovery and application platform for iOS. Users explore undergraduate and graduate programs by swiping through personalized college profiles — swiping right to save or apply, and left to pass. Designed for high school seniors, transfer students, and prospective graduate students, the app simplifies the overwhelming college search and application process. Students can view detailed school profiles, track submitted applications, and receive deadline reminders — all in one place. By combining personalization, convenience, and a familiar interaction model, Univunity empowers students to discover opportunities efficiently and take the next step in their education with confidence.

### App Evaluation
| Attribute | Evaluation |
|-----------|------------|
| **Category** | Education |
| **Mobile** | Yes — swipe-based interactions are inherently mobile-native and designed for on-the-go use. The app leverages push notifications, touch gestures, and a card-based UI that would not translate well to desktop. |
| **Story** | Students applying to college face a stressful, fragmented process spread across dozens of websites. Univunity consolidates discovery, saving, and applying into a single swipe-based experience — making the journey faster and less intimidating. |
| **Market** | High school seniors, community college transfer students, and prospective graduate students. In the US alone, over 20 million students are enrolled in higher education, with millions more applying each year. |
| **Habit** | Moderate-to-high frequency during application season (August–January). Users return daily to swipe through new colleges, check application status, and review deadline notifications. Less active in off-season but re-engaged for graduate/transfer cycles. |
| **Scope** | Narrow and well-defined. The MVP focuses on core features: user auth, swiping, college profiles, and saving/applying. Optional features like tracking dashboards and personalized recommendations are clearly scoped for future iterations. |

---

## Product Spec

### 1. User Stories

#### Required (Must-Have)
* User can create an account and log in securely
* User can complete an onboarding flow to set preferences (intended major, location preference, budget range, degree type)
* User can swipe right to save a college or swipe left to pass
* User can tap on a college card to view its full profile (tuition, majors, location, acceptance rate, requirements)
* User can save a college to their Favorites list
* User can initiate an application to a saved college through the app
* User can view all saved/favorited colleges in one screen
* User can access and edit their profile at any time

#### Optional (Nice-to-Have)
* User can track the status of submitted applications (Not Started, In Progress, Submitted, Decision Received) in an Application Dashboard
* User can receive push notifications for application deadlines and new college matches
* User can receive personalized college recommendations based on GPA, interests, and preferences
* User can filter and sort the college swipe feed (by location, tuition, major availability)
* User can add notes to a saved college

---

### 2. Screen Archetypes

* **Login / Sign Up Screen**
  * User can register a new account
  * User can log in with existing credentials

* **Onboarding Screen**
  * User can set academic preferences (major, degree type, GPA range, budget, location)

* **Home / Swipe Screen**
  * User can swipe right (save) or left (pass) on college cards
  * User can tap a card to view full college details

* **College Detail Screen**
  * User can view full school profile: tuition, acceptance rate, available majors, location, and requirements
  * User can save the college or start an application from this screen

* **Favorites / Saved Colleges Screen**
  * User can view all right-swiped and saved colleges
  * User can remove a college from favorites

* **Applications Dashboard**
  * User can view all colleges they have applied to
  * User can see the current application status for each school

* **Notifications Screen**
  * User can view alerts for upcoming deadlines, decision updates, and new matches

* **Profile Screen**
  * User can view and edit their personal information and preferences

* **Settings Screen**
  * User can manage account settings, notification preferences, and privacy options

---

### 3. Navigation

#### Tab Navigation (Bottom Tab Bar)
* 🏠 Home (Swipe Feed)
* ❤️ Favorites
* 📋 Applications
* 🔔 Notifications
* 👤 Profile

#### Flow Navigation (Screen to Screen)

* **Login / Sign Up Screen**
  * → Onboarding Screen *(first-time users)*
  * → Home / Swipe Screen *(returning users)*

* **Onboarding Screen**
  * → Home / Swipe Screen *(after completing preferences)*

* **Home / Swipe Screen**
  * → College Detail Screen *(on card tap)*

* **College Detail Screen**
  * → Favorites Screen *(on "Save" action)*
  * → Applications Dashboard *(on "Apply" action)*
  * → Home / Swipe Screen *(on back navigation)*

* **Favorites Screen**
  * → College Detail Screen *(on college tap)*

* **Applications Dashboard**
  * → College Detail Screen *(on application tap)*

* **Profile Screen**
  * → Settings Screen *(via Settings button)*
  * → Onboarding Screen *(via "Edit Preferences")*

---

## Wireframes

![Wireframe 1](Wireframes/Screenshot%202026-03-28%20at%205.59.57%E2%80%AFPM.png)
![Wireframe 2](Wireframes/Screenshot%202026-03-28%20at%206.00.11%E2%80%AFPM.png)
![Wireframe 3](Wireframes/Screenshot%202026-03-28%20at%206.00.27%E2%80%AFPM.png)
![Wireframe 4](Wireframes/Screenshot%202026-03-28%20at%206.00.40%E2%80%AFPM.png)

---

## MVP Demo

[![MVP Demo](https://img.youtube.com/vi/kH5p2kJn51g/0.jpg)](https://youtube.com/shorts/kH5p2kJn51g)

---

## Schema

### Models

#### User
| Property | Type | Description |
|----------|------|-------------|
| `userId` | String | Unique identifier for the user (auto-generated) |
| `username` | String | User's display name |
| `email` | String | User's email address |
| `password` | String | Hashed password for authentication |
| `gpa` | Float | Self-reported GPA for personalization |
| `majorInterest` | String | User's intended major or field of study |
| `degreeType` | String | Undergraduate, Graduate, Transfer |
| `locationPreference` | String | Preferred region/state for colleges |
| `budgetMax` | Integer | Maximum annual tuition the user is comfortable with |
| `createdAt` | DateTime | Timestamp of account creation |

#### College
| Property | Type | Description |
|----------|------|-------------|
| `collegeId` | String | Unique identifier for the college |
| `name` | String | College name |
| `location` | String | City, State |
| `tuitionInState` | Integer | In-state annual tuition |
| `tuitionOutState` | Integer | Out-of-state annual tuition |
| `acceptanceRate` | Float | Overall acceptance rate (%) |
| `availableMajors` | Array[String] | List of offered majors |
| `imageUrl` | String | URL for the college card image |
| `description` | String | Short overview of the college |
| `applicationDeadline` | DateTime | Primary application deadline |

#### SavedCollege
| Property | Type | Description |
|----------|------|-------------|
| `savedId` | String | Unique identifier for the saved entry |
| `userId` | Pointer → User | Reference to the user who saved it |
| `collegeId` | Pointer → College | Reference to the saved college |
| `savedAt` | DateTime | Timestamp of when it was saved |
| `notes` | String | Optional user notes about the school |

#### Application
| Property | Type | Description |
|----------|------|-------------|
| `applicationId` | String | Unique identifier for the application |
| `userId` | Pointer → User | Reference to the applicant |
| `collegeId` | Pointer → College | Reference to the college applied to |
| `status` | String | Not Started / In Progress / Submitted / Decision Received |
| `submittedAt` | DateTime | Timestamp of submission |
| `decisionResult` | String | Accepted / Waitlisted / Denied / Pending |

---

### Networking

#### Login / Sign Up Screen
- `[POST] /users` — Create a new user account
- `[POST] /login` — Authenticate user and return session token

#### Onboarding Screen
- `[PUT] /users/:userId` — Save user preferences after onboarding

#### Home / Swipe Screen
- `[GET] /colleges` — Fetch paginated list of colleges (filtered by user preferences)
- `[POST] /savedColleges` — Save a right-swiped college

#### College Detail Screen
- `[GET] /colleges/:collegeId` — Retrieve full profile for a single college
- `[POST] /applications` — Create a new application entry

#### Favorites Screen
- `[GET] /savedColleges?userId=:userId` — Retrieve all saved colleges for the current user
- `[DELETE] /savedColleges/:savedId` — Remove a college from favorites

#### Applications Dashboard
- `[GET] /applications?userId=:userId` — Retrieve all applications for the current user
- `[PUT] /applications/:applicationId` — Update application status

#### Profile Screen
- `[GET] /users/:userId` — Retrieve current user profile
- `[PUT] /users/:userId` — Update user profile and preferences