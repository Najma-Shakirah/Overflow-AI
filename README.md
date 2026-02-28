
# 🌊 Overflow AI  

Overflow AI is an intelligent flood preparedness and response mobile application that leverages AI-powered prediction, real-time weather data, and offline-first design to help communities prepare for and respond to floods effectively.

---

##  Repository Overview  

###  Team Name  
**Copedepedepod**

### 👥 Team Members  
1. **Siti Nurul Amirah Binti Sheikh Sulaiman** – Team Leader  
2. Najma Shakirah Binti Shahrulzaman  
3. Raden Salma Humaira Binti Muhammad Mu'nim  
4. Nawwarah Auni Binti Nazrudin  

---

#  Project Overview  

##  Problem Statement  
Floods remain one of the most frequent natural disasters in many regions, particularly in urban areas. Despite existing warning systems, several critical gaps remain:

###  Lack of Real-Time, Localized Flood Information  
Traditional flood warning systems provide broad regional alerts that fail to account for hyperlocal conditions. Residents often do not know the immediate risk in their exact location.

###  Delayed Emergency Response Coordination  
Emergency services struggle to prioritize rescue operations due to fragmented data about affected areas, trapped individuals, and available resources.

###  Information Gaps During Critical Moments  
Residents require instant access to:
- Evacuation routes  
- Nearby shelters  
- Emergency contacts  
- Safety protocols  

However, this information is often scattered or unavailable during network disruptions.

###  Post-Flood Recovery Challenges  
Communities lack centralized platforms to:
- Report damages  
- Request assistance  
- Connect with relief organizations

###  Connectivity Issues During Floods
Flood often distrupt internet access, making digital tools unusable

##  SDG Alignment  

Overflow AI aligns with:

- **SDG 11 – Sustainable Cities and Communities**  
  Enhancing disaster resilience in urban areas.

- **SDG 13 – Climate Action**  
  Supporting proactive adaptation and response to climate-related disasters.


##  Short Description of the Solution  

Overflow AI addresses the limitations of traditional flood app by delivering:

- AI-based flood prediction  
- Real-time weather and river level monitoring  
- Flood Alerts 
- Photo AI Analyser
- Live Monitoring
- Offline access during poor connectivity  
- Community-powered reporting
- Evacuation Plan AI Generator
- News AI Summarization

Unlike generic early warning systems, Overflow AI integrates prediction, mapping, preparedness education, and emergency coordination into one unified platform.


#  Key Features  

- **Flood Prediction AI**
 – Predicts potential flood risk using weather and environmental data
 
- **Real-Time Flood Map**
 – Displays affected and high-risk areas
- **Alert System**
 – Location-based real-time notifications
- **Photo AI Analyzer**
 – Assesses flood severity from uploaded images
- **Evacuation AI Generator Plan**
 – Personalised evacuation guidance
- **Alert & Notification System**
 – Sends timely emergency updates
- **Shelter Locator**
 – Shows available shelters information 
- **Community Reporting**
 – Allows users to report real-time flood conditions  
- **Gamified Flood Preparedness Education**
 – Interactive learning module  
- **Emergency Checklist**
 – Personalized preparation checklist  
- **Offline Mode**
 – Core features accessible without stable internet  
- **Dashboard/Home Page**
– Centralized flood status overview  
- **User Profile Page**
– Personalized data & reporting history  

---

# Overview of Technologies Used  

##  Google Technologies  

###  Flutter (Dart)  
Used to build a cross-platform mobile application with a responsive and modern UI.

###  Firebase  
Used as the backend infrastructure for:
- Authentication  
- Real-time database (Firestore)  
- Cloud storage  
- Push notifications  


## 🌦 Other Supporting Tools / APIs  

###  OpenWeather API  
Provides:
- Real-time weather data  
- Rainfall forecasts  
- Environmental indicators  

Used as input data for flood risk prediction.

###  Additional Libraries  
- HTTP package for API calls  
- Map integration libraries  
- Notification services  
- Local storage for offline functionality  



#  Implementation Details & Innovation  

##  System Architecture  

Overflow AI consists of:

- **Frontend (Flutter Mobile App)**  
  Handles UI, user interaction, offline storage, and map visualization.

- **Backend (Firebase)**  
  Manages authentication, database, cloud messaging, and community reports.

- **External APIs (OpenWeather)**  
  Supplies real-time weather data used in flood risk calculations.

- **AI Prediction Module**  
  Processes environmental indicators to generate flood risk levels.



##  Workflow  

1. User register into the app
2. 
3.
4.
5.


##  Innovation  

- Hyperlocal prediction instead of regional alerts  
- Offline-first disaster design  
- Community-powered real-time reporting  
- Gamified preparedness education  
- Unified platform combining prediction, response, and recovery  


#  Challenges Faced  

Here are the challenges, with the social media point added:

---

## ⚠️ Challenges Faced

- **AI Contextualisation**
Getting Gemini to generate *useful*, location-specific evacuation plans required feeding it live weather and flood data, and engineering prompts that returned structured output instead of generic text.

- **Unreliable Live Data**
Real sensor data from JPS isn't always available. We built a fallback chain — live Firestore → cached Hive data → mock data — so the app never breaks during a disaster when users need it most.

- **Multi-Source News Aggregation**
Merging three data sources (NewsData.io, JPS RSS, social media) with different formats, languages (EN + BM), and reliability into one clean feed required a custom deduplication algorithm.

- **Social Media Data Restrictions**
Platforms like TikTok, X, and Facebook don't offer free public APIs for content scraping. We couldn't pull live posts directly, so we routed through a Firebase Cloud Function and fell back to deep-linking users to live search results — a practical workaround but a real limitation.

- **Offline Support**
The app is most needed when connectivity fails during floods. Knowing when to serve cached vs. live data — and what to pre-download — required deliberate architecture decisions using Hive + Firestore together.

- **Community Posts**
Coordinating image uploads to Cloudinary, retrieving the URL, then writing to Firestore — with proper error handling at each step — made what looks like a simple post feature technically involved.

- **Auth Edge Cases**
Handling three user states (registered, guest, loading) consistently across every screen, including edge cases like Firestore not yet written after registration or network failures mid-login, was harder than expected.

- **Keeping Shelter Data Current**
The shelter model tracks rich real-world detail (occupancy, medical needs, supplies). Without a live admin portal, keeping this data accurate during an actual flood event remains an operational challenge.

- **Games Without a Game Engine**
Flutter isn't built for games. Building custom water animations, collision detection, and game loops using `CustomPainter` and ViewModels alone — with no dedicated engine — took significant extra effort.



#  Installation & Setup  

##  Live Demo
Try the live version here : https://overflow-ai-five.vercel.app/

##  Prerequisites  

- Flutter SDK  
- Dart

## Installations 

```bash
1. Clone the repository
git clone https://github.com/your-username/overflow-ai.git

2. Navigate to project folder
cd overflow-ai

3. Install dependencies
flutter pub get

4. 


6. Run the application
flutter run
```
## Future Roadmap
### ✅ Currently Built
- [x] User authentication (login, register, guest)
- [x] Home dashboard with live weather & AI flood risk card
- [x] Flood alerts feed with filters
- [x] Live map monitor with road closures
- [x] Community posts with photo uploads
- [x] Flood reporting
- [x] AI evacuation plan generator (Gemini 2.5 Flash)
- [x] AI flood photo analyser
- [x] Shelter finder with live capacity data
- [x] Emergency preparedness checklist
- [x] Flood-themed educational games (3 games)
- [x] News feed (NewsData.io + JPS RSS)
- [x] Push notifications (FCM)
- [x] Offline caching (Hive)

---

### 🚧 Phase 1 — Near Term
- [ ] Full Bahasa Malaysia localisation
- [ ] Home screen widget (flood risk at a glance)
- [ ] Real JPS sensor API integration (live water levels)
- [ ] Offline / disaster mode (pre-downloaded plans & shelters)

### 🔮 Phase 2 — Mid Term
- [ ] Rescue request board (stranded → volunteer → rescued)
- [ ] Shelter check-in & reservation system
- [ ] Predictive flood arrival time (AI + rainfall trends)
- [ ] Web admin portal for shelter coordinators

### 🌟 Phase 3 — Long Term
- [ ] Gemini-powered flood assistant chatbot
- [ ] Video flood analysis (extend photo analyser)
- [ ] Flood heatmap dashboard for authorities
- [ ] NADMA / Bomba / Red Crescent official alert integration
- [ ] SMS fallback alerts for no-internet scenarios
