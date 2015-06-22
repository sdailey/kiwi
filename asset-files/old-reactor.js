// by Mohsen on Stack Overflow -- http://stackoverflow.com/questions/15308371/custom-events-model-without-using-dom-events-in-javascript

function __Event(name){
  this.name = name;
  this.callbacks = [];
}
__Event.prototype.registerCallback = function(callback){
  this.callbacks.push(callback);
}

function bReactor(){
  this.events = {};
}

bReactor.prototype.registerEvent = function(eventName){
  var event = new __Event(eventName);
  this.events[eventName] = event;
};

bReactor.prototype.dispatchEvent = function(eventName, eventArgs){
  this.events[eventName].callbacks.forEach(function(callback){
    callback(eventArgs);
  });
};

bReactor.prototype.addEventListener = function(eventName, callback){
  this.events[eventName].registerCallback(callback);
};