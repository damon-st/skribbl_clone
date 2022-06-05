const express = require("express");
var http = require("http");
const app = express();
const port = process.env.PORT ||3000;
var server = http.createServer(app);
const mongoose = require("mongoose");

const Room = require("./models/room");

const getWord = require("./api/get_word");

var io = require("socket.io")(server);

//middleware
app.use(express.json());

//connet to our MongoDB
const DB = "mongodb+srv://damon:1234Damon.@cluster0.qxd98ck.mongodb.net/?retryWrites=true&w=majority";
mongoose.connect(DB).then(()=>{
    console.log("Connection Success db");
}).catch(e =>{
    console.log("Error db"+ e);
});


io.on("connection",(socket)=>{
    console.log("connected");
    //CREATE GAME CALLBACK
    socket.on("create-game",async ({nickname,name,occupancy,maxRounds})=>{
        try {
            const existRoom = await Room.findOne({name});
            if(existRoom){
                socket.emit("notCorrectGame","Room with that name already exists!");
                return;
            }
            let room = new Room();
            const word = getWord();
            room.word = word;
            room.name = name;
            room.occupancy = occupancy;
            room.maxRounds = maxRounds;
            
            let player = {
                socketID: socket.id,
                nickname:nickname,
                isPartyLeader:true,
            };
            room.players.push(player);
            room = await room.save();
            socket.join(name);
            io.to(name).emit("updateRoom",room);
        } catch (error) {
            console.log(error);
        }
    });

    //JOIN GAME CALLBACK
    socket.on("join-game",async({nickname,name})=>{
        try {
            
            let room = await Room.findOne({name});
            if(!room){
                socket.emit("notCorrectGame","Please enter a valid room name");
                return;
            }
            
            if(room.isJoin){
                let player = {
                    socketID: socket.id,
                    nickname:nickname,
                };
                room.players.push(player);
                socket.join(name);

                if(room.players.length === room.occupancy){
                    room.isJoin = false;
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit("updateRoom",room);

            }else {
                socket.emit("notCorrectGame","The game is in progress, please try later");

            }
        } catch (error) {
            console.log(error);
        }
    });

    //message
    socket.on("msg",async(data)=>{
        try {
            if(data.msg === data.word){
                let room = await Room.find({name:data.roomName});
                let userPlayer = room[0].players.filter((player)=> player.nickname === data.username);
                if(data.timeTaken !== 0){
                    userPlayer[0].points += Math.round((200/data.timeTaken)*10);
                }
                room = await room[0].save();
                io.to(data.roomName).emit("msg",{
                    username:data.username,
                    msg: "Guessed it!",
                    guessedUserCtr:data.guessedUserCtr+1,
                });
                socket.emit("closeInput","");
            }else {
                io.to(data.roomName).emit("msg",{
                    username:data.username,
                    msg: data.msg,
                    guessedUserCtr:data.guessedUserCtr,
                });
    
            }
     
        } catch (error) {
            console.log(error);
        }
    });

    socket.on("updateScore",async(name)=>{
        try {
            const room = await Room.findOne({name});
            io.to(name).emit("updateScore",room);
        } catch (error) {
            console.log(error);
        }
    });

    //cahnge tourn
    socket.on("change-turn",async(name)=>{
        try {
            
        let room = await Room.findOne({name});
        let idx = room.turnIndex;
        if(idx+1 === room.players.length){
            room.currentRound+=1;
        }
        if(room.currentRound <= room.maxRounds){
            const word = getWord();
            room.word = word;
            room.turnIndex = (idx+1)% room.players.length;
            room.turn = room.players[room.turnIndex];
            room = await room.save();
            io.to(name).emit("change-turn",room);
        }else {
            //show the leaderboard
            io.to(name).emit("show-leaderboard",room.players);
        }

        } catch (error) {
            console.log(error);
        }
    });

    // White borad sockets
    socket.on("paint",({details,roomName})=>{
        io.to(roomName).emit("points",{details:details});
    });

    //color
    socket.on("color-change",({color,roomName})=>{
        io.to(roomName).emit("color-change",color);
    });
    //strock width
    socket.on("stroke-with",({value,roomName})=>{
        io.to(roomName).emit("stroke-with",value);
    });
    //clear Screen
    socket.on("clean-screen",(roomName)=>{
        io.to(roomName).emit("clean-screen","");
    });
    //disconnect
    socket.on("disconnect",async()=>{
        try {
            var room = await Room.findOne({"players.socketID":socket.id});
            console.log(room);
            if(room !=null){
                for(var i =0; i < room.players.length; i++){
                    if(room.players[i].socketID === socket.id){
                        room.players.splice(i,1);
                        break;
                    }
                }
                room = await room.save();
                if(room.players.length ===1){
                    socket.broadcast.to(room.name).emit("show-leaderboard",room.players);
                }else{
                    socket.broadcast.to(room.name).emit("user-disconnected",room);
                }
            }else{
                socket.emit("user-disconnected",room);
            }
        } catch (error) {
            console.log(error);
        }
    });

});

server.listen(port,"0.0.0.0",()=> {
    console.log("Server started and runing on port "+ port);
});