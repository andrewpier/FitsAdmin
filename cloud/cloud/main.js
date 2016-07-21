//hello?
Parse.Cloud.beforeSave("Post", function(request, response) {
    var comment = request.object.get("PostIDNumber");
    if (!(comment > 1)) {
        var number = 4;

        var query = new Parse.Query("Voting");
        query.greaterThan("mostRecentPost", 0);
        query.first({
            success: function(object) {
                // Successfully retrieved the object.
                number = object.get("mostRecentPost");
                number = number + 1;
                request.object.set( "PostIDNumber", number);
                object.set("mostRecentPost", number);
                object.save(null, {
                    success: function(object) {
                        // Execute any logic that should take place after the object is saved.
                        response.success();
                    },
                    error: function(gameScore, error) {
                        // error is a Parse.Error with an error code and message.
                        console.log("error:");
                        console.log(error);
                    }
                });
            },
            error: function(error) {
                console.log("error:");
                console.log(error);
            }
        });

		
    } else {
        response.success();
    }
	
});

Parse.Cloud.define("addVotes", function(request, response) {
    var numberOfVotes = request.params.number;
    var arrayOfPosts =  request.params.posts;
    var arrayOfVotes =  request.params.votes;
    var number = -5;
    for (var j = 0; j < (numberOfVotes-1); ++j) {
        (function(){
            var iter = j;
            var myPost = arrayOfPosts[iter];
            var myVote = arrayOfVotes[iter];
            var typeOfVote = "";
            var query = new Parse.Query("PostStatistics");
            query.equalTo("ParentObjectId", myPost);
            query.find({
                success: function(results) {
                    for (var i = 0; i < results.length; ++i) {
                       if (myVote){
                           typeOfVote = "Positive";
                           number = results[i].get("PositiveVotes");
                           number = number + 1;
                           results[i].set("PositiveVotes", number);
                       }
                       else {
                           typeOfVote = "Negative";
                           number = results[i].get("NegativeVotes");
                           number = number + 1;
                           results[i].set("NegativeVotes", number);
                       }
                       results[i].save(null, {
                           success: function(object) {
                           },
                           error: function(gameScore, error) {
                               // error is a Parse.Error with an error code and message.
                               console.log("error:");
                               console.log(error);
                           }
                       });
                    }
                },
                error: function() {
                    response.error("object lookup failed");
                }
            });
        })();
    }
                   
    //Need to run a last time to be able to properly call the success function
   (function(){
        var myPost = arrayOfPosts[(numberOfVotes-1)];
        var myVote = arrayOfVotes[(numberOfVotes-1)];
        var typeOfVote = "";
        var query = new Parse.Query("PostStatistics");
        query.equalTo("ParentObjectId", myPost);
        query.find({
               success: function(results) {
                   for (var i = 0; i < results.length; ++i) {
                       if (myVote){
                           typeOfVote = "Positive";
                           number = results[i].get("PositiveVotes");
                           number = number + 1;
                           results[i].set("PositiveVotes", number);
                       }
                       else {
                           typeOfVote = "Negative";
                           number = results[i].get("NegativeVotes");
                           number = number + 1;
                           results[i].set("NegativeVotes", number);
                       }
                       results[i].save(null, {
                           success: function(object) {
                               // Execute any logic that should take place after the object is saved.
                               response.success("Saved");
                           },
                           error: function(gameScore, error) {
                               // error is a Parse.Error with an error code and message.
                               console.log("error:");
                               console.log(error);
                               response.error("Save failed");
                           }
                       });
                   }
               },
               error: function() {
                     response.error("object lookup failed");
               }
        });
    })();
});




Parse.Cloud.afterSave("Post", function(request) {
                      var item = request.object.id;
                      var btObj = request.object.get("BelongsTo")
                      var query = new Parse.Query("UserInformation");
                      query.equalTo("BelongsTo", btObj);
                      query.find({
                         success: function(results) {
                                 for (var i = 0; i < results.length; ++i) {
                                    var userPosts = results[i].get("UserPosts");
                                    userPosts.push(item);
                                    results[i].set("UserPosts", userPosts);
                                 results[i].save(null, {
                                 success: function(object) {
                                    // Execute any logic that should take place after the object is saved.
                                    console.log("Saved");
                                 },
                                 error: function(gameScore, error) {
                                    // error is a Parse.Error with an error code and message.
                                    console.log("error:");
                                    console.log(error);
                                    console.log("Save failed");
                                 }
                                 });
                                 }
                                 
                         },
                         error: function() {
                                 console.log("object lookup failed");
                         }
                     });

});


//given number of tags from post
// and an array of the tags to post
//then it will look for the tag and if its not there create it
// and if it is there then update the Posts field

Parse.Cloud.define("addTags", function(request, response) {
                   var numberOfTags = request.params.number;
                   var arrayOfTags =  request.params.tags;
                   var postID = request.params.postID;
                   console.log(arrayOfTags)
                   for (var j = 0; j < (numberOfTags-1); ++j) {
                   (function(){
                    var iter = j;
                    var myTag = arrayOfTags[iter];
                    var query = new Parse.Query("Tags");
                    query.equalTo("Tag", myTag);
                    query.find({
                               success: function(results) {
                               for (var i = 0; i < results.length; ++i) {
                               var postsWithTag = results[i].get("Posts");
                                postsWithTag = postsWithTag + postID;
                               results[i].set(Posts , postsWithTag);
                               results[i].save(null, {
                                            success: function(object) {
                                            },
                                            error: function(gameScore, error) {
                                            // error is a Parse.Error with an error code and message.
                                            console.log("error:");
                                            console.log(error);
                                            }
                                            });
                               
                               }},
                               error: function() {
                               response.error("object lookup failed");
                               }
                               });
                    
                
                    })();}
                   
                   
                   //Need to run a last time to be able to properly call the success function
                   
                   (function(){
                    var myTag = arrayOfTags[(numberOfTags-1)];
                    var typeOfVote = "";
                    var query = new Parse.Query("Tags");
                    query.equalTo("Tag", myTag);
                    query.find({
                               success: function(results) {
                               for (var i = 0; i < results.length; ++i) {
                               var postsWithTag = results.get("Posts");
                               var postsWithTag = postsWithTag + myTag;
                               results[i].set(Posts , postsWithTag);
                               results[i].save(null, {
                                            success: function(object) {
                                            },
                                            error: function(gameScore, error) {
                                            // error is a Parse.Error with an error code and message.
                                            console.log("error:");
                                            console.log(error);
                                            }
                                            });
                               }
                               
                               },
                               error: function() {
                               response.error("object lookup failed");
                               }
                               });
                    })();

                   });

                       
Parse.Cloud.define("goodPost", function(request, response) {
    var admin = Parse.Object.extend("Post");
    var post = new admin();
    post.set("PostIDNumber",request.params.PostIDNumber);
    post.set("Thumbnail",request.params.Thumbnail);
    post.set("BelongsTo",request.params.BelongsTo);
    post.set("ThumbnailRect",request.params.ThumbnailRect);
    post.set("BelongsTo",request.params.BelongsTo);
    post.set("AllowComments",request.params.AllowComments);
    post.set("BelongsTo",request.params.BelongsTo);
        
    post.save(null,{
        success:function(person) { 
            response.success(person);
        },
        error:function(error) {
            response.error(error);
        }
    });
    
});
