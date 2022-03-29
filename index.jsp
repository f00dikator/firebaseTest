// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();


exports.showAuthLevel = functions.https.onRequest(async (request, response) => {
  // parses the request for a user's auth_id and then looks up that auth_id in firestore 
  // request : the HTTP request
  // response : JSON response to request

  //grab the user auth ID from the request
  const user = request.query['auth_id'];  

  //default to not authenticated
  let authenticated = false
  
  // require 28 char hash and nothing else
  const myregex = /^([a-zA-Z0-9]{28})$/g;
  
  //initialize message to empty string
  let mymessage = ""

  if (! user)
  // auth_id param not passed via request 
  {
    console.log("Failed to retrieve a user from query");
    mymessage = "The paramater auth_id was not present in the HTTP request"
    authenticated = false;
  } 
  else 
  {
    const regexresults = myregex.exec(user);
    if (! regexresults) 
    // The auth_id had invalid characters or insufficient length to be evaluated
    {
      console.log("Invalid Auth ID sent to showAuthLevel");
      mymessage = "The auth_id had invalid characters or insufficient length to be evaluated"
      authenticated = false;
    } 
    else 
    {
      let snapshot = await admin.firestore().collection('users').where('auth_id', '==', user).get();

      snapshot.forEach(doc => {
      if (doc.data()['is_admin'] == true) 
        {
          authenticated = true;
          console.log(doc.data()['auth_id'] + " " + doc.data()['first_name'] + " " + doc.data()['last_name'] + " is an admin user")
          mymessage = doc.data()['first_name'] + " " + doc.data()['last_name'] + " is an admin user"
        }
      });
    }
  }
  
  response.send({
     "response" : {
       "is_admin" : authenticated,
       "message" : mymessage
     }
  })
});
