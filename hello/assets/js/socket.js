import {Socket} from 'phoenix'

let socket = new Socket("/socket", {params: {token: window.userToken}})
let user;

socket.connect()


// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
//////////////////////////////////////////////////////// SIGN IN

var si = document.getElementById('new-message');
if(si){
  
  si.addEventListener('submit', (e) => {
    e.preventDefault()
  let messageInput = e.target.querySelector('#message-content').value
  let pwd = e.target.querySelector('#pwd-content').value 
   
  let signIn = [messageInput,pwd]

 channel.push('sign-in', { message: signIn })

    
    });

}




///////////////////////////////////////////////////// FROM ELIXIR TO JS
channel.on("room:lobby:new_message", (message) => {
  console.log("message", message)
  //output-board
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


///////////////////// LOGGED IN USER CODES

// SUBSCRIBE TO 
var subsTo = document.getElementById('SubstoButton');

if(subsTo){

  subsTo.addEventListener('click', (c1) => {
    c1.preventDefault()
    let username = document.getElementById('userName').innerHTML
    let subscriberData =  document.getElementById('subscribeTo').value
    // console.log(user)
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
    console.log("Here")
   let TweetData = [username,tweetMsg]
   channel.push('sign-up', { message: TweetData })

  });
}

// SEND TWEET
var sendTweetE = document.getElementById('signup');
if(sendTweetE){
  sendTweetE.addEventListener('click', (c1) => {
    c1.preventDefault()

    let username = document.getElementById('userName').innerHTML

   let TweetData = [username]
   channel.push('send-Tweet', { message: TweetData })

  });
}
// FETCH TWEET FROM SPECEFIC USERS

var fetchTweetE = document.getElementById('fetchTweetButton');
if(fetchTweetE){

  fetchTweetE.addEventListener('click', (c2) => {
    c2.preventDefault()
    var fromUserString =  document.getElementById('fetchTweet').value
    
    var fromUserList = fromUserString.split(' ');
    console.log(fromUserList)

  channel.push('fetch-Tweet', { message: fromUserList })

  });
}

channel.on("fetch-Tweet", (message) => {
 
  console.log("message",message)  
  document.getElementById('userTweetBox').innerHTML = JSON.stringify(message)
  
  });


//

//////////////////////

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket