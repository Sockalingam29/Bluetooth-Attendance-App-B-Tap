# Bluetooth Attendance app
Our project is a Bluetooth attendance system that can be used to take attendance in classes instantly. It uses [Nearby Connections API](https://developers.google.com/nearby/connections/overview) to discover nearby devices and mark attendance on the database. The communication model used is an advertise-discover communication model in which the teacher acts as the advertiser and the students discover the advertiser, i.e the teacher. This is a 1 to N connection.

The teacher has to select the semester, subject and slot for which they are taking attendance and click the submit button. Now the device starts advertising. 
On the student's view they just click a button to start discovering. And once the faculty is detected, the data is verified, and the attendance is recorded.
The teacher can also export the attendance data for any date as a CSV file.
## Demo
https://drive.google.com/file/d/1HFzRfbAdhQ4Gnc2p1IKb_vpfLU1ZV99E/view?usp=sharing 

## Workflow
### Student Registration and login
<div>
  <img src="https://user-images.githubusercontent.com/74052417/230736620-a493c671-fa2d-4062-8296-150b9b3ae99d.jpg" alt="Registration page" width="200" height="450">
  <img src="https://user-images.githubusercontent.com/74052417/230736805-30b4d892-988d-4966-8d2a-d89bc4058bf3.jpg" alt="Registration filled" width="200" height="450">
  <img src="https://user-images.githubusercontent.com/74052417/230736873-a1406d2c-a0fa-4f61-88c0-1703e3b37b39.jpg" alt="Login" width="200" height="450">
</div>

### Student / Discoverer
<div>
  <img src="https://user-images.githubusercontent.com/74052417/230737022-a9a67eac-340f-4b2c-a753-dd2bc2ef96c2.jpg" alt="Bluetooth" width="200" height="450">
  <img src="https://user-images.githubusercontent.com/74052417/230737028-adacf3c9-0203-4704-97f6-4e50ea951e2c.jpg" alt="Discovering" width="200" height="450">
  <img src="https://user-images.githubusercontent.com/74052417/230737032-c8c3f53b-cbcc-46cc-a824-9eabd52a7e8e.jpg" alt="Attendance recorded" width="200" height="450">
</div>

### Faculty / Advertiser
<div>
  <img src="https://user-images.githubusercontent.com/74052417/230737114-cd1c241a-dc2e-4ae2-bcf3-45f74daaabc8.jpg" alt="Class details" width="200" height="450">
    <img src="https://user-images.githubusercontent.com/74052417/230737133-c16b7271-b096-42ba-8566-1394820cd02a.jpg" alt="Advertising" width="200" height="450">
  <img src="https://user-images.githubusercontent.com/74052417/230737117-5023aa10-ed1f-4fd9-8a0a-b108abe6fae6.jpg" alt="Studnet list" width="200" height="450">
</div>

## Download the App
**Play Store:** https://play.google.com/store/apps/details?id=com.attendance.att_blue

**Test credentials:**

**Faculty:**

Email: janedoe@tce.edu

Password: jane123

**Student:**

Email: test3a1@student.tce.edu

Password: test123
