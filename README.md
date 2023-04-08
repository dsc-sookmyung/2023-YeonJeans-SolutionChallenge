![image](https://user-images.githubusercontent.com/61380136/229182068-4f0bd606-8dd3-4e27-a95a-41edc9d37410.png)


<br/>
Saera is providing educational solutions based on the app's high accessibility to help North Koreans make a smooth transition to South Korea.

## ❗️  Introduction
North and South Korea use the same writing system and have similar grammar, but they have developed linguistic differences over the years due to their different environments and societies where they lived for many years after the division. For North Koreans adjusting to life in South Korea, pronunciation and accent can be some of the most challenging differences, leading to discrimination. To bridge this gap, we created SAERA, an app that enables users to learn pronunciation and accent. In pronunciation learning, we provide word examples with standard pronunciation and tips on how to pronounce words and what to pay attention to when pronouncing words based on the differences between South and North Korean. For intonation learning, SAERA presents the target intonation and voice audibly and visually through a Korean TTS and pitch graph generation model. It also visualizes the user's recorded voice in a graph and evaluates it with a rating for each graph. <br/>

With SAERA, we hope North Korean defectors can quickly learn the South Korean language system and overcome language barriers to settle into South Korean society stably.

<br/>

## 🗒  Role division
| Name                     | Role |
|--------------------------|------|
| 김도은 <br/> (Doeun Kim) | - UI Screen <br/>(Splash & Login Screen, Persistent TabBar, Today Learn Screen, Pronunciation Learn Screen, Accent Learn Screen, Create Custom Sentence Screen, MyPage Screen) <br/> - Automatic login <br/> - Today Learn <br/> - Pronunciation Learn <br/> - Accent Learn|
| 남수연 <br/> (Suyeon Nam)|- Extract pitch graph from voice using SPICE<br/>- Similarity Search<br/>- Calculate similarity between two pitch graphs<br/>- Deploy FastAPI + Nginx environment to GCP Virtual Machine<br/>- UX/UI Design<br/>- Train a model to classify end-of-speech pitch (deprecated)|
| 이주은 <br/> (Jueun Lee)          |- Deploy spring server with GCP Virtual Machine<br/>- Manage MySql DB with GCP SQL<br/>- Server APIs|
| 황연진 <br/> (Yeonjin Hwang) | - UI Screen <br/>(Home Screen, Bookmark Screen, Learn Screen, Accent Main Screen, Pronunciation Main Screen, Search Learn Screen, Custom Sentence Loading & Done Screen, Custom Sentence Home Screen, Today Learn Word & Sentence List Screen) <br/> - Home <br/> - Search & Filter <br/> - Learn Pronunciation & Accent Retrieve |

<br/>

## 🛠  Project Architecure

![structure](https://user-images.githubusercontent.com/61380136/228789413-032bc738-8622-4970-944b-4fd2e4136d29.png)

## 📽  Demo Video Link

 [![Sae:ra](https://user-images.githubusercontent.com/61380136/229182496-a3ea7c7f-313d-49b1-8ee0-e5b9ab106999.png)](https://www.youtube.com/watch?v=DNo8ptfh5Qg)
 
 <br/>

 
 
## 👩🏼‍💻  User Guide
### 01 Initial Screen
| Android Screen                                                                                                                 | iOS Screen | Explanation                              |
|--------------------------------------------------------------------------------------------------------------------------------|------------|------------------------------------------|
| <img src="https://user-images.githubusercontent.com/61380136/229187779-eb9e0f87-4881-465b-8a56-21b92a39d14e.gif" width="250"/> | <img src="https://user-images.githubusercontent.com/61380136/229757086-f452ee6b-4fbe-4187-8914-cd24aa2cae9b.gif" width="250"/>  | Enjoy Saera Through Your Google Account. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|

### 02 Home Screen
| Screen                                                                                                                        | Explanation                                           |
|-------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| <img src="https://user-images.githubusercontent.com/61380136/229188331-aba2c8b1-b7de-4c6f-aced-c4caac693e6e.gif" width="250"> | Learn the 5 most learned sentences and today's lesson. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|

### 03 Learn Screen
| Screen                                | Explanation |
|---------------------------------------|-------------------------------------------------------|
|**1) Pronuciation Learning** <br/> <br/> <img src="https://user-images.githubusercontent.com/61380136/229590186-580638f7-11e6-4c13-b0bd-bf1db7fa6ee6.gif" width="250"/> | To help you learn pronunciation systematically, there are 6 categories organized by pronunciation. <br/> <br/> [ User Guide ] <br/> 1. Listen example speech for the word. <br/> 2. Look at the example sentences to see how this word would be used. <br/> 3. Record your voice. <br/> 4. Press the next button to practice as many times as you want. <br/> 5. Click stop button and check out the learning report. |
| **2) Accent Learning** <br/> <br/> <img src="https://user-images.githubusercontent.com/61380136/229347561-820f69c3-2840-4d68-b8cd-9b43fcda6e17.gif" width="250"/> | [ User Guide ] <br/> 1. We provide example speech for the sentence. <br/> 2. Record your voice. <br/> 3. You will be given an intonation graph and rating for your voice. |
| **3) Custom Sentence** <br/> <br/> <img src="https://user-images.githubusercontent.com/61380136/229347375-d3f2e958-d7e1-4b37-bcef-27588e1b2607.gif" width="250"/> | Create intonation practice content by entering sentences and tags that you want to practice. <br/> You can create the intonation content in 3 seconds. <br/>  <br/> [ User Guide ] <br/> 1. Press the ‘+’ floating button in the bottom right corner. <br/> 2. Write down a sentence you want to learn and enter the appropriate tags. <br/> 3. Press the "Generate Sentence" button. |
| **4) Search** <br/> (Provide Similarity Search) <br/> <br/> <img src="https://user-images.githubusercontent.com/61380136/229589104-73d9f6a3-49a8-46d1-8dca-b261f3b0458a.gif" width="250"/> | We have introduced similarity search to recommend sentences that include similar meanings by understanding the user’s intent. <br/> <br/>[ User Guide ] <br/> 1. Search the word you want to learn. <br/> 2. You can select a situation or sentence type tag to choose the sentences you want to practice on. <br/> 3. Click the sentence you want to study. |

### 04 Bookmark Screen
| Screen                                                                                                                         | Explanation                                                                                                                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://user-images.githubusercontent.com/61380136/229195752-052e0931-496b-45fc-ae42-26657fd90da6.gif" width="250"/> | You can view your bookmarked contents in Bookmark tab. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br/> <br/> [ User Guide ] <br/> You can mark sentences and words for the following three pieces of content. <br/> 1. Pronunciation <br/>  2. Accent <br/> 3. Custom Sentence |


### 05 My Information Screen
| Screen                                                                                                                         | Explanation                                                                                                                                                                                                                                                                                                                                                                                                           |
|--------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://user-images.githubusercontent.com/61380136/229195541-5447e7c0-6888-4f59-aca8-69e50505effb.gif" width="250"/> | You can level up with experience points gained through learning. <br/> <br/> [ Level Up System ] <br/> For each pronunciation and accent, you can gain experience points upon initial learning. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br/> <br/> * You can gain 1 level for every 1000 xp <br/> 1. Today learn <br/>   - Pronunciation : +250 xp / se <br/> - Accent : +750 xp / set <br/> 2. Pronunciation learn : +25 xp <br/> 3. Accent learn : +100 xp |


<br/>

## 📲  Execution Method

###  For Android User

1. Download the apk file at Releases tab.
2. Run the apk file on your phone.

### For iOS User
 
Update Soon!


<br/>

## 👥  Contributors

|[김도은](https://github.com/whaeundo25)|[남수연](https://github.com/mori8)|[이주은](https://github.com/lizuAg)|[황연진](https://github.com/yeoncheong)|
|---|---|---|---|
|<img src="https://github.com/whaeundo25.png">|<img src="https://github.com/mori8.png">|<img src="https://github.com/lizuAg.png">|<img src="https://github.com/yeoncheong.png">|
