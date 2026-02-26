
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

##  SDG Alignment  

Overflow AI aligns with:

- **SDG 11 – Sustainable Cities and Communities**  
  Enhancing disaster resilience in urban areas.

- **SDG 13 – Climate Action**  
  Supporting proactive adaptation and response to climate-related disasters.


##  Short Description of the Solution  

Overflow AI addresses the limitations of traditional flood systems by delivering:

- AI-based flood prediction  
- Real-time weather and river level monitoring  
- Hyperlocal alerts  
- Offline access during poor connectivity  
- Community-powered reporting  

Unlike generic early warning systems, Overflow AI integrates prediction, mapping, preparedness education, and emergency coordination into one unified platform.


#  Key Features  

- **Flood Prediction AI** – Predicts potential flood risk using weather and environmental data  
- **Real-Time Flood Map** – Displays affected and high-risk areas  
- **Evacuation AI** – Shows nearest evacuation center
- **Alert & Notification System** – Sends timely emergency updates
- **Shelter Locator** – Shows available shelters information 
- **Community Reporting** – Allows users to report real-time flood conditions  
- **Gamified Flood Preparedness Education** – Interactive learning module  
- **Emergency Checklist** – Personalized preparation checklist  
- **Offline Mode** – Core features accessible without stable internet  
- **Dashboard/Home Page** – Centralized flood status overview  
- **User Profile Page** – Personalized data & reporting history  

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

- 



#  Installation & Setup  

##  Requirements  

- Flutter SDK  
- Dart  
- Firebase project setup  
- OpenWeather API key  

---

## Setup Instructions  

```bash
1. Clone the repository
git clone https://github.com/your-username/overflow-ai.git

2. Navigate to project folder
cd overflow-ai

3. Install dependencies
flutter pub get

4. Add your OpenWeather API key in the configuration file

5. Configure Firebase
- Add google-services.json (Android)


6. Run the application
flutter run
