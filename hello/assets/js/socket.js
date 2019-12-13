import {Socket} from 'phoenix'

let socket = new Socket("/socket", {params: {token: window.userToken}})
let user;

socket.connect()


// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
//////////////////////////////////////////////////////// SIGN IN

var si = document.getElementById('register');
if(si){
  
  si.addEventListener('submit', (e) => {
    e.preventDefault()
  let messageInput = e.target.querySelector('#message-content').value
  let pwd = e.target.querySelector('#pwd-content').value 
   
  let signIn = [messageInput,pwd]

  channel.push('register', { message: signIn }).receive('ok', function ()
  {
   location.href = "http://localhost:4000/hello/"+messageInput;
  });

    
    });

}


///////////////////////////////////////////////////// FROM ELIXIR TO JS
channel.on("room:lobby:new_message", (message) => {
 document.getElementById('output-board').innerHTML = message["content"]

});

//////////////////// LOG IN BELOW

var el = document.getElementById('Log-in');
if(el){
  
  el.addEventListener('submit', (e2) => {
      e2.preventDefault()
      let username = e2.target.querySelector('#logIn-username').value
      let pwd = e2.target.querySelector('#logIn-pwd').value 
      user = username
       
      let LogIn = [username,pwd]
     channel.push('log-in', { message: LogIn }).receive('ok', function ()
     {
      location.href = "http://localhost:4000/hello/"+username;
     });
    
    });

}



channel.on("Log-in", (message) => {
  
  if(message["status"] == 1){
  document.getElementById('loginstatus').innerHTML = "Logged in successfully";
  }
  else{
    document.getElementById('loginstatus').innerHTML = "Invalid credentials!";
  }
  });

///////////////////// LOGGED IN USER CODES

// SUBSCRIBE TO 
var subsTo = document.getElementById('SubstoButton');

if(subsTo){

  subsTo.addEventListener('click', (c1) => {
    c1.preventDefault()
    let username = document.getElementById('userName').innerHTML
    let subscriberData =  document.getElementById('subscribeTo').value
    let SubscriberList = [username,subscriberData]
   channel.push('Subscribe-TO', { message: SubscriberList })
  
  });

}

// SEND TWEET
var sendTweetE = document.getElementById('sendTweet');
if(sendTweetE){
  sendTweetE.addEventListener('click', (c1) => {
    c1.preventDefault()

    let username = document.getElementById('userName').innerHTML
    let tweetMsg =  document.getElementById('tweet').value
   let TweetData = [username,tweetMsg]
   channel.push('send-Tweet', { message: TweetData })

  });
}

// LOG OUT
var logout = document.getElementById('logout');
if(logout){
  logout.addEventListener('click', (c1) => {
    c1.preventDefault()
   let username = document.getElementById('userName').innerHTML
   let TweetData = [username]
   channel.push('logout', { message: TweetData }).receive('ok', function ()
     {
      location.href = "http://localhost:4000/hello/";
     });

  });
}

// DELETE ACCOUNT
var deleteA = document.getElementById('delete');
if(deleteA){
  deleteA.addEventListener('click', (c1) => {
    c1.preventDefault()
   let username = document.getElementById('userName').innerHTML
   let TweetData = [username]
   channel.push('delete', { message: TweetData }).receive('ok', function ()
   {
    location.href = "http://localhost:4000/hello/";
   });

  });
}

// SEND TWEET
var reTweetE = document.getElementById('reTweet');
if(reTweetE){
  reTweetE.addEventListener('click', (c1) => {
    c1.preventDefault()

    let username = document.getElementById('userName').innerHTML
   let TweetData = [username]
   channel.push('re-Tweet', { message: TweetData })

  });
}

// SEND TWEET
var sendTweetE = document.getElementById('signup');
if(sendTweetE){
  sendTweetE.addEventListener('click', (c1) => {
    c1.preventDefault()

    let username = document.getElementById('userName').innerHTML

   let TweetData = [username]
   channel.push('sign-up', { message: TweetData })

  });
}
// FETCH TWEET FROM SPECEFIC USERS

var fetchTweetE = document.getElementById('userTweetBox');
if(fetchTweetE){
  setInterval(()=>{fetchTweetE.click()},2*1000);
  fetchTweetE.addEventListener('click', (c2) => {
    c2.preventDefault()
    let username = document.getElementById('userName').innerHTML
   let TweetData = [username]
  channel.push('fetch-Tweet', { message: TweetData })

  });
}

channel.on("fetch-Tweet", (message) => {
 
  document.getElementById('userTweetBox').innerText = "";
  document.getElementById('userTweetBox').append(JSON.stringify(message))
  
  });

  // Fetch tweets for specific hashtags
  var fetchHashE = document.getElementById('fetchhashButton');
if(fetchTweetE){
  fetchHashE.addEventListener('click', (c2) => {
    c2.preventDefault()
 
    let hashtag = document.getElementById('fetchHash').value
   let TweetData = [hashtag]
  channel.push('fetch-hash', { message: TweetData })

  });
}
  channel.on("fetch-hash", (message) => {
 
    document.getElementById('userTweetBox2').innerText = "";
    document.getElementById('userTweetBox2').append(JSON.stringify(message))
    
    });


//

//////////////////////

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket